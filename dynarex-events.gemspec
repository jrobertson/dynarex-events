Gem::Specification.new do |s|
  s.name = 'dynarex-events'
  s.version = '0.3.0'
  s.summary = 'dynarex-events'
  s.authors = ['James Robertson']
  s.files = Dir['lib/dynarex-events.rb']
  s.add_runtime_dependency('dynarex_cron', '~> 0.9', '>=0.9.2')
  s.add_runtime_dependency('chronic_duration', '~> 0.10', '>=0.10.6')
  s.signing_key = '../privatekeys/dynarex-events.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/dynarex-events'
  s.required_ruby_version = '>= 2.1.2'
end
