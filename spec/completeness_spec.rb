# encoding: UTF-8

require 'rspec'
require 'scraper'
require 'helpers/scraper_helper'

class TextOnlyScraper
  include ScraperHelper

  def initialize(filename)
    File.open "spec/data/#{filename}" do |f|
      @doc = Nokogiri::HTML(f, nil, "iso-8859-1")
      @doc.encoding = 'utf-8'
    end
  end

  def extract
    flatten_all_text_descendants(@doc.xpath("//body").first)
  end
end

describe "Completeness tests" do
  FILTER_PATTERN = /[^a-zA-ZáéíóúÁÉÍÓÚüÚ,'\*\d]+/

  context "Constitucion de 1830" do
    let :scraper do
      File.open "spec/data/1830.html" do |f|
        scraper = Scraper.new(f)
      end
    end
    it "should share the same contents" do
      scraper.to_markdown.gsub(FILTER_PATTERN, "").should ==
        TextOnlyScraper.new("1830.html").extract.gsub(FILTER_PATTERN, "")
    end
  end

  context "Constitucion de 1918" do
    let :scraper do
      File.open "spec/data/1918.html" do |f|
        scraper = Scraper.new(f)
      end
    end
    it "should share the same contents" do
      scraper.to_markdown.gsub(FILTER_PATTERN, "").should ==
        TextOnlyScraper.new("1918.html").extract.gsub(FILTER_PATTERN, "")
    end
  end

  context "Constitucion de 1918" do
    let :scraper do
      File.open "spec/data/1918.html" do |f|
        scraper = Scraper.new(f)
      end
    end
    it "should share the same contents" do
      scraper.to_markdown.gsub(FILTER_PATTERN, "").should ==
        TextOnlyScraper.new("1918.html").extract.gsub(FILTER_PATTERN, "")
    end
  end

  context "Constitucion de 1934" do
    let :scraper do
      File.open "spec/data/1934.html" do |f|
        scraper = Scraper.new(f)
      end
    end
    it "should share the same contents" do
      scraper.to_markdown.gsub(FILTER_PATTERN, "").should ==
        TextOnlyScraper.new("1934.html").extract.gsub(FILTER_PATTERN, "")
    end
  end

  context "Constitucion de 1942" do
    let :scraper do
      File.open "spec/data/1942.html" do |f|
        scraper = Scraper.new(f)
      end
    end
    it "should share the same contents" do
      scraper.to_markdown.gsub(FILTER_PATTERN, "").should ==
        TextOnlyScraper.new("1942.html").extract.gsub(FILTER_PATTERN, "")
    end
  end

  context "Constitucion de 1952" do
    let :scraper do
      File.open "spec/data/1952.html" do |f|
        scraper = Scraper.new(f)
      end
    end
    it "should share the same contents" do
      scraper.to_markdown.gsub(FILTER_PATTERN, "").should ==
        TextOnlyScraper.new("1952.html").extract.gsub(FILTER_PATTERN, "")
    end
  end

  context "Constitucion de 1967" do
    let :scraper do
      File.open "spec/data/1967.html" do |f|
        scraper = Scraper.new(f)
      end
    end
    it "should share the same contents" do
      scraper.to_markdown.gsub(FILTER_PATTERN, "").should ==
        TextOnlyScraper.new("1967.html").extract.gsub(FILTER_PATTERN, "")
    end
  end

  context "Constitucion de 2004" do
    let :scraper do
      File.open "spec/data/2004.html" do |f|
        scraper = Scraper.new(f)
      end
    end
    it "should share the same contents" do
      scraper.to_markdown.gsub(FILTER_PATTERN, "").should ==
        TextOnlyScraper.new("2004.html").extract.gsub(FILTER_PATTERN, "")
    end
  end
end
