# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spree/adyen/version'

Gem::Specification.new do |spec|
  spec.name          = "solidus-adyen"
  spec.version       = Spree::Adyen::VERSION
  spec.authors       = ["Washington Luiz"]
  spec.email         = ["huoxito@gmail.com"]
  spec.description   = "Plugs Adyen Payment Gateway into Spree Stores"
  spec.summary       = "Plugs Adyen Payment Gateway into Spree Stores"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]


  spec.add_runtime_dependency 'adyen', "~> 1.4"
  spec.add_runtime_dependency "solidus_core", "~> 1.0"
  spec.add_runtime_dependency "bourbon"

  spec.add_development_dependency "solidus", "~> 1.0"
  spec.add_development_dependency "solidus_auth_devise", "~> 1.2"
  spec.add_development_dependency "solidus_sample", "~> 1.0"

  spec.add_development_dependency 'sass-rails', '~> 4.0.2'
  spec.add_development_dependency 'coffee-rails'

  spec.add_development_dependency 'sqlite3'

  spec.add_development_dependency "rspec-rails", "~> 3.3"
  spec.add_development_dependency 'rspec-activemodel-mocks'
  spec.add_development_dependency "factory_girl"
  spec.add_development_dependency "shoulda-matchers"

  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-rcov'

  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'pry-rails'
  spec.add_development_dependency 'better_errors'
  spec.add_development_dependency 'binding_of_caller'
  spec.add_development_dependency 'pry-stack_explorer'

  spec.add_development_dependency 'capybara'
  spec.add_development_dependency 'poltergeist'
  spec.add_development_dependency 'launchy'
end
