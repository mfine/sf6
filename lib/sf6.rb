module SF6

  class Unavailable < StandardError
  end

  module Base

    def reset!(attr)
      data[:timestamps][attr] = 0
      data[:counts][attr] = 0
    end

    private

    def data
      @data ||= {:counts => Hash.new(0), :timestamps => Hash.new(0)}
    end

    def stamp(attr, bucket)
      timestamp = Time.now.to_i / bucket
      data[:counts][attr] = 0 unless data[:timestamps][attr] == timestamp
      timestamp
    end

    def increment(attr, timestamp)
      data[:timestamps][attr] = timestamp
      data[:counts][attr] += 1
    end

    def test(attr, value, &blk)
      if value == 0 || data[:counts][attr] < value
        yield
      else
        raise(Unavailable, attr)
      end
    end
  end

  module Limiter
    extend Base

    def self.check(attr, value, bucket, &blk)
      timestamp = stamp(attr, bucket)
      increment(attr, timestamp)
      test(attr, value) do
        yield
      end
    end
  end

  module Breaker
    extend Base

    def self.check(attr, value, bucket, &blk)
      timestamp = stamp(attr, bucket)
      test(attr, value) do
        begin
          yield
        rescue => e
          increment(attr, timestamp)
          raise
        end
      end
    end
  end
end
