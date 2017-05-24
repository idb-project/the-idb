#!/bin/bash

set -x

COMMIT=`git rev-parse --short HEAD`
#BRANCH=`git branch | grep \* | cut -d ' ' -f2`
TAG=`git tag | tail -1 | cut -d ' ' -f2`

if [[ "$BRANCH" == release* ]]; then
	VERSIONSTRING="${TAG}"
else
	VERSIONSTRING="${TAG}-${COMMIT}"
fi

cat > config/initializers/version.rb <<EOF
module IDB
	VERSION = '${VERSIONSTRING}'
end
EOF

