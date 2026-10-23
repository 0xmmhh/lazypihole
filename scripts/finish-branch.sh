#!/usr/bin/env bash
#
# Integrate the current feature branch into main with a fast-forward,
# push main and delete the branch locally and on the remote.
#
# Every check runs before anything is changed. Usage:
#   scripts/finish-branch.sh [--dry-run]
#   git finish [--dry-run]            (alias: git config alias.finish '!scripts/finish-branch.sh')
#
# Written for macOS's bash 3.2: no bash 4+ features.

set -euo pipefail

MAIN="main"
REMOTE="origin"

DRY_RUN=false

# --- output helpers ----------------------------------------------------------

if [[ -t 1 ]]; then
    RED=$'\033[31m' GREEN=$'\033[32m' YELLOW=$'\033[33m' BOLD=$'\033[1m' RESET=$'\033[0m'
else
    RED="" GREEN="" YELLOW="" BOLD="" RESET=""
fi

step() { printf '%s==>%s %s\n' "$BOLD" "$RESET" "$1"; }
ok()   { printf '    %s✓%s %s\n' "$GREEN" "$RESET" "$1"; }
warn() { printf '    %s!%s %s\n' "$YELLOW" "$RESET" "$1"; }
die()  { printf '%s✗ %s%s\n' "$RED" "$1" "$RESET" >&2; exit 1; }

usage() {
    sed -n '3,8p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
}

# --- arguments ---------------------------------------------------------------

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        -h|--help) usage ;;
        *) die "Unknown argument: $arg (see --help)" ;;
    esac
done

cd "$(git rev-parse --show-toplevel)"

BRANCH="$(git branch --show-current)"

# --- phase 1: checks (nothing is changed here) -------------------------------

step "Checking branch"
[[ -n "$BRANCH" ]] || die "Detached HEAD. Check out the branch you want to finish."
[[ "$BRANCH" != "$MAIN" ]] || die "You are on $MAIN. Check out the feature branch you want to finish."
ok "Finishing $BRANCH"

step "Checking working tree"
for marker in rebase-merge rebase-apply MERGE_HEAD CHERRY_PICK_HEAD; do
    [[ ! -e "$(git rev-parse --git-path "$marker")" ]] || die "A rebase, merge or cherry-pick is in progress. Finish or abort it first."
done
git diff --quiet || die "Unstaged changes. Commit or stash them first."
git diff --cached --quiet || die "Staged but uncommitted changes. Commit or stash them first."
[[ -z "$(git status --porcelain --untracked-files=normal)" ]] || die "Untracked files. Commit, ignore or remove them first."
ok "Clean, no operation in progress"

step "Checking $MAIN against $REMOTE"
git fetch --quiet --prune "$REMOTE"
if git rev-parse --verify --quiet "$REMOTE/$MAIN" >/dev/null; then
    local_main="$(git rev-parse "$MAIN")"
    remote_main="$(git rev-parse "$REMOTE/$MAIN")"
    if [[ "$local_main" != "$remote_main" ]]; then
        if git merge-base --is-ancestor "$MAIN" "$REMOTE/$MAIN"; then
            die "$MAIN is behind $REMOTE/$MAIN. Run: git switch $MAIN && git pull && git switch $BRANCH && git rebase $MAIN"
        else
            die "$MAIN has commits that are not on $REMOTE/$MAIN. Push or reset them before finishing a branch."
        fi
    fi
    ok "$MAIN matches $REMOTE/$MAIN"
else
    warn "$REMOTE/$MAIN does not exist yet; it will be created by the push"
fi

step "Checking that $BRANCH sits on top of $MAIN"
git merge-base --is-ancestor "$MAIN" "$BRANCH" || die "$BRANCH is not based on the latest $MAIN. Run: git rebase $MAIN"
commit_count="$(git rev-list --count "$MAIN..$BRANCH")"
[[ "$commit_count" -gt 0 ]] || die "$BRANCH has no commits that are not already on $MAIN."
ok "$commit_count commit(s) to integrate, fast-forward possible"

