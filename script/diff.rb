#!/usr/bin/env ruby

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


puts Compare.new(open(ARGV[0]).read, open(ARGV[1]).read).to_html
