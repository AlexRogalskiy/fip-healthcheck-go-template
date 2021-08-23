#!/bin/bash -e
# Copyright (c) 2021 SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

GITHUB_PROJECT=${1}

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    SED_BINARY="sed"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    SED_BINARY="gsed"
else
    echo "$OSTYPE Not supported"
    exit 2
fi

which "${SED_BINARY}" > /dev/null || (echo "*** Please install ${SED_BINARY} ***" && exit 1)

echo "Initializing repository for ${GITHUB_PROJECT}"
echo " Configuring local project"
echo "  Replacing README.md with repo.README.md"
mv repo.README.md README.md
echo "  Replacing example-check with ${GITHUB_PROJECT} in all the files"
grep -rl example-check --exclude-dir=.git ./ | xargs ${SED_BINARY} -i -e 's@example-check@'"$GITHUB_PROJECT"'@g'
echo "  Replacing fip-healthcheck-go-template with ${GITHUB_PROJECT} in all the files"
grep -rl fip-healthcheck-go-template --exclude-dir=.git ./ | xargs ${SED_BINARY} -i -e 's@fip-healthcheck-go-template@'"$GITHUB_PROJECT"'@g'
echo "  Replacing example-check directories with ${GITHUB_PROJECT} in all the dirs"
mv cmd/example-check cmd/"${GITHUB_PROJECT}"
mv internal/example-check internal/"${GITHUB_PROJECT}"
mv pkg/example-check pkg/"${GITHUB_PROJECT}"
echo "  Removing template docs"
rm -rf docs/template
echo "  Remove init target"
${SED_BINARY} -i '/Init the project/d' Makefile
${SED_BINARY} -i '/^init:.*/d' Makefile
${SED_BINARY} -i '/\"Project already/d' Makefile
echo "  Removing this script"
rm -rf "${0}"

cat << EOF
Successfully initialized. Feel free to:

$ git add .
$ git commit --amend -m "Initial commit"
$ git push -f

In order to have a clean repo starting point
EOF
