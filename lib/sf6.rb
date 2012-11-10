module SF6

  def self.stamp(data, attr, bucket)
    timestamp = Time.now.to_i / bucket
    data[:counts][attr] = 0 unless data[:timestamps][attr] == timestamp
    timestamp
  end

  def self.increment(data, attr, timestamp)
    data[:timestamps][attr] = timestamp
    data[:counts][attr] += 1
  end

  def self.test(data, attr, value, &blk)
    if value == 0 || data[:counts][attr] < value
      yield
    else
      raise(Error::Unavailable, attr)
    end
  end

  module Limiter

    def self.data
      @data ||= {counts: Hash.new(0), timestamps: Hash.new(0)}
    end

    def self.check(attr, value, bucket, &blk)
      timestamp = stamp(data, attr, bucket)
      increment(data, attr, timestamp)
      test(data, attr, value) do
        yield
      end
    end
  end

  module Breaker

    def self.data
      @data ||= {counts: Hash.new(0), timestamps: Hash.new(0)}
    end

    def self.check(attr, value, bucket, &blk)
      timestamp = stamp(data, attr, bucket)
      test(data, attr, value) do
        begin
          yield
        rescue => e
          increment(data, attr, timestamp)
          raise
        end
      end
    end
  end
end
