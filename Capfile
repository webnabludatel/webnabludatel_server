load 'deploy' if respond_to?(:namespace) # cap2 differentiator

load 'deploy/assets'

Dir['vendor/gems/*/recipes/*.rb','vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

load 'config/deploy'
load 'config/deploy/symlinks'
load 'config/deploy/unicorn'
load 'config/deploy/setup'
load 'config/deploy/admin'

