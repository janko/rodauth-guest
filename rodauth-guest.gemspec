# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "rodauth-guest"
  spec.version = "0.0.1"
  spec.authors = ["Janko Marohnić"]
  spec.email = ["janko@hey.com"]

  spec.summary = "Provides guest users functionality for Rodauth."
  spec.homepage = "https://github.com/janko/rodauth-guest"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.3"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/janko/rodauth-guest"

  spec.files = Dir["lib/**/*", "README.md", "CHANGELOG.md", "LICENSE.txt", "*.gemspec"]
  spec.require_paths = ["lib"]

  spec.add_dependency "rodauth", "~> 2.0"

  spec.add_development_dependency "minitest"
  spec.add_development_dependency "minitest-hooks"
  spec.add_development_dependency "capybara"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "tilt"
  spec.add_development_dependency "bcrypt"
  spec.add_development_dependency "mail"
  spec.add_development_dependency "net-smtp"
end
