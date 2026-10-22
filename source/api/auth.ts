export async function login(
	baseUrl: string,
	password: string,
): Promise<string> {
	const response = await fetch(`${baseUrl}/auth`, {
		method: "POST",
		headers: { "Content-Type": "application/json" },
		body: JSON.stringify({ password }),
	});

	if (!response.ok) {
		throw new Error(`Login failed (HTTP ${response.status})`);
	}

	const data = await response.json();
	return data.session.sid;
}
