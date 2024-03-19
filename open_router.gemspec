# frozen_string_literal: true

require_relative "lib/open_router/version"

Gem::Specification.new do |spec|
  spec.name = "open_router"
  spec.version = OpenRouter::VERSION
  spec.authors = ["Obie Fernandez"]
  spec.email = ["obiefernandez@gmail.com"]

  spec.summary = "Ruby library for OpenRouter API."
  spec.homepage = "https://github.com/OlympiaAI/open_router"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.1"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/OlympiaAI/open_router"
  spec.metadata["changelog_uri"] = "https://github.com/OlympiaAI/open_router/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.end_with?('.gem') || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", ">= 1"
  spec.add_dependency "faraday-multipart", ">= 1"
end
