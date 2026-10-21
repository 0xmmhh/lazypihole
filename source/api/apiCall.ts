import axios from "axios";

const token = process.env["SID"];

export const api = axios.create({
	baseURL: process.env["API_URL"],
	headers: {
		"Content-Type": "application/json",
		"X-FTL-SID": token,
	},
	timeout: 10000,
});
