require 'drb/drb'
require './some_class'
r = DRbObject.new_with_uri(
  'druby://localhost:5555')
remote_str = r.make_new(String, "123")
remote_str.class # Drb::DrbObject
remote_str.to_i