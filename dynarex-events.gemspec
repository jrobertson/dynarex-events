Gem::Specification.new do |s|
  s.name = 'dynarex-events'
  s.version = '0.2.0'
  s.summary = 'dynarex-events'
  s.authors = ['James Robertson']
  s.files = Dir['lib/**/*.rb']
  s.add_runtime_dependency('dynarex_cron', '~> 0.5', '>=0.5.3')
  s.add_runtime_dependency('chronic_duration', '~> 0.10', '>=0.10.4')
  s.signing_key = '../privatekeys/dynarex-events.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/dynarex-events'
  s.required_ruby_version = '>= 2.1.2'
end
