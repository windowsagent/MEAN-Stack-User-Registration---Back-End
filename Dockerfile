ARG VERSION=lts
ARG BUILDER=docker.io/library/node
FROM ${BUILDER}:${VERSION}-slim AS base
RUN corepack enable

FROM base AS deps
WORKDIR /app
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* bun.lockb* ./
ARG INSTALL_CMD="npm ci"
ARG NPM_MIRROR=
RUN if [ ! -z "${NPM_MIRROR}" ]; then npm config set registry ${NPM_MIRROR}; fi
RUN if [ ! -z "${INSTALL_CMD}" ]; then echo "${INSTALL_CMD}" > dep.sh; sh dep.sh; fi

FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules* ./node_modules
COPY . .
ARG BUILD_CMD=
RUN if [ ! -z "${BUILD_CMD}" ]; then sh -c "$BUILD_CMD"; fi

FROM base AS runtime
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends wget ca-certificates && apt-get clean && rm -f /var/lib/apt/lists/*_*
RUN update-ca-certificates 2>/dev/null || true
RUN addgroup --system nonroot && adduser --disabled-login --ingroup nonroot nonroot
ENV COREPACK_HOME=/app/.cache
RUN mkdir -p /app/.cache
RUN chown -R nonroot:nonroot /app

COPY --chown=nonroot:nonroot --from=builder /app .

USER nonroot:nonroot

ARG START_CMD="node app.js"
ENV START_CMD=${START_CMD}
RUN if [ -z "${START_CMD}" ]; then echo "Unable to detect a container start command" && exit 1; fi
CMD ${START_CMD}