# AGENTS.md

Repo-specific notes for agents. General linting/commit/branch conventions live
in the global `~/.config/opencode/AGENTS.md`; this file only covers what is
specific to this repo or easy to get wrong here.

## What this repo is

A **Docker-based GitHub Action** that lints Markdown files. Not a library/app.
Execution chain: `action.yml` (`using: docker`) -> `Dockerfile` ->
`entrypoint.sh`. The action runs `markdownlint-cli` over files discovered by
[`fd`](https://github.com/sharkdp/fd). Published to Docker Hub as
`peru/my-markdown-linter` and to the GitHub Marketplace.

Core files:

- `entrypoint.sh` - all action logic. Reads `INPUT_*` env vars (set by Action
  inputs), builds an `fd` command, pipes each result to `markdownlint`.
- `action.yml` - input definitions (`config_file`, `debug`, `exclude`,
  `fd_cmd_params`, `search_paths`). Keep in sync with `entrypoint.sh` + README.
- `Dockerfile` - `node:current-alpine`; installs `bash`, `fd`, and
  `markdownlint-cli`.
- `tests/` - fixture `*.md` files exercised by `.github/workflows/tests.yml`.

## Two linting layers (do not confuse them)

1. **The action's linter** (shipped to users): `markdownlint-cli`, version
   pinned in `Dockerfile` (`MARKDOWNLINT_CLI_VERSION`).
2. **This repo's own CI linting**: **MegaLinter**, which uses **`rumdl`** for
   Markdown. `MARKDOWN_MARKDOWNLINT` is disabled in `.mega-linter.yml`.
   So repo Markdown is checked by rumdl (`.rumdl.toml`), not markdownlint.

The README documents `.markdownlint.yaml` as the action's default config; there
is no such file in this repo (users supply their own).

## CI gotchas

- **README bash blocks are executed.**
  `.github/workflows/readme-commands-check.yml`
  extracts every ```` ```bash ```` block from `README.md` and runs it with
  `bash -euxo pipefail`. Any bash fence in the README must actually run clean.
- **MegaLinter runs only on non-`main` branches** and is skipped for
  `chore/renovate/*` and `release-please--*` branches (see `mega-linter.yml`).
  To get a full lint pass, push to a feature branch and open a PR.
- **`tests.yml` / `docker-image.yml` are path-filtered**: they trigger only when
  `Dockerfile`, `entrypoint.sh`, `.dockerignore`, `tests/**`, or the workflow
  itself changes.
- **`docker-image` and `readme-commands-check` run on both `ubuntu-latest` and
  `ubuntu-24.04-arm`** - keep commands/image arch-agnostic.
- `MARKDOWNLINT_CLI_VERSION` in `Dockerfile` is **Renovate-managed** (has a
  `# renovate:` comment). Do not bump it manually.

## Test fixtures

`tests/test-bad-mdfile/bad.md` is intentionally broken and **must stay failing**
for markdownlint - it proves the action detects errors. CI never runs the action
over it directly (it is always excluded); the demo and tests show it being
excluded. Its `<!-- markdownlint-disable -->` only neutralizes rumdl so it does
not break this repo's own MegaLinter run. Do not "fix" this file.

## Releases

Automated via **release-please** (`release-type: simple`, driven by Conventional
Commits on `main`). On release it force-pushes/moves the `v<major>` and
`v<major>.<minor>` tags. Do not hand-edit `CHANGELOG.md` or create version tags
manually. `CHANGELOG.md` is generated and is excluded from nearly every linter.

## Conventions easy to miss

- `keep-sorted` blocks (`.mega-linter.yml`, `.github/workflows/stale.yml`) must
  stay alphabetically sorted between the `keep-sorted start/end` markers.
- Commit subjects here allow lowercase (`CCHK_SUBJECT_CAPITALIZED: false`) and
  must be <= 72 chars; branch names must follow Conventional Branch
  (`feature/`, `bugfix/`, ...).
- Shell scripts use `set -Eeuo pipefail` and the `print_info`/`print_error`/
  `error_trap` helpers in `entrypoint.sh`; match that style.
