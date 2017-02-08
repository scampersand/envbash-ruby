require 'shellwords'


module EnvBash

  FIXUPS = %qw{_ OLDPWD PWD SHLVL}

  class ScriptExitedEarly < StandardError
  end

  def read(envbash, bash: 'bash', env: ENV, missing_ok: false, fixups: FIXUPS)
    # make sure the file exists and is readable.
    # alternatively we could test File.readable?(envbash) but this approach
    # raises Errno::ENOENT or Errno::EACCES which is what we want.
    begin
      File.open(envbash).close
    rescue Errno::ENOENT
      return if missing_ok
      raise
    end

    # construct an inline script which sources env.bash then prints the
    # resulting environment so it can be eval'd back into this process.
    inline = <<-EOT
        set -a
        source #{envbash.shellescape} >/dev/null
        #{Gem.ruby.shellescape} -e 'p ENV'
    EOT

    # run the inline script with bash -c, capturing stdout. if there is any
    # error output from env.bash, it will pass through to stderr.
    # exit status is ignored.
    output = IO.popen(env, ['bash', '-c', inline, :in=>"/dev/null"]).read

    # the only stdout from the inline script should be
    # `p ENV` so there should be no syntax errors eval'ing this. however there
    # will be no output to eval if the sourced env.bash exited early, and that
    # indicates script failure.
    raise ScriptExitedEarly if output.empty?

    # the eval'd output should return a hash.
    nenv = eval(output)

    # there are a few environment variables that vary between this process and
    # running the inline script with bash -c, but are certainly not part of the
    # intentional settings in env.bash.
    for f in fixups
      if env.include? f
        nenv[f] = env[f]
      else
        nenv.delete(f)
      end
    end

    nenv
  end
end
