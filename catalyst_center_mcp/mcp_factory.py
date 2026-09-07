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

"""Shared FastMCP construction for main and LocalMCP entrypoints."""

from __future__ import annotations

import logging

from fastmcp import FastMCP

from catalyst_center_mcp.config import get_settings
from catalyst_center_mcp.tool_loader import load_tools
from catalyst_center_mcp.tool_registry import register_tools

logger = logging.getLogger(__name__)


def create_mcp() -> FastMCP:
    mcp = FastMCP("catalyst-center-mcp")
    settings = get_settings()
    tools_root = settings.bundled_tools_dir
    tools = load_tools(tools_root)
    count = register_tools(mcp, tools)
    logger.info("Registered %s bundled Catalyst Center tools", count)
    return mcp
