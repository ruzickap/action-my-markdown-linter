FROM node:current-alpine@sha256:49e45bf002728e35c3a466737d8bcfe12c29731c7c2f3e223f9a7c794fff19a4

LABEL maintainer="Petr Ruzicka <petr.ruzicka@gmail.com>"
LABEL repository="https://github.com/ruzickap/action-my-markdown-linter"
LABEL homepage="https://github.com/ruzickap/action-my-markdown-linter"

LABEL "com.github.actions.name"="My Markdown Linter"
LABEL "com.github.actions.description"="Lint Markdown files"
LABEL "com.github.actions.icon"="list"
LABEL "com.github.actions.color"="blue"

# renovate: datasource=npm depName=markdownlint-cli versioning=npm
ENV MARKDOWNLINT_CLI_VERSION="0.45.0"

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
