require "redis"

module Redisent
  def self.new(sentinels, master, options = {})
    sentinels.each do |sentinel|
      begin
        master = find_master(sentinel, master, options)
        return master if master
      rescue Redis::CannotConnectError
      end
    end

    raise Redis::CannotConnectError
  end

  def self.find_master(sentinel, master, options)
    redis = Redis.new(url: sentinel)

    host, port = redis.sentinel("get-master-addr-by-name", master)

    Redis.new(options.merge(:host => host, :port => port))
  end
end
