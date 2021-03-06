# -*- encoding: utf-8 -*-
require File.expand_path('../lib/google_auth_bridge/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["GOV.UK Dev"]
  gem.email = %w(govuk-dev@digital.cabinet-office.gov.uk)
  gem.description   = "bridge for supporting multiple google authentication libraries" 
  gem.summary       = "bridge for supporting multiple google authentication libraries"  
  gem.homepage      = "https://github.com/alphagov/google-auth-bridge"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "google_auth_bridge"
  gem.require_paths = %w(lib)
  gem.version = GoogleAuthenticationBridge::VERSION

  gem.add_dependency('oauth2')
  gem.add_dependency('google-api-client')

  gem.add_development_dependency("rake")
  gem.add_development_dependency("rspec")
  gem.add_development_dependency("ci_reporter")
  gem.add_development_dependency("simplecov")
  gem.add_development_dependency("gem_publisher", "~> 1.1.1")

end
