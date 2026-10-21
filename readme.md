# lazypihole

A terminal UI for Pi-hole. Check your stats, toggle blocking and manage your lists without opening a browser.

<!-- TODO: demo GIF -->

> **Status:** early development. Most features below are planned, not built yet.

## Table of contents

- [Elevator pitch](#elevator-pitch)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Keybindings](#keybindings)
- [Contributing](#contributing)
- [FAQ](#faq)
- [Alternatives](#alternatives)
- [License](#license)

## Elevator pitch

A website breaks, and you suspect Pi-hole. You open the web dashboard, log in, look through the query log for the domain, add it to the allowlist, then reload the site to check. It's the same few clicks every time, in a browser tab you didn't want to open.

lazypihole puts the things you do most often one keypress away in your terminal, the same idea as lazygit for Git and lazydocker for Docker.

## Features

Planned:

- [ ] **Dashboard:** total queries, blocked percentage, top domains and clients
- [ ] **Blocking toggle:** turn blocking on or off, with an optional timer ("disable for 5 minutes")
- [ ] **Live query log:** follow queries as they come in, with filtering by domain or client
- [ ] **Quick allow / block:** add the selected domain to the allowlist or denylist straight from the query log
- [ ] **List management:** browse and edit domains and adlists
- [ ] **Gravity update:** rebuild the blocklists and watch the progress
- [ ] **Login:** sign in with your password; the session is refreshed automatically

## Requirements

- Pi-hole **v6** or newer (lazypihole uses the v6 REST API)
- Node.js (a current LTS release)

## Installation

### From source

```bash
git clone <repo-url>
cd lazypihole
npm install
npm run build
npm link        # makes the `lazypihole` command available globally
```

<!-- TODO: npm package once published -->

## Configuration

Create a `.env` file in the project root:

```env
API_URL=http://pi.hole/api
SID=<your session id>
```

| Variable  | Description                                         |
| --------- | --------------------------------------------------- |
| `API_URL` | Base URL of your Pi-hole API                        |
| `SID`     | Session ID; will be replaced by password login later |

Never commit `.env`. It's already listed in `.gitignore`.

## Usage

```bash
lazypihole
```

During development, run it without building:

```bash
npm run dev
```

## Keybindings

<!-- TODO: fill in as features are built -->

| Key | Action |
| --- | ------ |
| `q` | Quit   |

## Contributing

Issues and pull requests are welcome. Before you open a PR, run:

```bash
npm run check   # Biome lint + TypeScript type check
```

## FAQ

**Does it work with Pi-hole v5?**
No. v5 used a different API. lazypihole targets the v6 REST API only.

**Do I need a server or backend?**
No. lazypihole talks directly to the API your Pi-hole already exposes.

## Alternatives

- **Pi-hole web interface:** the built-in dashboard, with every feature available
- **`pihole` CLI:** the official command-line tool, run on the Pi itself
- **PADD:** a status display for Pi-hole, aimed at small screens

## License

MIT
