![SF6](http://www.3dchem.com/inorganics/SF6.jpg)

# SF6

Simple circuit breaking, rate limiting.

### Using

```ruby
require "sf6"

class Numeric
  def seconds
    self
  end

  def minutes
    seconds * 60
  end
end

# rate limit to under 3 every minute
10.times do
  puts "limiter trying..."
  begin
    SF6::Limiter.check("first", 3, 1.minutes) do
      puts "limit success"
    end
  rescue SF6::Unavailable
    puts "limiter unavailable"
  rescue => e
    puts "limiter other"
    puts e
  end
  puts
  sleep 1
end

# circuit break to under 3 failures every minute
10.times do
  puts "breaker trying..."
  begin
    SF6::Breaker.check("first", 3, 1.minutes) do
      puts "breaker success"
      raise("zomg")
    end
  rescue SF6::Unavailable
    puts "breaker unavailable"
  rescue => e
    puts "breaker other"
    puts e
  end
  puts
  sleep 1
end
```

