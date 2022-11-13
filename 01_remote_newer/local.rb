require 'drb/drb'
require './some_class'
r = DRbObject.new_with_uri(
  'druby://localhost:5555'
)
r.make_new(SomeClass)