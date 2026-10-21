import { Text } from "ink";
import React from "react";
import type { operations } from "./api/schema.js";

export type BlockingStatus =
	operations["get_blocking"]["responses"][200]["content"]["application/json"];

export default function App({ blocking }: Readonly<{ blocking: string }>) {
	return <Text>{blocking}</Text>;
}
