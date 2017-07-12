#!/bin/sh

# remove existing symlink to config
if [ -L /opt/idb/config ]; then
  rm /opt/idb/config
end

# create symlink to config
ln -s /etc/idb /opt/idb/config

# copy initializers
cp /opt/idb/config-example/initializers/{app_config.rb,assets.rb,backtrace_silencers.rb,filter_parameter_logging.rb,inflections.rb,mime_types.rb,paper_trail.rb,raven.rb,redis.rb,rubius.rb,session_store.rb,sidekiq.rb,simple_form.rb,simple_form_bootstrap.rb,version.rb,wrap_parameters.rb} /etc/idb/initializers
