$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
# require "blueprinter/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "blueprinter"
  s.version     = "1.1.1"
  s.authors     = ["Adam Hess", "Derek Carter"]
  s.email       = ["adamhess1991@gmail.com"]
  s.homepage    = "https://github.com/procore/blueprinter"
  s.summary     = "Simple Fast Declarative Serialization Library"
  s.description = "Blueprinter is a JSON Object Presenter for Ruby that takes business objects and breaks them down into simple hashes and serializes them to JSON. It can be used in Rails in place of other serializers (like JBuilder or ActiveModelSerializers). It is designed to be simple, direct, and performant."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "CHANGELOG.md", "MIT-LICENSE", "Rakefile", "README.md"]

  s.required_ruby_version = '>= 2.2.2'

  s.add_development_dependency "factory_bot"
  s.add_development_dependency "nokogiri", ">= 1.8.2"
#   s.add_development_dependency "oj", "~> 3.0"
#   s.add_development_dependency "yajl-ruby", "~> 1.4.1"
#   s.add_development_dependency "pry"
#   s.add_development_dependency "rake"
#   s.add_development_dependency "activerecord", "~> 5.1.2"
#   s.add_development_dependency "rspec", "~> 3.7"
#   # rspec-rails >= 4.0.0 does not support ruby 2.2
#   s.add_development_dependency 'rspec-rails', '< 4.0.0'
#   s.add_development_dependency "sqlite3", '~> 1.3.6'
#   s.add_development_dependency "yard", "~> 0.9.11"
#   s.add_development_dependency "ammeter", "~> 1.1.4"
end
