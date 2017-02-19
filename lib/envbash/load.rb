require_relative 'read'


module EnvBash
  def EnvBash.load(envbash, into: ENV, override: false, remove: false, **kwargs)
    # read envbash into a hash. This will raise an exception if something goes
    # wrong, and might return nil if missing_ok is true.
    loaded = read(envbash, **kwargs)

    if loaded
      # if the destination is ENV, then replace this temporarily with a hash.
      # this ensures the methods such as merge! are available, and also prevents
      # ENV being in an intermediate state as we add and remove key-value pairs.
      is_env = into.equal? ENV
      into = into.to_h if is_env

      # merge loaded, respecting kwargs remove and override
      into.select! {|k| loaded.include? k} if remove
      loaded.reject! {|k| into.include? k} unless override
      into.merge! loaded

      # if the destination is ENV, replace it wholesale
      ENV.replace into if is_env
    end
  end
end
