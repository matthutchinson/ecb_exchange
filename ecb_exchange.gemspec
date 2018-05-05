# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ecb/exchange"

Gem::Specification.new do |spec|
  spec.name    = "ecb_exchange"
  spec.version = ECB::Exchange::VERSION
  spec.authors = ["Matthew Hutchinson"]
  spec.email   = ["matt@hiddenloop.com"]

  spec.license = "MIT"
  spec.summary = <<-EOF
  Currency conversion using the European Central Bank's foreign exchange rates.
  EOF

  spec.description = <<-EOF
  Currency conversion using the European Central Bank's foreign exchange rates.
  Rates for the last 90 days are fetched and cached on demand. All calculations
  are performed and returned as BigDecimal.
  EOF

  spec.metadata = {
    "homepage_uri"    => "https://github.com/matthutchinson/ecb_exchange",
    "changelog_uri"   => "https://github.com/matthutchinson/ecb_exchange/blob/master/CHANGELOG.md",
    "source_code_uri" => "https://github.com/matthutchinson/ecb_exchange",
    "bug_tracker_uri" => "https://github.com/matthutchinson/ecb_exchange/issues",
  }

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.test_files    = `git ls-files -- {test}/*`.split("\n")
  spec.bindir        = "bin"
  spec.require_paths = ["lib"]

  # documentation
  spec.has_rdoc         = true
  spec.extra_rdoc_files = ["README.md", "LICENSE"]
  spec.rdoc_options << "--title" << "ECB Exchange" << "--main" << "README.md" << "-ri"

  # non-gem dependecies
  spec.required_ruby_version = ">= 2.1.0"

  # dev gems
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry-byebug"

  # docs
  spec.add_development_dependency "rdoc"

  # testing
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "simplecov"
end
