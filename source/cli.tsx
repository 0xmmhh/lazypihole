#!/usr/bin/env node
import "dotenv/config";
import { render } from "ink";
import React from "react";
import App from "./app.js";

const enterAltScreen = "\x1b[?1049h";
const leaveAltScreen = "\x1b[?1049l";

process.stdout.write(enterAltScreen);
try {
	const { waitUntilExit } = render(<App />);
	await waitUntilExit();
} finally {
	process.stdout.write(leaveAltScreen);
}
