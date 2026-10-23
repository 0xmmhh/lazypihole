import { Text } from "ink";
import React from "react";

type Props = {
	blocking: "enabled" | "disabled" | "failed" | "unknown";
};

export function BlockingStatus({ blocking }: Props) {
	const color = blocking === "enabled" ? "green" : "red";

	return (
		<Text>
			Blocking: <Text color={color}>{blocking.toUpperCase()}</Text>
		</Text>
	);
}
