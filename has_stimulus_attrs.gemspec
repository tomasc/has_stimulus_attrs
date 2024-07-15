# frozen_string_literal: true

require_relative "lib/has_stimulus_attrs/version"

Gem::Specification.new do |spec|
  spec.name = "has_stimulus_attrs"
  spec.version = HasStimulusAttrs::VERSION
  spec.authors = ["Tomas Celizna", "Asger Behncke Jacobsen"]
  spec.email = ["tomas.celizna@gmail.com", "a@asgerbehnckejacobsen.dk"]

  spec.summary = "Helper methods for dealing with stimulus attributes."
  spec.description = "Helper methods for dealing with stimulus attributes."
  spec.homepage = "https://github.com/tomasc/has_stimulus_attrs"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/tomasc/has_stimulus_attrs/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "stimulus_helpers", "~> 0.1.0"
  spec.add_dependency "has_dom_attrs", "~> 0.1.0"
  spec.add_dependency "activesupport", ">= 7.0.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", "~> 5.0"

  spec.add_development_dependency "lefthook"
  spec.add_development_dependency "rubocop-rails_config"
end
