import "dotenv/config";
import { createClient } from "../source/api/client.js";

const client = createClient(
	process.env["API_URL"]!,
	process.env["PIHOLE_PASSWORD"]!,
);

console.log(await client.get("/dns/blocking")); // logs in, then requests
console.log(await client.get("/dns/blocking")); // reuses the same SID, no login
