#!/bin/sh

# remove existing symlink to config
if [ -L /opt/idb/config ]; then
  rm /opt/idb/config
end

# create symlink to config
ln -s /etc/idb /opt/idb/config

# copy initializers
cp -R /opt/idb/config-example/initializers /etc/idb/initializers