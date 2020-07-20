#!/usr/bin/env bash
# shellcheck disable=SC2016

# Record using: termtosvg --screen-geometry 93x30 --command ./my-markdown-linter-demo.sh

set -u

################################################
# include the magic
################################################
test -s ./demo-magic.sh || curl --silent https://raw.githubusercontent.com/paxtonhare/demo-magic/master/demo-magic.sh > demo-magic.sh
# shellcheck disable=SC1091
. ./demo-magic.sh

################################################
# Configure the options
################################################

#
# speed at which to simulate typing. bigger num = faster
#
export TYPE_SPEED=20

# Uncomment to run non-interactively
export PROMPT_TIMEOUT=1

# No wait
export NO_WAIT=false

#
# custom prompt
#
# see http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/bash-prompt-escape-sequences.html for escape sequences
#
#DEMO_PROMPT="${GREEN}➜ ${CYAN}\W "
export DEMO_PROMPT="${GREEN}➜ ${CYAN}$ "

# hide the evidence
clear

p 'This is example of my-markdown-linter usage...'

p ''
p 'Set the INPUT_SEARCH_PATHS variable'
pe 'export INPUT_SEARCH_PATHS="tests/"'

p ''
p 'Run the container image "peru/my-markdown-linter" to start checking:'
pe 'docker run --rm -t -e INPUT_SEARCH_PATHS -v "${PWD}:/mnt" peru/my-markdown-linter'

sleep 3

p ''
p 'As you can see there are errors in this file: tests/test-bad-mdfile/bad.md'
p ''
pe 'bat -p tests/test-bad-mdfile/bad.md'

p ''
p '(There should be a new line after the header in the bad.md file)'
p ''
p "Let's exclude this file form beeing checked:"
pe 'export INPUT_EXCLUDE="test-bad-mdfile/bad.md test1/CHANGELOG.md"'
pe 'docker run --rm -t -e INPUT_SEARCH_PATHS -e INPUT_EXCLUDE -v "${PWD}:/mnt" peru/my-markdown-linter'

sleep 3

p ''
p 'You can also specify the command line parameters for fd command if you need advanced search:'
pe 'export INPUT_FD_CMD_PARAMS=". -0 --extension md --type f --hidden --no-ignore --exclude CHANGELOG.md --exclude test1/excluded_file.md --exclude bad.md --exclude excluded_dir/ tests/"'
pe 'docker run --rm -t -e INPUT_FD_CMD_PARAMS -v "${PWD}:/mnt" peru/my-markdown-linter'

sleep 3

p ''
p 'If you are in trouble you can try the debug mode:'
pe 'export INPUT_DEBUG="true"'
pe 'docker run --rm -t -e INPUT_DEBUG -v "${PWD}:/mnt" peru/my-markdown-linter'

sleep 3

p ''
p 'Enjoy ;-) ...'

sleep 3

rm ./demo-magic.sh
