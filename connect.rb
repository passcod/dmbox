include RethinkDB::Shortcuts

def deets
  {
    host: ENV['RETHINK_HOST'] || 'localhost',
    port: ENV['RETHINK_PORT'] || 28015,
    db: ENV['RETHINK_DB'] || 'test'
  }
end

def connect!
  10.times do |n|
    puts "Attempting (#{n}) to connect..."
    STDOUT.flush
    begin
      return [try_connect, deets[:db]]
    rescue Exception => e
      puts "Failed to connect, retrying in #{n ** 2}s"
      puts e
      STDOUT.flush
      sleep n ** 2
    end
  end

  puts "Failed to connect, bowing out in disgrace."
  STDOUT.flush
  exit 1
end

def try_connect
  r.connect(host: deets[:host], port: deets[:port])
end
