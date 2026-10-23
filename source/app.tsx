import { Box, Text, useApp, useInput, useStdout } from "ink";
import React from "react";
import { BlockingStatus } from "./components/BlockingStatus.js";
import { Panel } from "./components/Panel.js";

export default function App() {
	const { exit } = useApp();
	const { stdout } = useStdout();

	useInput((input) => {
		if (input === "q") {
			exit();
		}
	});

	return (
		<Box width={stdout.columns} height={stdout.rows - 1} flexDirection="column">
			<Box flexGrow={1} flexBasis={0}>
				<Panel focused>
					<BlockingStatus blocking="enabled" />
				</Panel>
				<Panel>
					<Text>Query log</Text>
				</Panel>
			</Box>
			<Box flexGrow={1} flexBasis={0}>
				<Panel>
					<Text>Top blocked</Text>
				</Panel>
				<Panel>
					<Text>Top clients</Text>
				</Panel>
			</Box>
		</Box>
	);
}
