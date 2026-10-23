import { Box } from "ink";
import React from "react";

type Props = {
	focused?: boolean;
	children: React.ReactNode;
};

export function Panel({ focused = false, children }: Props) {
	return (
		<Box
			flexGrow={1}
			flexBasis={0}
			borderStyle="round"
			borderColor={focused ? "green" : "gray"}
			paddingX={1}
		>
			{children}
		</Box>
	);
}
