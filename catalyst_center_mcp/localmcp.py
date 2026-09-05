# Copyright 2026 Cisco Systems, Inc. and its affiliates
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

"""NCP LocalMCP SSE entrypoint (port 8001, /mcp/sse)."""

from __future__ import annotations

import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI

from catalyst_center_mcp.config import SettingsError, get_settings
from catalyst_center_mcp.main import create_mcp

logger = logging.getLogger(__name__)

mcp = create_mcp()
mcp_app = mcp.http_app(path="/mcp/sse", transport="sse")


@asynccontextmanager
async def lifespan(app: FastAPI):
    try:
        get_settings().validate_credentials()
    except SettingsError as exc:
        logger.warning("Catalyst Center credentials are not fully configured: %s", exc)
    async with mcp_app.lifespan(app):
        yield


app = FastAPI(
    title="Catalyst Center MCP (LocalMCP)",
    version="0.1.0",
    lifespan=lifespan,
)
app.mount("", mcp_app)


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok", "transport": "sse"}
