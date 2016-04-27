Gem::Specification.new do |s|
  s.name        = 'pureftpdinator'
  s.version     = '0.0.0'
  s.date        = '2016-02-23'
  s.summary     = "Deploy Applications"
  s.description = "Deploy Ruby on Rails using Capistrano and Docker"
  s.authors     = ["david amick"]
  s.email       = "davidamick@ctisolutionsinc.com"
  s.files       = [
    "lib/pureftpdinator.rb",
    "lib/pureftpdinator/pureftpd.rb",
    "lib/pureftpdinator/config.rb",
    "lib/pureftpdinator/built-in.rb",
    "lib/pureftpdinator/examples/Capfile",
    "lib/pureftpdinator/examples/config/deploy.rb",
    "lib/pureftpdinator/examples/config/deploy/staging.rb",
    "lib/pureftpdinator/examples/Dockerfile",
    "lib/pureftpdinator/examples/ssl.crt.erb",
    "lib/pureftpdinator/examples/ssl.key.erb"
  ]
  s.required_ruby_version   =               '>= 1.9.3'
  s.requirements            <<              "Docker ~> 1.9.1"
  s.add_runtime_dependency  'capistrano',   '~> 3.2.1'
  s.add_runtime_dependency  'deployinator', '~> 0.1.6'
  s.add_runtime_dependency  'rake',         '~> 10.3.2'
  s.add_runtime_dependency  'sshkit',       '~> 1.5.1'
  s.homepage      =
    'https://github.com/snarlysodboxer/pureftpdinator'
  s.license       = 'GNU'
end
