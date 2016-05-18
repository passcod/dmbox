require 'bundler'
Bundler.require :default

include RethinkDB::Shortcuts
$db = ENV['RETHINK_DB'] || 'test'
$conn = r.connect(
  host: ENV['RETHINK_HOST'] || 'localhost',
  port: ENV['RETHINK_PORT'] || 28015
)

def garbage_spam!
  month_ago = Time.at(Time.now.to_i - 30 * 24 * 60 * 60)
  puts "Deleting all spam older than #{month_ago}"

  status = r.db($db).table('submissions')
    .filter(status: 'spam')
    .filter { |sub| sub['updated_at'].lt month_ago }
    .delete
    .run($conn)

  puts "Deleted #{status['deleted']} spam items"
end

def email_new_items!
  # TODO
end

timers = Timers::Group.new
timers.now_and_every(24 * 60 * 60) do
  garbage_spam!
  email_new_items!
  STDOUT.flush
end

loop do
  timers.wait
end
