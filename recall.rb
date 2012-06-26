# http://net.tutsplus.com/
#tutorials/ruby/singing-with-sinatra-the-recall-app-2/
require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'rack-flash'
require 'sinatra/redirect_with_flash'

enable :sessions
use Rack::Flash, :sweep => true

SITE_TITLE = "Recall"
SITE_DESCRIPTION = "You, sir, are too busy to member stuff." 

# Define our DB with the ORM

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/recall.db")

class Note
	include DataMapper::Resource
	property :id, Serial
	property :content, Text, :required => true
	property :complete, Boolean, :required => true, :default => false
	property :created_at, DateTime
	property :updated_at, DateTime
end

DataMapper.finalize.auto_upgrade!

# Helper

helpers do
	include Rack::Utils
	alias_method :h, :escape_html
end


# Routes
# Retrieve all Notes from the database

get "/" do 
	@notes = Note.all :order => :id.desc
	@title = "All Notes"
	erb :home
end

# RSS feed

get '/rss.xml' do
	@notes = Note.all :order => :id.desc
	builder :rss
end

#POST Route to add Notes to the database

post "/" do
	n = Note.new
	n.content = params[:content]
	n.created_at = Time.now
	n.updated_at = Time.now
	n.save
	redirect '/'
end

#Edit the Note from [edit] link

get '/:id' do
	@note = Note.get params[:id]
	@title = "Edit note ##{params[:id]}"
	erb :edit
end

#Fake PUT Request only when complete checkbox is true

put '/:id' do
	n = Note.get params[:id]
	n.content = params[:content]
	n.complete = params[:complete] ? 1 : 0
	n.updated_at = Time.now
	n.save
	redirect '/'
end

#Link Deleting the Note. /:id/delete 

get '/:id/delete' do
	@note = Note.get params[:id]
	@title = "Confirm deletion of this Note ##{params[:id]}"	
	erb :delete
end

#Fake Delete Route

delete '/:id' do
	n = Note.get params[:id]
	n.destroy
	redirect '/'
end

# Mark as COMPLETE without going to EDIT View

get '/:id/complete' do
	n = Note.get params[:id]
	n.complete = n.complete ? 0 : 1
	n.updated_at = Time.now
	n.save
	redirect '/'
end











