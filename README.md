Redisent
========

Sentinel aware Redis client.

Description
-----------

Redisent is a wrapper for the Redis client that fetches configuration
details from sentinels.

## Usage

Instead of passing a Redis URL, you have to pass an array with the
URLs of your Redis sentinels as the first parameter, then the name
of your master server (as defined in the sentinels configuration) as
the second parameter, and finally a hash of options to be used when
connecting to the master.

```ruby
# List of sentinels.
sentinels = ["localhost:27379",
             "localhost:27380",
             "localhost:27381"]

# Master server name as defined in sentinel.conf.
master = "server-1"

redis = Redisent.new(hosts: sentinels, name: master)
```

If the sentinels can't be reached you will get the exception
`Redisent::UnreachableHosts`. If the master name is unknown, you
will get the exception `Redisent::UnknownMaster`.

## Failover

In case of a failover, it is important that the clients don't engage
with the failed master even if it's restored. For that reason, clients
must connect to the Redis sentinels in order to get the address of the
promoted master, and the way to accomplish that is by using
Redisent.new each time a reconnection is needed.

## Installation

You can install it using rubygems:

```
$ gem install redisent
```
