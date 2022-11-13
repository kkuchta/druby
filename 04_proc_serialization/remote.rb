require 'drb/drb'
require './block_serializer'

module InvokeMethodWithLogging
  def perform
    result = super
    @msg_id && (puts "remote: #{@msg_id}")
    result
  end
end
class DRb::DRbServer::InvokeMethod
  prepend InvokeMethodWithLogging
end

class RemoteNewer
  def make_new(klass, *rest, **kwargs, &block)
    obj = klass
      .new(*rest, **kwargs, &block)
      .extend(DRb::DRbUndumped)
  end
end
DRb.start_service('druby://localhost:5555', RemoteNewer.new)
DRb.thread.join