import "dotenv/config";
import { login } from "../source/api/auth.js";
import { apiGet } from "../source/api/request.js";

const sid = await login(
	process.env["API_URL"]!,
	process.env["PIHOLE_PASSWORD"]!,
);
console.log(`Logged in. Got a SID with ${sid.length} characters.`);

const blocking = await apiGet(process.env["API_URL"]!, sid, "/dns/blocking");
console.log(blocking);
