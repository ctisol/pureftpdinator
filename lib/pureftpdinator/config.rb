module Capistrano
  module TaskEnhancements
    alias_method :pureftpd_original_default_tasks, :default_tasks
    def default_tasks
      pureftpd_original_default_tasks + [
        "pureftpdinator:write_built_in",
        "pureftpdinator:write_example_configs",
        "pureftpdinator:write_example_configs:in_place"
      ]
    end
  end
end

namespace :pureftpdinator do

  set :example, "_example"

  desc 'Write example config files'
  task :write_example_configs => 'deployinator:load_settings' do
    run_locally do
      path = fetch(:pureftpd_templates_path)
      execute "mkdir", "-p", "config/deploy", path
      {
        "examples/Capfile"                    => "Capfile#{fetch(:example)}",
        "examples/config/deploy.rb"           => "config/deploy#{fetch(:example)}.rb",
        "examples/config/deploy/staging.rb"   => "config/deploy/staging#{fetch(:example)}.rb",
        "examples/Dockerfile"                 => "#{path}/Dockerfile#{fetch(:example)}",
        "examples/ssl.crt.erb"                => "#{path}/ssl.crt#{fetch(:example)}.erb",
        "examples/ssl.key.erb"                => "#{path}/ssl.key#{fetch(:example)}.erb"
      }.each do |source, destination|
        config = File.read(File.dirname(__FILE__) + "/#{source}")
        File.open("./#{destination}", 'w') { |f| f.write(config) }
        info "Wrote '#{destination}'"
      end
      unless fetch(:example).empty?
        info(
          "Now remove the '#{fetch(:example)}' portion of their names " +
          "or diff with existing files and add the needed lines."
        )
      end
    end
  end

  desc 'Write example config files (will overwrite any existing config files).'
  namespace :write_example_configs do
    task :in_place => 'deployinator:load_settings' do
      set :example, ""
      Rake::Task['pureftpdinator:write_example_configs'].invoke
    end
  end

  desc 'Write a file showing the built-in overridable settings.'
  task :write_built_in => 'deployinator:load_settings' do
    run_locally do
      {
        'built-in.rb'                         => 'built-in.rb',
      }.each do |source, destination|
        config = File.read(File.dirname(__FILE__) + "/#{source}")
        File.open("./#{destination}", 'w') { |f| f.write(config) }
        info "Wrote '#{destination}'"
      end
      info "Now examine the file and copy-paste into your deploy.rb or <stage>.rb and customize."
    end
  end

  # These are the only two tasks using :preexisting_ssh_user
  namespace :deployment_user do
    #desc "Setup or re-setup the deployment user, idempotently"
    task :setup => 'deployinator:load_settings' do
      on roles(:all) do |h|
        on "#{fetch(:preexisting_ssh_user)}@#{h}" do |host|
          as :root do
            path = fetch(:deploy_templates_path, nil)
            path = fetch(:pureftpd_templates_path) if path.nil?
            deployment_user_setup(path)
          end
        end
      end
    end
  end

  task :deployment_user => 'deployinator:load_settings' do
    on roles(:all) do |h|
      on "#{fetch(:preexisting_ssh_user)}@#{h}" do |host|
        as :root do
          if unix_user_exists?(fetch(:deployment_username))
            info "User #{fetch(:deployment_username)} already exists. You can safely re-setup the user with 'deployinator:deployment_user:setup'."
          else
            Rake::Task['deployinator:deployment_user:setup'].invoke
          end
        end
      end
    end
  end

end
