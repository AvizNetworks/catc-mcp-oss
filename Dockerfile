FROM containers.cisco.com/mre/jenkinsnode:node20nodocker

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PATH="/home/jenkins/.local/bin:${PATH}"

USER root
WORKDIR /app

COPY pyproject.toml README.md ./
COPY catalyst_center_mcp ./catalyst_center_mcp
COPY scripts ./scripts

RUN python3 -m pip install --break-system-packages --no-cache-dir .

EXPOSE 7001

USER jenkins
CMD ["python3", "-m", "uvicorn", "catalyst_center_mcp.main:app", "--host", "0.0.0.0", "--port", "7001"]
