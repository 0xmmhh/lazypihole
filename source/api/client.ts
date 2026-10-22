import { login } from "./auth.js";
import { apiGet } from "./request.js";

export function createClient(baseUrl: string, password: string) {
	let sid: string | null = null;

	async function get(path: string): Promise<unknown> {
		if (sid === null) {
			sid = await login(baseUrl, password);
		}
		return apiGet(baseUrl, sid, path);
	}
	return { get };
}
