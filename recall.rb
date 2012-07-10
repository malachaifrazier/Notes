# http://net.tutsplus.com/tutorials/ruby/singing-with-sinatra-the-recall-app-2/
require 'rubygems'
require 'sinatra'
require "bundler/setup"
require 'data_mapper'
require 'dm-timestamps'
require 'rack-flash'
require 'sinatra/redirect_with_flash'
require 'pg'


SITE_TITLE = "Thug Notes"
SITE_DESCRIPTION = "Thugs are too busy to 'member stuff."


enable :sessions
use Rack::Flash, :sweep => true

# Display some logs

DataMapper::Logger.new($stdout, :debug)

# Define our DB with the ORM

######
# DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/recall.db")
######

######
# Heroku postgre default port 5432?
######

DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://postgres:danladi@localhost:5433/postgres")
 

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

##########
## Le Routes, :notice fadesOut via jQuery
## Retrieve all Notes from the database
#########


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
  n.attributes = {   
      :content => params[:content],
      :created_at => Time.now.strftime("-%m-%d-%Y %I:%M%p"), #Time.now.strftime("%Y-%m-%d %H:%M")
      :updated_at => Time.now.strftime("-%m-%d-%Y %I:%M%p")
  } 
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
  unless n
    redirect '/', :error => "No Note to be found, son."
  end
  n.attributes = {
      :content => params[:content],
      :complete => params[:complete] ? 1 : 0,
      :updated_at => Time.now.strftime("%m/%d/%Y %I:%M%p")
  }
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

####
# Mark as COMPLETE without going to EDIT View
####

get '/:id/complete' do
  n = Note.get params[:id]
  unless n
    redirect '/', :error => "Hells naw. Error, son."
  end
  n.attributes = {
      :complete => n.complete ? 0 : 1,
      :updated_at => Time.now.strftime("%m/%d/%Y %I:%M%p")
  }
  if n.save
    redirect '/', :notice => "Completed? That's whats up."
  else
    redirect '/', :error => "You say you're done. I don't believe you. Error."
  end
end
