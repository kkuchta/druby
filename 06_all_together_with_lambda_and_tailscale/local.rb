require 'drb/drb'
require 'securerandom'
require './block_serializer'
$lambda_function_name = "remote-object-runner-RemoteObjectRunnerFunction-DTKRHsGJPw9M"
class Object
  @@old_new = method(:new)
  def self.new(*args, **kwargs, &block)
    contains_recursion = caller.any? { _1 =~ /(drb\/drb)/ }
    if contains_recursion
      @@old_new.unbind.bind(self)[*args, **kwargs, &block]
    else
      # $r.make_new(self, *args, **kwargs, &block)
      remote_new(*args, **kwargs, &block)
    end
  end
  def self.remote_new(*args, **kwargs, &block)
      lambda_hostname = start_lambda
      sleep 4
      uri = "druby://#{lambda_hostname}:5555"
      remote_newer = DRbObject.new_with_uri(uri)
      new_obj = remote_newer.make_new(self, *args, **kwargs, &block)
      new_obj.instance_variable_set(:@uri, uri)
      new_obj
  end
  def self.start_lambda
    hostname = "drb-#{SecureRandom.uuid}"
    puts `aws lambda invoke --invocation-type Event --cli-binary-format raw-in-base64-out --function-name #{$lambda_function_name} --payload '{ "TSHostname": "#{hostname}" }' /tmp/out && cat /tmp/out`
    hostname
  end
end
processed = DATA.read
    .gsub(/\[(.*)\]/, 'Array.new([\1])')
    .gsub(/{([^|]+:[^|]+)}/, 'Hash.new.merge!({\1})')
    .gsub(/"(.*)"/, 'String.new("\1")')
eval(processed, binding, __FILE__, File.readlines(__FILE__).index { _1 =~ /^__END__$/ } + 2)
__END__

arr = [1,2,3]
str = "whatever"

puts arr.map { |x| x * 2}
str.each_char { |c| puts c }