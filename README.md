# envbash

[![gem](https://img.shields.io/gem/v/envbash.svg?style=plastic)][gem]
[![travis](https://img.shields.io/travis/scampersand/envbash-ruby/master.svg?style=plastic)][travis]
[![codecov](https://img.shields.io/codecov/c/github/scampersand/envbash-ruby/master.svg?style=plastic)][codecov]

Ruby gem for sourcing a bash script to augment the environment.

## Rationale

[12-factor apps][12] require
[configuration loaded from the environment][12-config].

That's [easy on a platform like Heroku][heroku-config],
where the environment is preset by the user with commands like
`heroku config:set`. But it's messier in development and non-Heroku
deployments, where the environment might need to be loaded from a file.

This package provides a mechanism for sourcing a Bash script to update
Ruby's environment (`ENV`). There are reasons for using a Bash script
instead of another configuration language:

1. Environment variable keys and values should always be strings. Using a Bash
   script to update the environment enforces that restriction, so there won't
   be surprises when you deploy into something like Heroku later on.

2. Using a script means that the values can be sourced into a Bash shell,
   something that's non-trivial if you use a different config language.

3. For better or worse, using a script means that environment variables can be
   set using the full power of the shell, including reading from other files.

Commonly the external file is called `env.bash`, hence the name of this project.

## Installation

Install from [RubyGems][gem]

    gem install envbash

or in your Gemfile:

    gem 'envbash'

## Usage

Call `EnvBash.load` to source a Bash script into the current Ruby process.
Any variables that are set in the script, regardless of whether they are
explicitly exported, will be added to the process environment.

For example, given `env.bash` with the following content:

```bash
FOO='bar baz qux'
```

This can be loaded into Ruby:

```ruby
require 'envbash'

EnvBash.load('env.bash')

puts ENV['FOO']  #=> bar baz qux
```

## Vagrant

This also works as a [Vagrant][vagrant] plugin to load environment variables for
use in `Vagrantfile`. Putting settings in `env.bash` provides a single source of
development configuration for Vagrant and the application under development.
This makes `env.bash` the ideal place to put development configuration such as
AWS secrets for [vagrant-aws][vagrant-aws] that shouldn't be committed to source
control in Vagrantfile.

To use envbash with Vagrant, install it using Vagrant's plugin system:

```bash
vagrant plugin install envbash
```

Then in Vagrantfile, call it:

```ruby
EnvBash.load('env.bash')
```

There's no need to `require` since Vagrant loads plugins automatically. However
you might want to preface this with a check to make sure the plugin is
available:

```ruby
unless Vagrant.has_plugin? 'envbash'
  raise 'Please run: vagrant plugin install envbash'
end
EnvBash.load('env.bash', missing_ok: true)
```

### Example of AWS secrets in `env.bash`

With this `Vagrantfile`:

```ruby
Vagrant.configure("2") do |config|
  config.vm.provider :aws do |aws, override|
    override.vm.box = "dummy"
    aws.access_key_id = ENV['AWS_ACCESS_KEY_ID']
    aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    aws.keypair_name = ENV['AWS_KEYPAIR_NAME']
    aws.ami = ENV.fetch('AWS_AMI', "ami-7747d01e")
  end
end
```

then the secrets can be put into `env.bash`:

```bash
export AWS_ACCESS_KEY_ID=xxxxxxxxxxxx
export AWS_SECRET_ACCESS_KEY=yyyyyyyyyyyyyyyyyy
export AWS_KEYPAIR_NAME=email@example.com
```

## FAQ

### Should I commit `env.bash` to source control?

No, definitely not. The purpose of `env.bash` is to store development
configuration that isn't suitable for committing to the repository, whether
that's secret keys or developer-specific customizations. In fact, you should add
the following line to `.gitignore`:

```
/env.bash
```

### Is it necessary to explicitly `export` variables in `env.bash`?

No, envbash prefixes sourcing your `env.bash` with `set -a` which causes all
newly-set variables to be exported automatically. If you would rather explicitly
export variables, you can `set +a` at the top of your `env.bash`.

### How do I put a multi-line string into `env.bash`?

You can put newlines directly into a multi-line string in Bash, so for example
this works:

```bash
PRIVATE_KEY="
-----BEGIN RSA PRIVATE KEY-----
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-----END RSA PRIVATE KEY-----"
```

### Does envbash override my environment settings?

By default your local environment settings win, so you can override the content
of `env.bash` by explicitly exporting variables in your shell.

You can change this behavior. This makes sense for a deployed instance that gets
full configuration from `env.bash` and needs to be protected from the calling
environment.

```ruby
EnvBash.load('env.bash', override: true)
```

### Can I remove settings from the environment?

By default envbash doesn't remove settings, but you can change this behavior.

```ruby
EnvBash.load('env.bash', remove: true)
```

This will cause any variables that you explicitly `unset` in `env.bash` to be
removed from Ruby's `ENV` as well.

### How do I source `env.bash` into my guest shell environment?

Assuming that your source directory is available on the default `/vagrant` mount
point in the guest, you can add add this line at the bottom of
`/home/vagrant/.bash_profile`:

```
set -a; source /vagrant/env.bash; set +a
```

Note that this means that settings are loaded on `vagrant ssh` so you need to
exit the shell and rerun `vagrant ssh` to refresh if you change settings.

## Legal

Copyright 2017 [Scampersand LLC][ss]

Released under the [MIT license](https://github.com/scampersand/envbash-ruby/blob/master/LICENSE)

[gem]: https://rubygems.org/gems/envbash
[travis]: https://travis-ci.org/scampersand/envbash-ruby?branch=master
[codecov]: https://codecov.io/gh/scampersand/envbash-ruby/branch/master
[12]: https://12factor.net/
[12-config]: https://12factor.net/config
[heroku-config]: https://devcenter.heroku.com/articles/config-vars
[ss]: https://scampersand.com
[vagrant]: http://www.vagrantup.com
[vagrant-aws]: https://github.com/mitchellh/vagrant-aws
