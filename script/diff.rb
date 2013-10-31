#!/usr/bin/env ruby
# encoding: UTF-8

require 'lib/scraper'
require 'open-uri'
require 'htmldiff'
require 'kramdown'

class Compare
  include HTMLDiff

  def initialize(file1, file2)
    @html1 = Kramdown::Document.new(file1).to_html
    @html2 = Kramdown::Document.new(file2).to_html
  end

  def to_html
    diff @html1, @html2
  end
end

file1 = File.open(ARGV[0])
file2 = File.open(ARGV[1])

puts Compare.new(file1.read, file2.read).to_html

file1.close
file2.close
