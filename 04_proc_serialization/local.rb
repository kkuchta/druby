require 'drb/drb'
require './block_serializer'
$r = DRbObject.new_with_uri('druby://localhost:5555')
class Object
  @@old_new = method(:new)
  def self.new(*args, **kwargs, &block)
    contains_recursion = caller.any? { _1 =~ /(drb\/drb)/ }
    if contains_recursion
      @@old_new.unbind.bind(self)[*args, **kwargs, &block]
    else
      $r.make_new(self, *args, **kwargs, &block)
    end
  end
end

arr = Array.new([1,2,3])
arr.each { |i| puts i }