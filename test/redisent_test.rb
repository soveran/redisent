require File.expand_path("../lib/redisent", File.dirname(__FILE__))

test "basics" do |redis|
  redis = Redisent.new(
    ["redis://localhost:27378/",
     "redis://localhost:27379/",
     "redis://localhost:27380/",
     "redis://localhost:27381/"],
    "server-1", :timeout => 5)

  redis.set("foo", 1)

  assert_equal "1", redis.get("foo")
  assert_equal "6379", redis.info["tcp_port"]
  assert_equal 5.0, redis.client.timeout
end

test "no available sentinel" do
  assert_raise Redis::CannotConnectError do
    redis = Redisent.new(
      ["redis://localhost:27478/",
       "redis://localhost:27479/",
       "redis://localhost:27480/",
       "redis://localhost:27481/"],
      "server-1")
  end
end

test "no available master" do
  assert_raise Redis::CannotConnectError do
    redis = Redisent.new(
      ["redis://localhost:27478/",
       "redis://localhost:27479/",
       "redis://localhost:27480/",
       "redis://localhost:27481/"],
      "server-2")
  end
end
