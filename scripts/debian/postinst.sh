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

# copy selected initializers
cp $IDBPATH/config-example/initializers/app_config.rb $IDBETC/initializers
cp $IDBPATH/config-example/initializers/assets.rb $IDBETC/initializers
cp $IDBPATH/config-example/initializers/backtrace_silencers.rb $IDBETC/initializers
cp $IDBPATH/config-example/initializers/filter_parameter_logging.rb $IDBETC/initializers
cp $IDBPATH/config-example/initializers/inflections.rb $IDBETC/initializers
cp $IDBPATH/config-example/initializers/mime_types.rb $IDBETC/initializers
cp $IDBPATH/config-example/initializers/paper_trail.rb $IDBETC/initializers
cp $IDBPATH/config-example/initializers/raven.rb $IDBETC/initializers
cp $IDBPATH/config-example/initializers/redis.rb $IDBETC/initializers
cp $IDBPATH/config-example/initializers/rubius.rb $IDBETC/initializers
cp $IDBPATH/config-example/initializers/session_store.rb $IDBETC/initializers
cp $IDBPATH/config-example/initializers/sidekiq.rb $IDBETC/initializers
cp $IDBPATH/config-example/initializers/simple_form.rb $IDBETC/initializers
cp $IDBPATH/config-example/initializers/simple_form_bootstrap.rb $IDBETC/initializers
cp $IDBPATH/config-example/initializers/version.rb $IDBETC/initializers
cp $IDBPATH/config-example/initializers/wrap_parameters.rb $IDBETC/initializers
