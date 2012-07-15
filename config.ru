require 'dm-postgres-adapter'
require 'bundler'
require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'dm-timestamps'
require 'rack-flash'
require 'sinatra/redirect_with_flash'
require 'pg'

stdout.sync = true

Bundler.require

require './recall'
run Sinatra::Application