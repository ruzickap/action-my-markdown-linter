FROM node:current-alpine@sha256:72a53f6b6299d2214b8c4857369644ac0c44aec3f1b1b346e05ab95eaab8393d

LABEL maintainer="Petr Ruzicka <petr.ruzicka@gmail.com>"
LABEL repository="https://github.com/ruzickap/action-my-markdown-linter"
LABEL homepage="https://github.com/ruzickap/action-my-markdown-linter"

LABEL "com.github.actions.name"="My Markdown Linter"
LABEL "com.github.actions.description"="Lint Markdown files"
LABEL "com.github.actions.icon"="list"
LABEL "com.github.actions.color"="blue"

# renovate: datasource=npm depName=markdownlint-cli versioning=npm
ENV MARKDOWNLINT_CLI_VERSION="0.39.0"

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# kics-scan ignore-block
RUN set -eux && \
    apk --update --no-cache add bash fd && \
    npm install --global --production "markdownlint-cli@v${MARKDOWNLINT_CLI_VERSION}"

COPY entrypoint.sh /entrypoint.sh

USER nobody

WORKDIR /mnt

HEALTHCHECK NONE

ENTRYPOINT [ "/entrypoint.sh" ]
