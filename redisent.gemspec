# encoding: utf-8

Gem::Specification.new do |s|
  s.name              = "redisent"
  s.version           = "0.0.1"
  s.summary           = "Sentinel aware Redis client."
  s.description       = "Redisent is a wrapper for the Redis client that fetches configuration details from sentinels."
  s.authors           = ["Michel Martens"]
  s.email             = ["michel@soveran.com"]
  s.homepage          = "https://github.com/soveran/redisent"
  s.files             = ["LICENSE", "README", "lib/redisent.rb", "test/redisent_test.rb"]
  s.license           = "MIT"

  s.add_dependency "redis"
  s.add_development_dependency "cutest"
end
