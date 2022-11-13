require 'drb/drb'
remote = 
  DRbObject.new_with_uri(
    'druby://localhost:5555'
  )
remote.foo