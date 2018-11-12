class UntrackedMachinesList
  def initialize(redis)
    @redis = redis
    @key = 'untracked_machines'
  end

  def set(list)
    @redis.connection do |r|
      r.del(@key)

      Array(list).each do |name|
        r.sadd(@key, name)
      end
    end
  end

  def add(list)
    @redis.connection do |r|
      Array(list).each do |name|
        r.sadd(@key, name)
      end
    end
  end

  def get
    @redis.connection do |r|
      r.smembers(@key) || []
    end
  end
end
