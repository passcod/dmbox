require 'bundler'
Bundler.require :default
require 'tilt/erb'

include RethinkDB::Shortcuts
require_relative 'connect'

configure do
  set bind: '0.0.0.0'
  conn, db = connect!
  set conn: conn
  set db: db
end

get '/' do
  erb :index
end

get '/form' do
  erb :form, locals: { success: !request.query_string.empty? }
end

post '/form' do
  r.db(settings.db).table('submissions').insert({
    raw: request['dm'],
    status: 'todo',
    created_at: Time.new,
    updated_at: Time.new,
    request: {
      host: request.host,
      ip: request.ip,
      referrer: request.referrer,
      secure: request.secure?,
      url: request.url,
      user_agent: request.user_agent,
      xhr: request.xhr?
    }
  }).run(settings.conn)
  redirect to '/form?!'
end
