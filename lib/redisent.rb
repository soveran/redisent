require "redic"

class Redisent
  class UnreachableHosts < ArgumentError; end
  class UnknownMaster < ArgumentError; end

  ECONN = [
    Errno::ECONNREFUSED,
    Errno::EINVAL,
  ]

  attr_reader :hosts
  attr_reader :healthy
  attr_reader :invalid
  attr_reader :unknown
  attr_reader :prime
  attr_reader :scout

  def initialize(hosts:, name:, client: Redic, auth: nil)
    @name = name
    @auth = auth

    # Client library
    @client = client

    # Hosts according to availability
    @healthy = []
    @invalid = []
    @unknown = []

    # Last known healthy hosts
    @hosts = hosts

    # Primary client
    @prime = @client.new

    # Scout client
    @scout = @client.new

    explore!
  end

  def url
    @prime.url
  end

  private def explore!
    @unknown = []
    @invalid = []
    @healthy = []

    @hosts.each do |host|
      begin
        @scout.configure(sentinel_url(host))

        sentinels = @scout.call("SENTINEL", "sentinels", @name)

        if RuntimeError === sentinels
          unknown.push(host)
        else
          healthy.push(host)

          sentinels.each do |sentinel|
            info = Hash[*sentinel]

            healthy.push(sprintf("%s:%s", info["ip"], info["port"]))
          end
        end

        @scout.quit

      rescue *ECONN
        invalid.push(host)
      end
    end

    if healthy.any?
      @hosts.replace(healthy)
      @prime.configure(master)
      return true
    end

    if invalid.any?
      raise UnreachableHosts, invalid
    end

    if unknown.any?
      raise UnknownMaster, @name
    end
  end

  def call(*args)
    forward do
      @prime.call(*args)
    end
  end

  def call!(*args)
    forward do
      @prime.call!(*args)
    end
  end

  def queue(*args)
    @prime.queue(*args)
  end

  def commit
    buffer = @prime.buffer

    forward do
      @prime.buffer.replace(buffer)
      @prime.commit
    end
  end

  def forward
    yield
  rescue
    explore!
    retry
  end

  private def sentinel_url(host)
    sprintf("redis://%s", host)
  end

  private def redis_url(host)
    if @auth then
      sprintf("redis://:%s@%s", @auth, host)
    else
      sprintf("redis://%s", host)
    end
  end

  private def master
    hosts.each do |host|
      begin
        @scout.configure(sentinel_url(host))
        ip, port = @scout.call("SENTINEL", "get-master-addr-by-name", @name)

        break redis_url(sprintf("%s:%s", ip, port))
      rescue *ECONN
        $stderr.puts($!.inspect)
      end
    end
  end
end
