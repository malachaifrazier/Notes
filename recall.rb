# http://net.tutsplus.com/tutorials/ruby/singing-with-sinatra-the-recall-app-2/
require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'dm-timestamps'
require 'rack-flash'
require 'sinatra/redirect_with_flash'

SITE_TITLE = "Thug Notes"
SITE_DESCRIPTION = "Thugs are too busy to 'member stuff."


enable :sessions
use Rack::Flash, :sweep => true

# Display some logs

DataMapper::Logger.new($stdout, :debug)

# Define our DB with the ORM

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/recall.db")

######
# Class/Models
######

class Note
  include DataMapper::Resource
  property :id, Serial
  property :content, Text, :required => true
  property :complete, Boolean, :required => true, :default => false
  property :created_at, DateTime
  property :updated_at, DateTime
  property :deleted_at, ParanoidDateTime #Don't REALLY destroy a table row
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
  if @notes.empty?
    flash[:error] = "No notes, thug. Add some below!"
  end
  erb :home
end

##########
## RSS feed
##########
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
  if n.save
    redirect '/', :notice => 'Note created successfully, thug.'
  else
    redirect '/', :error => 'Fail whale. Try again.'
  end
end

#Edit the Note from [edit] link

get '/:id' do
  @note = Note.get params[:id]
  @title = "Edit note ##{params[:id]}"
  if @note
    erb :edit
  else
    redirect '/', :error => "Nope. Can't find that note, champ."
  end
end

#Fake PUT Request only when complete checkbox is true

put '/:id' do
  n = Note.get params[:id]
  n.content = params[:content]
  n.complete = params[:complete] ? 1 : 0
  n.updated_at = Time.now
  if n.save
    redirect '/', :notice => "Note updated thuggishly."
  else
    redirect '/', :error => 'Update failed, son.'
  end
end

#Link Deleting the Note. /:id/delete

get '/:id/delete' do
  @note = Note.get params[:id]
  @title = "Straight up delete this thug ass note ##{params[:id]}"
  if @note
    erb :delete
  else
    redirect '/', :error => "Nope. Can't find that note, chief."
  end
end

#Fake Delete Route

delete '/:id' do
  n = Note.get params[:id]
  if n.destroy
    redirect '/', :notice => "Hurray! The note is dead!"
  else
    redirect '/', :error => "Hells naw, error deleting note."
  end
end

# Mark as COMPLETE without going to EDIT View
####
# TODO=> :notice should vanish when no longer complete
####

get '/:id/complete' do
  n = Note.get params[:id]
  n.complete = n.complete ? 0 : 1
  n.updated_at = Time.now
  if n.save
    redirect '/', :notice => "Completed? That's whats up."
  else
    redirect '/', :error => "You say you're done. I don't believe you. Error."
  end
end
