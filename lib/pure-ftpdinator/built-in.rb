set :pureftpd_socket_dir,         -> { shared_path.join('run') }

def run_pureftpd(host)
  execute(
    "docker", "run", "--tty", "--detach",
    "--name", fetch(:pureftpd_container_name),
    "--restart", "always",
    "--memory", "#{fetch(:pureftpd_container_max_mem_mb)}m",
    "--memory-swap='-1'",
    "--volume", "#{fetch(:deploy_to)}:#{fetch(:deploy_to)}:rw",
    "--entrypoint", "/usr/sbin/pure-ftpd",
    fetch(:pureftpd_image_name),
    "-0", "-4", "-A", "-E",
    "-f", "none", # TODO confirm we get logging to stdout
    "-g", "#{fetch(:pureftpd_socket_dir)}/pure-ftpd.pid",
    "-G", "-k", "90",
    "-O", "clf:#{shared_path.join('log', 'pure-ftpd.log')}",
    "-l", "extauth:#{fetch(:pureftpd_socket_dir)}/pure-authd.sock",
    "-p", "first:last", #TODO set the port range here,
    "-R", "-S", "0.0.0.0,990", # TODO confirm this is the right port
    "-u", "999", "-U", "113:022", # TODO confirm these umasks
    "-Y", "3"
  )
end

def run_pureauthd(host)
  execute(
    "docker", "run", "--tty", "--detach",
    "--name", fetch(:pureauthd_container_name),
    "--restart", "always",
    "--memory", "#{fetch(:pureauthd_container_max_mem_mb)}m",
    "--memory-swap='-1'",
    "--volume", "#{fetch(:deploy_to)}:#{fetch(:deploy_to)}:rw",
    "--entrypoint", "/usr/sbin/pure-authd",
    fetch(:pureftpd_image_name),
    "--socket", "#{fetch(:pureftpd_socket_dir)}/pure-authd.sock",
    "--pidfile", "#{fetch(:pureftpd_socket_dir)}/pure-authd.pid",
    "--run", shared_path.join('bundle', 'bin', 'ftp_auth'),
    # TODO set the uid and gid correctly,
    "--uid", "2000", "--gid", "2000"
  )
end

def restart_pureftpd(host)
  execute(
    "docker", "restart", fetch(:pureftpd_container_name)
  )
end

def restart_pureauthd(host)
  execute(
    "docker", "restart", fetch(:pureftpd_container_name)
  )
end
