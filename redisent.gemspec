Gem::Specification.new do |s|
  s.name              = "redisent"
  s.version           = "0.1.0"
  s.summary           = "Sentinel aware Redis client."
  s.description       = "Redisent is a wrapper for the Redis client that fetches configuration details from sentinels."
  s.authors           = ["Michel Martens"]
  s.email             = ["michel@soveran.com"]
  s.homepage          = "https://github.com/soveran/redisent"
  s.files             = `git ls-files`.split("\n")
  s.license           = "MIT"

  s.add_dependency "redic", "~> 1.5"
  s.add_development_dependency "cutest", "~> 0"
end
