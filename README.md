# Catalyst Center MCP Open Source

[![Maintainer](https://img.shields.io/badge/Maintainer-Cisco-00bceb.svg)](https://opensource.cisco.com)

## About The Project

This repository contains open source code for the Catalyst Center Open Source MCP Server.
Each version of Catalyst Center <M.N.P.Q> will have an accompanying branch within this
repository (release/<M.N.P.Q>) containing the corresponding MCP Server.

Each MCP server exposes as tools many of the functions exposed as read apis exposed by
the Catalyst Center.   The context for each tool incorporates the documentation of the
api endpoint as well as, in some cases, additional context that Cisco believes improves
the usability of the tool by AI Agents.

Important: The `main` branch of this repository does not include any MCP server code.
Please reference the appropriate release branch based on your Catalyst Center version.

### Runtime Experience

Let's start with where you will end.  Once you have the MCP Server running, you can configure
your AI Agent of choice with this mcp server.  Responses are limited by the public apis
from the Catalyst Center integrated to present information.

Here's an example of a brief interaction via an AI Agent:
```
❯ list my sites

⏺ I'll help you list your sites. Let me load the necessary tool to retrieve sites from
  Catalyst Center.

⏺ Now I'll retrieve your sites from Catalyst Center.

  Called catc (ctrl+o to expand)

⏺ Here are your sites in Catalyst Center:

  Site Hierarchy

  Global (Root)
  - CO (Colorado)
    - ENGL (Englewood) - 9155 East Nichols Avenue, Centennial, CO 80112
        - Floor-5
  - France
    - Paris - 17 Avenue Jules Rimet, 93200 Saint-Denis, France
  - NY (New York)
    - NYC (New York City) - 1 Pennsylvania Plaza, New York, NY 10001
        - Floor-8
  - OR (Oregon)
    - BEAV (Beaverton) - 1600 NW Compton Drive, Beaverton, OR 97006
        - Main
    - LO (Lake Oswego) - 5400 Meadows Rd, Lake Oswego, OR 97035
        - Floor-3
    - PDX (Portland) - 1600 NE Compton Drive, Hillsboro, OR 97006
        - Floor-2
  - SF (San Francisco)
    - SFO - 500 Terry a. François Boulevard, San Francisco, CA 94158
        - Net plat

  Summary: 19 total sites (1 global, 5 areas, 6 buildings, 7 floors)
```

## Getting Started

To get a local copy up and running follow these simple steps.

### Prerequisites

- Docker Build and Runtime Environment (Recommended)
- Python - see [pyproject.toml](pyproject.toml) (Optional if Docker is not available)

### Installation

Clone the repository.  It's fully self-contained.

```sh
git clone https://github.com/cisco-en-programmability/catc-mcp-oss
```

## Usage

### Environment (Required)

Set the Catalyst Center target through environment variables:

```bash
export CATALYST_CENTER_HOST=10.10.10.10
export CATALYST_CENTER_USERNAME=admin
export CATALYST_CENTER_PASSWORD='...'
export CATALYST_CENTER_VERIFY_SSL=false
```

Note: Relevant only when using https, setting CATALYST_CENTER_VERIFY_SSL to
false is not a recommended practice.  We recommend ensuring that the docker
build is modified to allow trust store maintenance and management over time
to allow the use of trusted certificates.  However, this is currently set to
false to allow use of certificates that are not part of a trusted chain; often
the case with self-signed certificates.

### STDIO

Use STDIO when your MCP client launches and communicates with the server as a
child process.

```bash
docker build -t catalyst-center-mcp:local .
docker run --rm -i \
  -e CATALYST_CENTER_HOST \
  -e CATALYST_CENTER_USERNAME \
  -e CATALYST_CENTER_PASSWORD \
  -e CATALYST_CENTER_VERIFY_SSL \
  catalyst-center-mcp:local \
  fastmcp run catalyst_center_mcp/main.py:mcp --transport stdio
```

Use `-i` so stdin remains attached. Do not publish ports for STDIO mode.

An MCP client can launch the Docker-backed STDIO server with a configuration
like this:

```json
{
  "mcpServers": {
    "catalyst-center-mcp": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "-e", "CATALYST_CENTER_HOST",
        "-e", "CATALYST_CENTER_USERNAME",
        "-e", "CATALYST_CENTER_PASSWORD",
        "-e", "CATALYST_CENTER_VERIFY_SSL",
        "catalyst-center-mcp:local",
        "fastmcp",
        "run",
        "catalyst_center_mcp/main.py:mcp",
        "--transport",
        "stdio"
      ],
      "env": {
        "CATALYST_CENTER_HOST": "10.10.10.10",
        "CATALYST_CENTER_USERNAME": "admin",
        "CATALYST_CENTER_PASSWORD": "...",
        "CATALYST_CENTER_VERIFY_SSL": "false"
      }
    }
  }
}
```

If Docker is not available, run the same transport directly with Python:

```bash
pip install -e '.[test]'
fastmcp run catalyst_center_mcp/main.py:mcp --transport stdio
```

For a direct Python STDIO launch, use a configuration like this:

```json
{
  "mcpServers": {
    "catalyst-center-mcp": {
      "command": "fastmcp",
      "args": [
        "run",
        "/path/to/catc-mcp-oss/catalyst_center_mcp/main.py:mcp",
        "--transport",
        "stdio"
      ],
      "cwd": "/path/to/catc-mcp-oss",
      "env": {
        "CATALYST_CENTER_HOST": "10.10.10.10",
        "CATALYST_CENTER_USERNAME": "admin",
        "CATALYST_CENTER_PASSWORD": "...",
        "CATALYST_CENTER_VERIFY_SSL": "false"
      }
    }
  }
}
```

### HTTP(S)

HTTPS is recommended when exposing the MCP server over the network. For
enterprise deployments, prefer terminating TLS outside this container using the
organization's standard ingress, reverse proxy, service mesh, API gateway, or
load balancer. Use centrally managed certificates, rotation, policy enforcement,
and audit controls there, while keeping this container on its default internal
HTTP listener unless direct TLS termination in the container is explicitly
required.

For direct container TLS termination, mount the certificate and key read-only and
pass Uvicorn SSL options. If you need a local development certificate, see
[Appendix: Generating SSL Certificates](#appendix-generating-ssl-certificates).

```bash
docker build -t catalyst-center-mcp:local .
docker run --rm -p 7001:7001 \
  -v "$PWD/certs:/certs:ro" \
  -e CATALYST_CENTER_HOST \
  -e CATALYST_CENTER_USERNAME \
  -e CATALYST_CENTER_PASSWORD \
  -e CATALYST_CENTER_VERIFY_SSL \
  catalyst-center-mcp:local \
  python3 -m uvicorn catalyst_center_mcp.main:app \
    --host 0.0.0.0 \
    --port 7001 \
    --ssl-keyfile /certs/localhost-key.pem \
    --ssl-certfile /certs/localhost-cert.pem
```

If SSL is not required, such as when TLS is terminated by external
infrastructure or for local-only testing, run the default HTTP listener. The
image's default command already starts Uvicorn with `--host 0.0.0.0 --port
7001`:

```bash
docker run --rm -p 7001:7001 \
  -e CATALYST_CENTER_HOST \
  -e CATALYST_CENTER_USERNAME \
  -e CATALYST_CENTER_PASSWORD \
  -e CATALYST_CENTER_VERIFY_SSL \
  catalyst-center-mcp:local
```

If Docker is not available, run Uvicorn directly. Add the `--ssl-keyfile` and
`--ssl-certfile` options shown above when direct HTTPS is required.

```bash
pip install -e '.[test]'
uvicorn catalyst_center_mcp.main:app --host 0.0.0.0 --port 7001
```

The streamable HTTP(S) MCP endpoint is mounted at:

```text
http(s)://localhost:7001/v1/mcp
```

Health endpoints:

```text
GET http(s)://localhost:7001/v1/health
GET http(s)://localhost:7001/v1/readiness
```

When the HTTP(S) server is already running, configure MCP clients with the server
URL. The Catalyst Center environment variables belong to the server process or
container, not the MCP client.

```json
{
  "mcpServers": {
    "catalyst-center-mcp": {
      "url": "http://localhost:7001/v1/mcp"
    }
  }
}
```

For direct HTTPS, use:

```json
{
  "mcpServers": {
    "catalyst-center-mcp": {
      "url": "https://localhost:7001/v1/mcp"
    }
  }
}
```

For enterprise TLS termination, point clients at the externally managed
endpoint:

```json
{
  "mcpServers": {
    "catalyst-center-mcp": {
      "url": "https://catc-mcp.example.com/v1/mcp"
    }
  }
}
```

## Appendix: Generating SSL Certificates

For local development or test environments, you can generate a self-signed
certificate with OpenSSL:

```bash
mkdir -p certs
openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout certs/localhost-key.pem \
  -out certs/localhost-cert.pem \
  -days 365 \
  -subj "/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"
```

This creates the certificate and key expected by the direct HTTPS Docker example:

```text
certs/localhost-cert.pem
certs/localhost-key.pem
```

Use enterprise-managed certificates for shared, production, or externally
reachable deployments.

## Contributing

Please see [CONTRIBUTING.md](CONTRIBUTING.md)

## License

Distributed under the Apache License. See [LICENSE.md](LICENSE.md) for more
information.

## Contact

Please see [MAINTAINERS.md](MAINTAINERS.md)

Project Link:
[Catalyst Center MCP Open Source](https://github.com/cisco-en-programmability/catc-mcp-oss)

## Acknowledgements

This project is based on work done by:
* The Catalyst Center API Program.
* The Network Platform Group AI Assistant Program for Catalyst Center.
