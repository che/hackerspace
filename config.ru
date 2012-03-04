# encoding: utf-8

require 'rubygems'
require File.dirname(File.expand_path(__FILE__)) + '/lib/hackerspace'


HACKERSPACE.init

map HACKERSPACE::SEPARATOR do
  run HACKERSPACE::Site
end