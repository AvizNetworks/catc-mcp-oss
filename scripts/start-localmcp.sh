#!/bin/sh
# NCP LocalMCP entrypoint. SSE on :8001 for aviz-shared-network.
# Does not touch the Kafka API collector path.
set -eu

export LOCAL_MCP_MODE="${LOCAL_MCP_MODE:-true}"
export MCP_TRANSPORT="${MCP_TRANSPORT:-sse}"
export MCP_SERVER_PORT="${MCP_SERVER_PORT:-8001}"

echo "LocalMCP: starting catalyst-center-mcp on 0.0.0.0:${MCP_SERVER_PORT} (${MCP_TRANSPORT})"
exec python3 -m uvicorn catalyst_center_mcp.localmcp:app \
  --host 0.0.0.0 \
  --port "${MCP_SERVER_PORT}"
