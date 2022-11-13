require 'drb/drb'
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

some_string = String.new("foo")
some_string.to_i

arr = Array.new([1,2,3])
sum = arr.sum