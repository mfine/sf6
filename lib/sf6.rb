module SF6

  class Unavailable < StandardError
  end

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
      raise(Unavailable, attr)
    end
  end

  def self.reset!(data, attr)
    data[:timestamps][attr] = 0
    data[:counts][attr] = 0
  end

  module Limiter

    def self.data
      @data ||= {:counts => Hash.new(0), :timestamps => Hash.new(0)}
    end

    def self.check(attr, value, bucket, &blk)
      timestamp = SF6.stamp(data, attr, bucket)
      SF6.increment(data, attr, timestamp)
      SF6.test(data, attr, value) do
        yield
      end
    end

    def self.reset!(attr)
      SF6.reset!(data, attr)
    end
  end

  module Breaker

    def self.data
      @data ||= {:counts => Hash.new(0), :timestamps => Hash.new(0)}
    end

    def self.check(attr, value, bucket, &blk)
      timestamp = SF6.stamp(data, attr, bucket)
      SF6.test(data, attr, value) do
        begin
          yield
        rescue => e
          SF6.increment(data, attr, timestamp)
          raise
        end
      end
    end

    def self.reset!(attr)
      SF6.reset!(data, attr)
    end
  end
end
