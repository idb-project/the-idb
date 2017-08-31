#!/bin/sh

# abort on errors
set -e

IDBBASENAME=the-idb
IDBPATH=/opt/$IDBBASENAME
IDBETC=/etc/$IDBBASENAME

# remove existing symlink to config
if [ -L $IDBPATH/config ]; then
  rm $IDBPATH/config
fi

# test if configuration dir exists, create if not
if [ ! -d "$IDBETC" ]; then
  mkdir $IDBETC
fi 

# create symlink to config
ln -s $IDBETC $IDBPATH/config

# copy config files
for f in $IDBPATH/config-example/*; do
  # don't overwrite existing configs
  cp -nR $f $IDBETC
done

# fix ownership of config and symlinks
chown -R idb:idb $IDBETC
chown idb:idb $IDBPATH/config
chown idb:idb $IDBPATH/log
