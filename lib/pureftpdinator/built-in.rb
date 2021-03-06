require 'resolv'
set :pureftpd_config_dir,         -> { shared_path.join('pureftpd') }
set :pureftpd_pid_file,           -> { "#{fetch(:pureftpd_config_dir)}/pure-ftpd.pid" }
set :pureauthd_pid_file,          -> { "#{fetch(:pureftpd_config_dir)}/pure-authd.pid" }
set :pureftpd_socket_dir,         "/tmp/pureftpd"
set :pureauthd_socket_file,       -> { "#{fetch(:pureftpd_socket_dir)}/pure-authd.sock" }
set :pureftpd_entrypoint,         "/usr/sbin/pure-ftpd"
set :pureauthd_entrypoint,        "/usr/sbin/pure-authd"
set :pureauthd_program,           -> { shared_path.join('bundle', 'bin', 'ftp_auth') }
set :pureftpd_templates_path,     "templates/pureftpd"
set :pureftpd_umask,              "117:007"
set :pureftpd_internal_cert_file, "/etc/ssl/private/pure-ftpd.pem"
set :pureftpd_external_cert_file, -> { "#{fetch(:pureftpd_config_dir)}/ssl.pem" }
set :pureftpd_custom_vol_mounts,  -> {} # Set custom vol mounts w/o overriding methods below
set :pureftpd_custom_env_vars,    -> {} # Set custom env vars w/o overriding methods below
set :pureftpd_ports_options,      -> {
  fetch(:pureftpd_connection_ports).collect do |port|
    ["--publish", "0.0.0.0:#{port}:#{port}"]
  end.flatten
}
set :pureftpd_port_range_options, -> {
  ports = fetch(:pureftpd_passive_port_range).split(":")
  ["--publish", "0.0.0.0:#{ports[0]}-#{ports[1]}:#{ports[0]}-#{ports[1]}"]
}
set :pureftpd_tls_volume_options, -> {
  if ["1", "2", "3"].include? fetch(:pureftpd_tls_mode)
    ["--volume", "#{fetch(:pureftpd_external_cert_file)}:#{fetch(:pureftpd_internal_cert_file)}:ro"]
  end
}

def pureftpd_run(host)
  warn "Starting a new container named #{fetch(:pureftpd_container_name)} on #{host}"
  execute(
    "docker", "run", "--tty", "--detach",
    "--name", fetch(:pureftpd_container_name),
    "--restart", "always",
    "--memory", "#{fetch(:pureftpd_container_max_mem_mb)}m",
    "--memory-swap='-1'",
    "-e", "RAILS_ROOT=#{current_path}",
    "--volume", "#{fetch(:deploy_to)}:#{fetch(:deploy_to)}:rw",
    "--volume", "/home/#{fetch(:pureftpd_username)}:/home/#{fetch(:pureftpd_username)}:rw",
    "--volume", "#{fetch(:pureftpd_socket_dir)}:#{fetch(:pureftpd_socket_dir)}:rw",
    fetch(:pureftpd_tls_volume_options),
    fetch(:pureftpd_custom_vol_mounts),
    fetch(:pureftpd_custom_env_vars),
    fetch(:pureftpd_ports_options),
    fetch(:pureftpd_port_range_options),
    "--entrypoint", fetch(:pureftpd_entrypoint),
    fetch(:pureftpd_image_name),
    "-0", "-4", "-A", "-E",
    "-g", fetch(:pureftpd_pid_file),
    "-G", "-k", "90",
    "-O", "clf:#{shared_path.join('log', 'pure-ftpd.log')}",
    "-l", "extauth:#{fetch(:pureauthd_socket_file)}",
    "-p", fetch(:pureftpd_passive_port_range),
    "-R", "-S", "0.0.0.0,",
    "-P", Resolv::DNS.new(:nameserver => ['8.8.8.8', '8.8.4.4']).getaddress(fetch(:domain)).to_s,
    "-u", "999", "-U", fetch(:pureftpd_umask),
    "-Y", fetch(:pureftpd_tls_mode)
  )
end

def pureauthd_run(host)
  warn "Starting a new container named #{fetch(:pureauthd_container_name)} on #{host}"
  execute(
    "docker", "run", "--tty", "--detach",
    "--name", fetch(:pureauthd_container_name),
    "--restart", "always",
    "--memory", "#{fetch(:pureauthd_container_max_mem_mb)}m",
    "--memory-swap='-1'",
    "-e", "RAILS_ROOT=#{current_path}",
    "--workdir", current_path,
    "--volume", "#{fetch(:deploy_to)}:#{fetch(:deploy_to)}:rw",
    "--volume", "/home/#{fetch(:pureftpd_username)}:/home/#{fetch(:pureftpd_username)}:rw",
    "--volume", "#{fetch(:pureftpd_socket_dir)}:#{fetch(:pureftpd_socket_dir)}:rw",
    "--volume", "/etc/passwd:/etc/passwd:ro",
    "--volume", "/etc/group:/etc/group:ro",
    fetch(:pureftpd_custom_vol_mounts),
    fetch(:pureftpd_custom_env_vars),
    "--entrypoint", fetch(:pureauthd_entrypoint),
    fetch(:pureftpd_image_name),
    "--socket", fetch(:pureauthd_socket_file),
    "--pidfile", fetch(:pureauthd_pid_file),
    "--run", fetch(:pureauthd_program)
    # "--uid", unix_user_get_uid(fetch(:pureftpd_username)), # won't communicate over socket unless run as root for some reason
    # "--gid", unix_user_get_gid(fetch(:pureftpd_username))
  )
end

