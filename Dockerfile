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

# Shared hardened NCP base (see deploy-ones/dockerfiles/ncp-python-base-312-alpine).
# All dependencies (fastmcp, fastapi, uvicorn[standard], httpx, ...) ship musllinux
# wheels; Alpine drops the Debian OS findings that python:3.14-slim carried.
ARG PYTHON_BASE=avizdock/ncp-python-base-312-alpine:latest
# Runtime stage: plain upstream python:3.12-alpine -- the same Alpine release and
# CPython the shared base is built FROM, but without its build toolchain, so the
# image does not carry ~450 MB of gcc/binutils/git layers underneath. Override
# with a lean shared runtime base once deploy-ones provides one.
ARG PYTHON_RUNTIME_BASE=python:3.12-alpine

# --- builder: install the package into a self-contained venv ---
FROM ${PYTHON_BASE} AS builder

WORKDIR /app

COPY pyproject.toml README.md ./
COPY catalyst_center_mcp ./catalyst_center_mcp

RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir . \
    && /opt/venv/bin/pip uninstall -y pip setuptools wheel

# --- runtime: lean upstream alpine (PYTHON_RUNTIME_BASE), no toolchain or pip ---
FROM ${PYTHON_RUNTIME_BASE}

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PATH="/opt/venv/bin:${PATH}"

# Build toolchain, packaging tools: if PYTHON_RUNTIME_BASE is the shared alpine base it
# carries build-base/git/curl/*-dev, and every base carries pip/setuptools/wheel
# for building; none are needed at runtime, and they are the bulk of the image's
# HIGH findings (binutils, pip's vendored msgpack/setuptools).
RUN pkgs="$(apk info -e build-base libffi-dev openssl-dev git curl || true)" \
    && if [ -n "$pkgs" ]; then apk del --no-cache $pkgs; fi \
    && apk upgrade --no-cache \
    && (python -m pip uninstall -y setuptools wheel pip || true)

USER root
WORKDIR /app

COPY --from=builder /opt/venv /opt/venv
COPY pyproject.toml README.md ./
COPY catalyst_center_mcp ./catalyst_center_mcp
COPY scripts ./scripts

EXPOSE 7001 8001

CMD ["python3", "-m", "uvicorn", "catalyst_center_mcp.main:app", "--host", "0.0.0.0", "--port", "7001"]
