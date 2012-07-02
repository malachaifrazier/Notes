require 'dm-sqlite-adapter'
require 'bundler'
require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'dm-timestamps'
require 'rack-flash'
require 'sinatra/redirect_with_flash'

Bundler.require

require './recall.rb'
run recall.rb