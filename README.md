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

Note: Setting CATALYST_CENTER_VERIFY_SSL to false is not a recommended practice.
We recommend ensuring that the docker build is modified to allow trust store
maintenance and mangement over time to allow the use of trusted certificates.
If using any certificate that is not part of a trusted chain, often the case with
self-signed certificates, this must be set to false.

### Docker Execution (Recommended)

```bash
docker build -t catalyst-center-mcp:local .
docker run --rm -p 7001:7001 \
  -e CATALYST_CENTER_HOST \
  -e CATALYST_CENTER_USERNAME \
  -e CATALYST_CENTER_PASSWORD \
  -e CATALYST_CENTER_VERIFY_SSL \
  catalyst-center-mcp:local
```

### Python Based Execution (Alternative)

```bash
pip install -e '.[test]'
uvicorn catalyst_center_mcp.main:app --host 0.0.0.0 --port 7001
```

### Runtime Experience

The streamable HTTP MCP endpoint is mounted at:

```text
http://localhost:7001/v1/mcp
```

Health endpoints:

```text
GET /v1/health
GET /v1/readiness
```

Once you have the MCP Server running, you can configure your AI Agent of choice with this 
endpoint.  Responses are limited only by the public apis available for Catalyst Center to 
present information. 

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