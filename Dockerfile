FROM node:current-alpine

LABEL maintainer="Petr Ruzicka <petr.ruzicka@gmail.com>"
LABEL repository="https://github.com/ruzickap/action-my-markdown-linter"
LABEL homepage="https://github.com/ruzickap/action-my-markdown-linter"

LABEL "com.github.actions.name"="My Markdown linter"
LABEL "com.github.actions.description"="Lint Markdown files"
LABEL "com.github.actions.icon"="list"
LABEL "com.github.actions.color"="blue"

ENV MARKDOWNLINT-CLI_VERSION="0.23.2"

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN set -eux && \
    apk --update --no-cache add bash curl fd jq && \
    if [ -z "${MARKDOWNLINT-CLI_VERSION+x}" ] ; then \
      npm install --global --production "markdownlint-cli@${MARKDOWNLINT-CLI_VERSION}" ; \
    else \
      npm install --global --production markdownlint-cli ; \
    fi

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
