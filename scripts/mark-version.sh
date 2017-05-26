#!/bin/bash

COMMIT=`git rev-parse --short HEAD`
TAG=`git tag | tail -1`

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

