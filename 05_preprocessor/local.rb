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
processed = DATA.read
    .gsub(/\[(.*)\]/, 'Array.new([\1])')
    .gsub(/{([^|]+:[^|]+)}/, 'Hash.new.merge!({\1})')
    .gsub(/"(.*)"/, 'String.new("\1")')
eval(processed, binding, __FILE__, File.readlines(__FILE__).index { _1 =~ /^__END__$/ } + 2)
__END__

arr = [1,2,3]
hash = {a: 1, b: 2}
str = "whatever"

hash.each_key { |k| puts k}
puts arr.map { |x| x * 2}
str.each_char { |c| puts c }