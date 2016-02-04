# config valid only for Capistrano 3.2.1
lock '3.2.1'

##### pureftpdinator
### ------------------------------------------------------------------
set :application,                     'my_app_name'
set :preexisting_ssh_user,            ENV['USER']
set :deployment_username,             "deployer" # user with SSH access and passwordless sudo rights
set :ignore_permissions_dirs,         [fetch(:pureftpd_config_path)]
set :pureftpd_username,               "ftpuser"
# TODO confirm 990 is the right port for TLS
set :pureftpd_connection_ports,       ["21", "990"] # ports 21, 990, etc
set :pureftpd_passive_port_range,     "6500:6700"
set :pureftpd_tls_mode,               "3"
### ------------------------------------------------------------------
