#!/usr/bin/env ruby

require 'lib/scraper'
require 'open-uri'

puts Scraper.new(open(ARGV[0])).to_markdown
