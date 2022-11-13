require 'json'
require 'drb/drb'
require './block_serializer'

puts "Loaded app.rb"
class RemoteRunner
  def make_new(klass, *rest, **kwargs, &block)
    klass.new(*rest, **kwargs, &block).extend(DRb::DRbUndumped)
  end
end

# Monkeypatch DRb to log remote method calls
module InvokeMethodWithLogging
  def perform
    result = super
    puts "remote: #{@msg_id}"
    result
  end
end
class DRb::DRbServer::InvokeMethod
  prepend InvokeMethodWithLogging
end

def lambda_handler(event:, context:)
  ts_hostname = event["TSHostname"]

  DRb.start_service("druby://localhost:5555", RemoteRunner.new)
  `
  source /var/task/tskey
  mkdir -p /tmp/tailscale
  /var/runtime/tailscaled --tun=userspace-networking &
  /var/runtime/tailscale up --authkey=${TAILSCALE_AUTHKEY} --hostname=#{ts_hostname}
  `
end