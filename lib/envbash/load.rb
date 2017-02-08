require_relative 'read'


module EnvBash
  def load(envbash, into: ENV, override: false, remove: false, **kwargs)
    loaded = read_envbash(envbash, **kwargs)
    if loaded
      into.select! {|k| loaded.include? k} if remove
      loaded.reject! {|k| into.include? k} unless override
      into.merge! loaded
    end
  end
end
