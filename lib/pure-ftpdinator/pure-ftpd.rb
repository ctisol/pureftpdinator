# config valid only for Capistrano 3.2.1
lock '3.2.1'

namespace :pureftpd do
  desc "Setup Pure-FTPd on the host"
  task :setup => 'deployinator:load_settings' do
    # ensure "ftpuser" is setup?
    # ensure UFW port range is opened
    # check if running, start if not
  end
end
