#!/bin/sh

# abort on errors
set -e

IDBBASENAME=the-idb
IDBPATH=/opt/$IDBBASENAME
IDBETC=/etc/$IDBBASENAME

# remove existing symlink to config
if [ -L $IDBPATH/config ]; then
  rm $IDBPATH/config
end

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
cp $IDBPATH/config-example/initializers/{app_config.rb,assets.rb,backtrace_silencers.rb,filter_parameter_logging.rb,inflections.rb,mime_types.rb,paper_trail.rb,raven.rb,redis.rb,rubius.rb,session_store.rb,sidekiq.rb,simple_form.rb,simple_form_bootstrap.rb,version.rb,wrap_parameters.rb} $IDBETC/initializers
