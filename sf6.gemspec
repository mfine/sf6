Gem::Specification.new do |s|
  s.name = "sf6"
  s.email = "mark.fine@gmail.com"
  s.version = "0.3"
  s.description = "Circuit breaker, Rate limiter."
  s.summary = "breaker"
  s.authors = ["Mark Fine"]
  s.homepage = "http://github.com/mfine/sf6"

  s.files = Dir["lib/**/*.rb"] + Dir["Gemfile*"]
  s.require_paths = ["lib"]
end
