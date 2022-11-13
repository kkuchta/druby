require 'drb/drb'
class RemoteServer
  def foo; puts "foo ran here"; end
end
DRb.start_service(
  'druby://localhost:5555',
  RemoteServer.new
)
DRb.thread.join