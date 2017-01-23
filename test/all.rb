require_relative "helper"

require "stringio"

module Silencer
  @output = nil

  def self.start
    $olderr = $stderr
    $stderr = StringIO.new
  end

  def self.stop
    @output = $stderr.string
    $stderr = $olderr
  end

  def self.output
    @output
  end
end

SENTINEL_HOSTS = [
  "127.0.0.1:27000",
  "127.0.0.1:27001",
  "127.0.0.1:27002",
  "127.0.0.1:27003",
  "127.0.0.1:27004",
]

SENTINEL_BAD_HOSTS = SENTINEL_HOSTS[0,1]
SENTINEL_GOOD_HOSTS = SENTINEL_HOSTS[1,4]

prepare do
  c = Redic.new

  SENTINEL_GOOD_HOSTS.each do |host|
    c.configure(sprintf("redis://%s", host))

    c.call("SENTINEL", "monitor", "master-6379", "127.0.0.1", "6379", "3")
    c.call("QUIT")
  end
end

setup do
  Redic.new.tap do |c|
    c.call("FLUSHDB")
  end
end

test "invalid hosts" do
  assert_raise(Redisent::UnreachableHosts) do
    Redisent.new(hosts: SENTINEL_BAD_HOSTS, name: "master-6379")
  end
end

test "invalid master" do
  assert_raise(Redisent::UnknownMaster) do
    Redisent.new(hosts: SENTINEL_GOOD_HOSTS, name: "master-6380")
  end
end

setup do
  Redisent.new(hosts: SENTINEL_GOOD_HOSTS, name: "master-6379")
end

test "call" do |c|
  assert_equal "PONG", c.call("PING")
end

test "call!" do |c|
  assert_equal "PONG", c.call("PING")
end

test "queue/commit" do |c|
  assert_equal [["PING"]], c.queue("PING")
  assert_equal [["PING"], ["PING"]], c.queue("PING")
  assert_equal ["PONG", "PONG"], c.commit
end

test "retry on connection failures" do |c|
  assert_equal "PONG", c.call("PING")

  # Simulate a server disconnection.
  c.prime.configure(sprintf("redis://%s", SENTINEL_BAD_HOSTS.first))

  assert_equal "PONG", c.call("PING")

  # Simulate a server disconnection.
  c.prime.configure(sprintf("redis://%s", SENTINEL_BAD_HOSTS.first))

  assert_equal [["PING"]], c.queue("PING")
  assert_equal [["PING"], ["PING"]], c.queue("PING")
  assert_equal ["PONG", "PONG"], c.commit
end