step "Checking commit signatures"
unsigned="$(git log --format='%G? %h %s' "$MAIN..$BRANCH" | grep -v '^G ' || true)"
[[ -z "$unsigned" ]] || die "Commits without a valid signature:
$unsigned"
ok "All commits have a good signature"

step "Checking commit emails"
expected_email="$(git config user.email)"
wrong_email="$(git log --format='%ae %ce %h %s' "$MAIN..$BRANCH" \
    | awk -v e="$expected_email" '$1 != e || $2 != e' || true)"
[[ -z "$wrong_email" ]] || die "Commits with an author or committer email other than $expected_email:
$wrong_email"
ok "All commits use $expected_email"

step "Scanning changes for secrets and IP addresses"
if command -v gitleaks >/dev/null 2>&1; then
    gitleaks_args=(git --no-banner --redact --log-opts="$MAIN..$BRANCH" .)
    if ! gitleaks "${gitleaks_args[@]}" --log-level error >/dev/null 2>&1; then
        # Run again with details (secrets stay redacted) so you can see what and where.
        gitleaks "${gitleaks_args[@]}" --verbose --log-level warn || true
        die "gitleaks found possible secrets (details above, values redacted)."
    fi
    ok "gitleaks found nothing"
else
    warn "gitleaks not installed (brew install gitleaks); only scanning for private keys and IP addresses"
fi
leaks="$(git diff "$MAIN...$BRANCH" \
    | grep -E '^\+' \
    | grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}|BEGIN [A-Z ]*PRIVATE KEY' \
    | grep -vE '127\.0\.0\.1|0\.0\.0\.0' || true)"
[[ -z "$leaks" ]] || die "Added lines contain IP addresses or private keys:
$leaks"
ok "No IP addresses or private keys in added lines"
env_files="$(git diff --name-only "$MAIN...$BRANCH" \
    | grep -E '(^|/)\.env(\..+)?$' | grep -v '\.env\.example$' || true)"
[[ -z "$env_files" ]] || die "Branch adds or changes .env files:
$env_files"
ok "No .env files in the diff"

step "Running npm run check (Biome + tsc)"
npm run --silent check >/dev/null 2>&1 \
    || die "Check failed. Run: npm run check"
ok "Biome and tsc passed"
if [[ "$(npm pkg get scripts.test)" != "{}" ]]; then
    npm test --silent >/dev/null 2>&1 \
        || die "Tests failed. Run: npm test"
    ok "Tests passed"
fi

# --- phase 2: confirm and integrate ------------------------------------------

echo
step "Commits that will land on $MAIN"
git log --format='    %h %s' "$MAIN..$BRANCH"
echo

if $DRY_RUN; then
    ok "Dry run: all checks passed, nothing was changed."
    exit 0
fi

read -r -p "Fast-forward $MAIN, push it and delete $BRANCH? [y/N] " answer
[[ "$answer" == "y" || "$answer" == "Y" ]] || die "Aborted, nothing was changed."

step "Fast-forwarding $MAIN"
git switch --quiet "$MAIN"
git merge --ff-only --quiet "$BRANCH"
ok "$MAIN is now at $(git rev-parse --short HEAD)"

step "Pushing $MAIN"
if ! git push --quiet "$REMOTE" "$MAIN"; then
    die "Push failed. $MAIN moved locally but not on $REMOTE; $BRANCH still exists.
  To undo the local fast-forward: git reset --hard $REMOTE/$MAIN && git switch $BRANCH"
fi
ok "Pushed"

step "Deleting $BRANCH"
git branch --quiet -d "$BRANCH"
ok "Deleted locally"
if git ls-remote --exit-code --heads "$REMOTE" "$BRANCH" >/dev/null 2>&1; then
    git push --quiet "$REMOTE" --delete "$BRANCH"
    ok "Deleted on $REMOTE"
fi

echo
ok "Done. You are on $MAIN."
