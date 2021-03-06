require 'date'
require 'bundler'
Bundler.require :default
require 'tilt/erb'

include RethinkDB::Shortcuts
require_relative 'connect'

include ERB::Util

require_relative 'checks'
$checks = Checks.new
def bad?(*args)
  $checks.bad? *args
end

def timeago(*args)
  Jekyll::Timeago::Core.timeago *args
end

username = ENV['AUTH_USER'] || 'admin'
password = ENV['AUTH_PASS'] || (1..24)
  .map{50 + Random.rand(64)}.pack('w*').gsub(/[^\w]/, '')

puts "Username: #{username}\nPassword: #{password}"
use Rack::Auth::Basic, "Restricted Area" do |u, p|
  username == u and password == p
end

configure do
  set bind: '0.0.0.0'
  conn, db = connect!
  set conn: conn
  set db: db
end

def filtering(request)
  q = request.query_string
  if q =~ /all/
    ['all', {}]
  elsif q =~ /done/
    ['done', {status: 'done'}]
  elsif q =~ /spam/
    ['spam', {status: 'spam'}]
  else
    ['normal', Proc.new { |sub| r.and(
      sub['status'].ne('done'),
      sub['status'].ne('spam')
    ) }]
  end
end

get '/' do
  @title = 'Submission dashboard'
  @conn = settings.conn
  @db = r.db(settings.db)

  filter = filtering request
  @showing = filter[0]
  @submissions = @db.table('submissions')
    .filter(filter[1])
    .order_by('updatedAt')
    .run(@conn)

  erb :dash
end

post '/yes' do
  id = request['id']
  r.db(settings.db).table('submissions')
    .get(id)
    .update(status: 'yes')
    .run(settings.conn)

  redirect to '/'
end

post '/no' do
  id = request['id']
  r.db(settings.db).table('submissions')
    .get(id)
    .update(status: 'no')
    .run(settings.conn)

  redirect to '/'
end

post '/done' do
  id = request['id']
  r.db(settings.db).table('submissions')
    .get(id)
    .update(status: 'done')
    .run(settings.conn)

  redirect to '/'
end

post '/spam' do
  id = request['id']
  r.db(settings.db).table('submissions')
    .get(id)
    .update(status: 'spam')
    .run(settings.conn)

  redirect to '/'
end

post '/normal' do
  redirect to '/'
end

post '/show-all' do
  redirect to '/?all'
end

post '/show-done' do
  redirect to '/?done'
end

post '/show-spam' do
  redirect to '/?spam'
end
