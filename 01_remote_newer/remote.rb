require 'drb/drb'
require './some_class'
class RemoteNewer
  def make_new(klass)
    klass.new()
  end
end
DRb.start_service('druby://localhost:5555', RemoteNewer.new)
DRb.thread.join