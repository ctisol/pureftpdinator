# config valid only for Capistrano 3.2.1
lock '3.2.1'

namespace :pureftpd do

  set :pureftpd_config_file_changed, false
  desc "Setup Pure-FTPd on the host"
  task :setup => ['deployinator:load_settings', 'pureftpdinator:deployment_user', :open_firewall, :ensure_ftp_user, :ensure_ssl_cert] do
    on roles(:app) do |host|
      as :root do
        name = fetch(:pureauthd_container_name)
        unless container_exists?(name)
          pureauthd_run(host)
        else
          unless container_is_running?(name)
            start_container(name)
          else
            info "#{name} is already running; we're setup!"
          end
        end
        name = fetch(:pureftpd_container_name)
        unless container_exists?(name)
          pureftpd_run(host)
        else
          unless container_is_running?(name)
            start_container(name)
          else
            if fetch(:pureftpd_config_file_changed)
              restart_container(name)
            else
              info "No config file changes for #{name} and it is already running; we're setup!"
            end
          end
        end
      end
    end
  end

  desc 'Restart the PureFTPd and PureAuthd Docker containers'
  task :restart => 'deployinator:load_settings' do
    on roles(:app) do |host|
      name = fetch(:pureauthd_container_name)
      if container_exists?(name)
        if container_is_restarting?(name) or container_is_running?(name)
          execute("docker", "stop", name)
        else
          execute("docker", "start", name)
        end
      else
        pureauthd_run(host)
        check_stayed_running(name)
      end
      name = fetch(:pureftpd_container_name)
      if container_exists?(name)
        if container_is_restarting?(name) or container_is_running?(name)
          execute("docker", "stop", name)
        else
          execute("docker", "start", name)
        end
      else
        pureftpd_run(host)
        check_stayed_running(name)
      end
    end
  end

  namespace :restart do
    desc 'Restart PureFTPd and PureAuthd by recreating the Docker containers'
    task :force => 'deployinator:load_settings' do
      on roles(:app) do |host|
        [fetch(:pureauthd_container_name), fetch(:pureftpd_container_name)].each do |name|
          if container_exists?(name)
            if container_is_running?(name)
              execute("docker", "stop", name)
            end
            begin
              execute("docker", "rm",   name)
            rescue
              sleep 5
              begin
                execute("docker", "rm",   name)
              rescue
                fatal "We were not able to remove the container #{name} for some reason. Try running 'cap <stage> deploy:restart:force' again."
                exit
              end
            end
          end
        end
        Rake::Task['pureftpd:restart'].invoke
      end
    end
  end

  task :ensure_ssl_cert => 'deployinator:load_settings' do
    require 'erb'
    on roles(:app) do
      as :root do
        if ["1", "2", "3"].include? fetch(:pureftpd_tls_mode)
          execute "mkdir", "-p", File.dirname(fetch(:pureftpd_external_cert_file))
          ["ssl.key", "ssl.crt"].each do |file|
            template_path = File.expand_path("#{fetch(:pureftpd_templates_path)}/#{file}.erb")
            generated_config_file ||= ""
            generated_config_file += ERB.new(File.new(template_path).read).result(binding)
          end
          temp_file = "/tmp/temp.file"
          upload! StringIO.new(generated_config_file), temp_file
          unless test "diff", "-q", temp_file, fetch(:pureftpd_external_cert_file)
            warn "Config file #{config_file} on #{fetch(:domain)} is being updated."
            execute "mv", temp_file, fetch(:pureftpd_external_cert_file)
            set :pureftpd_config_file_changed, true
          else
            execute "rm", temp_file
          end
          execute "chown", "-R", "root:root", File.dirname(fetch(:pureftpd_external_cert_file))
          execute "chmod", "600", fetch(:pureftpd_external_cert_file)
        end
      end
    end
  end

  task :ensure_ftp_user => 'deployinator:load_settings' do
    on roles(:app) do
      as :root do
        name = fetch(:pureftpd_username)
        unix_user_add(name) unless unix_user_exists?(name)
        execute "mkdir", "-p", "/home/#{name}"
        execute "chown", "#{name}:#{name}", "/home/#{name}"
        execute "chmod", "750", "/home/#{name}"
      end
    end
  end

  task :open_firewall => 'deployinator:load_settings' do
    on roles(:app) do
      as :root do
        if test "bash", "-c", "\"ufw", "status", "&>" "/dev/null\""
          unless test("ufw", "allow", "#{fetch(:pureftpd_passive_port_range)}/tcp")
            raise "Error opening UFW firewall range #{fetch(:pureftpd_passive_port_range)}"
          end
          fetch(:pureftpd_connection_ports).each do |port|
            raise "Error opening UFW firewall port #{port}" unless test("ufw", "allow", "#{port}/tcp")
          end
        else
          warn "UFW appears not to be installed, not opening the firewall"
        end
      end
    end
  end

end
