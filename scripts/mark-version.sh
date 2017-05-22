#!/bin/bash

COMMIT=`git rev-parse --short HEAD`
BRANCH=`git branch | grep \* | cut -d ' ' -f2`
VERSION=`cat VERSION`

if [[ "$BRANCH" == release* ]]; then
	VERSIONSTRING="${VERSION}"
else
	VERSIONSTRING="${VERSION}-${BRANCH}-${COMMIT}"
fi

cat > config/initializers/version.rb <<EOF
module IDB
	VERSION = '${VERSIONSTRING}'
end
EOF

