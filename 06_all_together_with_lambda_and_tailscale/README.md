# How to run all this

1. Sign up for Tailscale - the free plan is fine. Install Tailscale on your laptop and enable it. In the tailscale admin UI, generate an ephemeral key.
1. Add a file named `tskey` to remote-object-runner/remote-object-runner/ - it should contain `export TAILSCALE_AUTHKEY="..."` with a valid tailscale ephemeral auth key.
1. Run `sam build`.
1. Run `sam deploy --resolve-image-repos`. Note a few things from the output:

- Note the ECR repo name. It'll be under `deployment image repository` and look something like `3456789012.dkr.ecr.us-west-2.amazonaws.com/remoteobjectrunner9134de11/remoteobjectrunnerfunctione5203094repo`
- Note the value for `RemoteObjectRunnerFunction` in the output - you'll need the function name. The output should look something like `arn:aws:lambda:us-west-2:1234567890:function:remote-object-runner-RemoteObjectRunnerFunction-BNAtiz1oUOaI` - you want to grab everything after `function:`.

1. Open `local.rb` and change `$lambda_function_name` to be your function name.
2. Open samconfig.toml and set `image_repositories` to `RemoteObjectRunnerFunction=your_ecr_rep_here`
