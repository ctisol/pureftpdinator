Gem::Specification.new do |s|
  s.name        = 'pure-ftpdinator'
  s.version     = '0.0.0'
  s.date        = '2016-01-30'
  s.summary     = "Deploy Applications"
  s.description = "Deploy Ruby on Rails using Capistrano and Docker"
  s.authors     = ["david amick"]
  s.email       = "davidamick@ctisolutionsinc.com"
  s.files       = [
    "lib/pure-ftpdinator.rb",
    "lib/pure-ftpdinator/pure-ftpd.rb",
    "lib/pure-ftpdinator/config.rb",
    "lib/pure-ftpdinator/built-in.rb",
    "lib/pure-ftpdinator/examples/Capfile",
    "lib/pure-ftpdinator/examples/config/deploy.rb",
    "lib/pure-ftpdinator/examples/config/deploy/staging.rb",
    "lib/pure-ftpdinator/examples/Dockerfile",
    "lib/pure-ftpdinator/examples/deployment_authorized_keys.erb"
  ]
  s.required_ruby_version   =               '>= 1.9.3'
  s.requirements            <<              "Docker ~> 1.9.1"
  s.add_runtime_dependency  'capistrano',   '~> 3.2.1'
  s.add_runtime_dependency  'deployinator', '~> 0.2.0'
  s.add_runtime_dependency  'rake',         '~> 10.3.2'
  s.add_runtime_dependency  'sshkit',       '~> 1.5.1'
  s.homepage      =
    'https://github.com/snarlysodboxer/pure-ftpdinator'
  s.license       = 'GNU'
end
