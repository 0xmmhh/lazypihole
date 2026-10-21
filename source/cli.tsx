#!/usr/bin/env node
import "dotenv/config";
import { render } from "ink";
import React from "react";
import { api } from "./api/apiCall.js";
import App, { type BlockingStatus } from "./app.js";

const { data } = await api.get<BlockingStatus>("/dns/blocking");
render(<App blocking={data?.blocking ?? "unknown"} />);
