
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "omniauth/cloudiap/version"

Gem::Specification.new do |spec|
  spec.name          = "omniauth-cloudiap"
  spec.version       = OmniAuth::Cloudiap::VERSION
  spec.authors       = ["HORII Keima"]
  spec.email         = ["holysugar@gmail.com"]
  spec.license       = "MIT"

  spec.summary       = %q{omniauth strategy using Google Cloud IAP}
  spec.description   = %q{omniauth strategy using Google Cloud IAP}
  spec.homepage      = "https://github.com/holysugar/omniauth-cloudiap"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = spec.homepage
    #spec.metadata["changelog_uri"] = ""
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "minitest-power_assert"
  spec.add_development_dependency "rack-session"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "timecop"

  spec.add_dependency "omniauth"
  spec.add_dependency "jwt"
end

