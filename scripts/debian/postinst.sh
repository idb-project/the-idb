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

# check if initializers dir exists, create if not
if [ ! -d "$IDBETC/initializers" ]; then
  mkdir $IDBETC/initializers
fi

# copy initializers
for f in $IDBPATH/config-example/initializers/*; do
  # don't overwrite existing initializers as they may be customized
  cp -n $f $IDBETC/initializers
done

# copy config files
for f in $IDBPATH/config-example/*; do
  # don't overwrite existing configs
  cp -n $f $IDBETC
done

# fix ownership of config and symlinks
chown -R idb:idb $IDBETC
chown idb:idb $IDBPATH/config
chown idb:idb $IDBPATH/log
