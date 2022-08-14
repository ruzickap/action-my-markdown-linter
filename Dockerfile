FROM node:current-alpine

LABEL maintainer="Petr Ruzicka <petr.ruzicka@gmail.com>"
LABEL repository="https://github.com/ruzickap/action-my-markdown-linter"
LABEL homepage="https://github.com/ruzickap/action-my-markdown-linter"

LABEL "com.github.actions.name"="My Markdown Linter"
LABEL "com.github.actions.description"="Lint Markdown files"
LABEL "com.github.actions.icon"="list"
LABEL "com.github.actions.color"="blue"

# renovate: datasource=npm depName=markdownlint-cli versioning=npm
ENV MARKDOWNLINT_CLI_VERSION="0.32.1"

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN set -eux && \
    apk --update --no-cache add bash fd && \
    npm install --global --production "markdownlint-cli@v${MARKDOWNLINT_CLI_VERSION}"

COPY entrypoint.sh /entrypoint.sh

WORKDIR /mnt
ENTRYPOINT [ "/entrypoint.sh" ]
