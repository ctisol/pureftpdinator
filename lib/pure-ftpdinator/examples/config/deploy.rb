# config valid only for Capistrano 3.2.1
lock '3.2.1'

##### pure-ftpdinator
### ------------------------------------------------------------------
set :application,                   'my_app_name'
set :preexisting_ssh_user,          ENV['USER']
set :deployment_username,           "deployer" # user with SSH access and passwordless sudo rights
set :webserver_username,            "www-data" # less trusted web server user with limited write permissions
### ------------------------------------------------------------------
