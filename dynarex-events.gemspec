Gem::Specification.new do |s|
  s.name = 'dynarex-events'
  s.version = '0.1.8'
  s.summary = 'dynarex-events'
  s.authors = ['James Robertson']
  s.files = Dir['lib/**/*.rb']
  s.add_dependency('dynarex_cron')
  s.add_dependency('chronic_duration')
  s.signing_key = '../privatekeys/dynarex-events.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/dynarex-events'
end
