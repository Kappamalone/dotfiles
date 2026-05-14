#!/usr/bin/bash

set -eou pipefail

# TODO: write down the benefits/tradeoffs of each command

# NOTE: if set to true, results in "Empty last update token" which messes with gh.nvim/octo.nvim
git config core.fsmonitor false

git config core.untrackedCache true
git config feature.manyFiles true
git maintenance start

# no is apparently a speedup, but might result in me forgetting stuff
git config status.showUntrackedFiles yes

# git config core.commitGraph True
# git config gc.writeCommitGraph True
