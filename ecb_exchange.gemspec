# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ecb/exchange'

Gem::Specification.new do |spec|
  spec.name          = "ecb_exchange"
  spec.version       = ECB::Exchange::VERSION
  spec.authors       = ["Matthew Hutchinson"]
  spec.email         = ["matt@hiddenloop.com"]

  spec.license       = "MIT"
  spec.summary       = <<-EOF
  Finds and converts exchange rates based on available ECB reference rates from
  the last 90 days
  EOF

  spec.description = <<-EOF
  Finds (and caches) recent ECB reference rates, and provides an ExchangeRate
  convertor between currencies supported by the ECB reference rate feed
  EOF

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.test_files    = `git ls-files -- {test}/*`.split("\n")
  spec.bindir        = "bin"
  spec.require_paths = ["lib"]

  # documentation
  spec.has_rdoc         = true
  spec.extra_rdoc_files = ['README.md', 'LICENSE.txt']
  spec.rdoc_options << '--title' << 'ECB Exchange' << '--main' << 'README.md' << '-ri'

  # non-gem dependecies
  spec.required_ruby_version = ">= 2.1.0"

  # dev gems
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "byebug"

  # docs
  spec.add_development_dependency "rdoc"

  # testing
  # use latest Rails version in tests (for cache testing)
  spec.add_development_dependency('activesupport', '~> 5.2.0')
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "webmock"
end
