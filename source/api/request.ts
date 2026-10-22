export async function apiGet(
	baseUrl: string,
	sid: string,
	path: string,
): Promise<unknown> {
	const response = await fetch(`${baseUrl}${path}`, {
		headers: { "X-FTL-SID": sid },
	});

	if (!response.ok) {
		throw new Error(`GET ${path} failed (HTTP ${response.status})`);
	}

	return response.json();
}
