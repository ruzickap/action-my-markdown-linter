# AI Agent Guidelines

## Project Overview

Docker-based GitHub Action (`action-my-markdown-linter`) that lints
Markdown files using `markdownlint-cli` and `fd`. The core logic is a
single Bash script (`entrypoint.sh`) packaged in an Alpine Docker image.

## Build and Test Commands

### Build

```bash
docker build . --file Dockerfile
```

No compilation step; the Dockerfile installs `markdownlint-cli`
via npm and copies `entrypoint.sh` into the image.

### Test

Tests are integration tests in `.github/workflows/tests.yml`
exercising the Docker action end-to-end. To run locally:

```bash
docker build -t action-my-markdown-linter .

# Single test: lint tests/test2 only
docker run --rm -t \
  -e INPUT_SEARCH_PATHS="tests/test2" \
  -e INPUT_DEBUG="true" \
  -v "${PWD}:/mnt" action-my-markdown-linter

# With exclude patterns
docker run --rm -t \
  -e INPUT_EXCLUDE="CHANGELOG.md test1/excluded_file.md bad.md excluded_dir/" \
  -e INPUT_SEARCH_PATHS="tests/" \
  -v "${PWD}:/mnt" action-my-markdown-linter

# With custom fd parameters
docker run --rm -t \
  -e INPUT_FD_CMD_PARAMS=". -0 --extension md --type f --hidden --no-ignore --exclude CHANGELOG.md tests/" \
  -v "${PWD}:/mnt" action-my-markdown-linter
```

No unit test framework. Each test maps to a CI workflow step.

### Lint

Linting runs via MegaLinter (`.mega-linter.yml`). Key checks:

```bash
shellcheck --exclude=SC2317 entrypoint.sh
shfmt --case-indent --indent 2 --space-redirects -d entrypoint.sh
rumdl README.md
lychee --config lychee.toml .
jsonlint --comments .github/renovate.json5
actionlint
checkov --quiet --skip-check CKV_GHA_7 -d .
trivy fs --severity HIGH,CRITICAL --ignore-unfixed .
```

## Shell Script Style (`entrypoint.sh`)

- **Shebang**: `#!/usr/bin/env bash`
- **Strict mode**: `set -Eeuo pipefail` (always)
- **Indentation**: 2 spaces, no tabs
- **Variables**: UPPERCASE with braces: `${MY_VARIABLE}`
- **Defaults**: `${INPUT_VAR:-}` for empty, `${INPUT_VAR:-default}`
- **Functions**: `name() { ... }` syntax
- **Error handling**: `trap error_trap ERR` for centralized handling
- **Arrays**: `declare -a` with `+=` for appending
- **Null-delimited I/O**: `fd -0` piped to `read -r -d ''`
- **Section headers**: `####` comment blocks
- **shellcheck directives**: Inline `# shellcheck disable=SCXXXX`
  with justification; SC2317 globally excluded

Format with: `shfmt --case-indent --indent 2 --space-redirects`

## Markdown Style

- Wrap lines at **72 characters** (configured in `.rumdl.toml`)
- Use proper heading hierarchy (no skipped levels)
- Always include language identifiers in code fences
- Prefer code fences over inline code for multi-line examples
- Validate with `rumdl` (not `markdownlint` in CI for this repo)
- Bash code blocks are extracted and validated with `shellcheck`
  and `shfmt` during CI

## YAML Style (GitHub Actions Workflows)

- Start with `---` document marker (recommended)
- Include header comment describing the workflow purpose
- Set `permissions: read-all` at workflow level; scope per-job
- Pin all actions to **full SHA** with version comment:
  `uses: actions/checkout@<sha> # v6.0.2`
- Set `timeout-minutes` on every job (typically 5-10)
- Use `# keep-sorted start` / `# keep-sorted end` for sorted
  blocks
- Validate changes with `actionlint`

## JSON Files

- Must pass `jsonlint --comments` validation
- JSON5 (`.json5`) used for Renovate config with `//` comments

## Security Scanning

CI runs multiple scanners. Be aware when modifying files:

- **Checkov**: Skips `CKV_GHA_7` (workflow_dispatch inputs)
- **DevSkim**: Ignores DS162092 (debug code), DS137138
- **KICS**: Fails only on HIGH severity; use
  `# kics-scan ignore-line` to suppress known issues
- **Trivy**: HIGH/CRITICAL only, ignores unfixed vulnerabilities
- **CodeQL**: Targets GitHub Actions language

## Version Control

### Commit Messages

Conventional commit format: `<type>: <description>`

Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`,
`style`, `perf`, `ci`, `build`, `revert`

Subject: imperative mood, lowercase, no trailing period,
max 72 characters. Body: optional; wrap at 72 chars; explain
what and why. Reference issues with `Fixes`/`Closes`/`Resolves`.

### Branching

Conventional Branch format: `<type>/<description>`
(`feature/`, `bugfix/`, `hotfix/`, `release/`, `chore/`).
Use lowercase and hyphens. Include issue numbers when
applicable: `feature/issue-42-add-export`.

### Pull Requests

- Always create as **draft** initially
- Title must follow conventional commit format
- Link related issues with `Fixes`, `Closes`, `Resolves`

## General Quality Rules

- Two spaces for indentation everywhere (shell, YAML, Markdown)
- No tabs; pass all pre-commit hooks before committing
- Make atomic, focused commits
- Update documentation for user-facing changes
- Keep `CHANGELOG.md` untouched (managed by release-please)
