#!/usr/bin/bash

set -eou pipefail

# TODO: write down the benefits/tradeoffs of each command

git config core.fsmonitor true
git config core.untrackedCache true
git config feature.manyFiles true
git maintenance start
git config status.showUntrackedFiles no

# git config core.commitGraph True
# git config gc.writeCommitGraph True
