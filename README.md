# GitHub Actions: My Markdown Linter ✔

[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-My%20Markdown%20Linter-blue.svg?colorA=24292e&colorB=0366d6&style=flat&longCache=true&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAM6wAADOsB5dZE0gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAERSURBVCiRhZG/SsMxFEZPfsVJ61jbxaF0cRQRcRJ9hlYn30IHN/+9iquDCOIsblIrOjqKgy5aKoJQj4O3EEtbPwhJbr6Te28CmdSKeqzeqr0YbfVIrTBKakvtOl5dtTkK+v4HfA9PEyBFCY9AGVgCBLaBp1jPAyfAJ/AAdIEG0dNAiyP7+K1qIfMdonZic6+WJoBJvQlvuwDqcXadUuqPA1NKAlexbRTAIMvMOCjTbMwl1LtI/6KWJ5Q6rT6Ht1MA58AX8Apcqqt5r2qhrgAXQC3CZ6i1+KMd9TRu3MvA3aH/fFPnBodb6oe6HM8+lYHrGdRXW8M9bMZtPXUji69lmf5Cmamq7quNLFZXD9Rq7v0Bpc1o/tp0fisAAAAASUVORK5CYII=)](https://github.com/marketplace/actions/my-markdown-linter)
[![license](https://img.shields.io/github/license/ruzickap/action-my-markdown-linter.svg)](https://github.com/ruzickap/action-my-markdown-linter/blob/master/LICENSE)
[![release](https://img.shields.io/github/release/ruzickap/action-my-markdown-linter.svg)](https://github.com/ruzickap/action-my-markdown-linter/releases/latest)
[![GitHub release date](https://img.shields.io/github/release-date/ruzickap/action-my-markdown-linter.svg)](https://github.com/ruzickap/action-my-markdown-linter/releases)
![GitHub Actions status](https://github.com/ruzickap/action-my-markdown-linter/workflows/docker-image/badge.svg)
[![Docker Hub Build Status](https://img.shields.io/docker/cloud/build/peru/my-markdown-linter.svg)](https://hub.docker.com/r/peru/my-markdown-linter)

This is a GitHub Action to lint Markdown files.
It's using the [markdownlint-cli](https://github.com/igorshubovych/markdownlint-cli)
and [fd](https://github.com/sharkdp/fd).

See the basic GitHub Action example:

```yaml
name: markdown_lint

on:
  push:

name: Lint Markdown files
jobs:
  markdown_lint:
    name: Check Markdown files
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Markdown Lint
        uses: ruzickap/action-my-markdown-linter@v1
```

## Parameters

Variables used by `action-my-markdown-linter` GitHub Action:

| Variable        | Default                                                | Description                                                                                                                                                                        |
| --------------- | ------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `config_file`   | `.markdownlint.yaml` / `.markdownlint.yml` (if exists) | [Config file](https://github.com/igorshubovych/markdownlint-cli#configuration) used by [markdownlint-cli](https://github.com/igorshubovych/markdownlint-cli)                       |
| `debug`         | (not defined)                                          | Enable debug mode for the [entrypoint.sh](entrypoint.sh) script (`set -x`)                                                                                                                      |
| `exclude`       | (not defined)                                          | Exclude files or directories - see the [--exclude parameter](https://github.com/sharkdp/fd#excluding-specific-files-or-directories) of [fd](https://github.com/sharkdp/fd) command |
| `fd_cmd_params` | `. -0 --extension md --type f --hidden --no-ignore`    | Set your own parameters for [fd](https://github.com/sharkdp/fd) command. `exclude` and `search_paths` parameters are ignored if this is set.                                       |
| `search_paths`  | (not defined)                                          | By default all `*.md` are checked in whole repository, but you can specify your directories                                                                                        |

Non of the parameters above are "mandatory".

## Full example

GitHub Action example:

```yaml
name: markdown_lint

on:
  push:
    branches:
      - master

jobs:
  markdown_lint:
  name: Check Markdown files
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Markdown Lint
        uses: ruzickap/action-my-markdown-linter@v1
        with:
          config_file: my_markdownlint.yml
          debug: true
          exclude: |
            my_exclude_dir/md_files/
            my_exclude_dir_2/markdown_files/
            CHANGELOG.md
          search_paths: |
            check_dir_1/md_files/
            check_dir_2/markdown_files/

      - name: Markdown Lint - check only 'docs' directory and exclude CHANGELOG.md
        uses: ruzickap/action-my-markdown-linter@v1
        with:
          search_paths: |
            docs/
          exclude: |
            CHANGELOG.md

      - name: Markdown Lint - simple example
        uses: ruzickap/action-my-markdown-linter@v1

      - name: Markdown Lint using pre-built container
        uses: docker://peru/my-markdown-linter@v1
```

## Running locally

It's possible to use the markdown linter task locally using docker:

```bash
docker run --rm -t -v "${PWD}/tests/test2:/mnt" peru/my-markdown-linter
```

Output:

```text
*** Start checking...
*** Running: fd . -0 --extension md --type f --hidden --no-ignore
*** Running: markdownlint  normal.md
*** Checks completed...
```

Or you can also use parameters:

```bash
export INPUT_EXCLUDE="CHANGELOG.md test1/excluded_file.md bad.md excluded_dir/"
export INPUT_SEARCH_PATHS="tests/"
docker run --rm -t -e INPUT_EXCLUDE -e INPUT_SEARCH_PATHS -v "${PWD}:/mnt" peru/my-markdown-linter
```

Output:

```text
*** Start checking...
*** Running: fd . -0 --extension md --type f --hidden --no-ignore --exclude CHANGELOG.md --exclude test1/excluded_file.md --exclude bad.md --exclude excluded_dir/ tests/
*** Running: markdownlint  tests/test2/normal.md
*** Checks completed...
```

## Examples
