# encoding: UTF-8

require "nokogiri"
require "open-uri"

class String
  def truncate
    return self.gsub(/\n/, ' ').split.join(' ')
  end
end

class Scraper
  def initialize(html)
    @doc = Nokogiri::HTML(html, nil, "iso-8859-1")
    @doc.encoding = 'utf-8'
  end

  def to_markdown
    output = []
    body = @doc.xpath("//body").first
    state = :intro
    tags = body.children
    while tags.any? do
      tag = tags.first
      case state
      when :intro
        if tag.name == "h2"
          output << tag.text.truncate
          output << "=" * tag.text.length
          output << ""
        elsif tag.name == "h4"
          if tag.text.downcase =~ /secci[oó]n/
            state = :section
            next
          end
          output << tag.text.truncate
          output << ""
        elsif tag.name == "hr"
          output << "---"
          output << ""
        elsif tag.name == "p"
          output << tag.text.truncate
          output << ""
        end
        tags.shift
      when :section
        if tag.name == "h4"
          if tag.text.downcase =~ /secci[oó]n/
            output << "#{tag.text.truncate}"
            output << "-" * tag.text.length
            output << ""
          elsif tag.text.downcase =~ /cap[ií]tulo/
            state = :chapter
            next
          else
            output << "#{tag.text.truncate}"
            output << ""
          end
        end
        tags.shift
      when :chapter
        if tag.name == "h4"
          if tag.text.downcase =~ /cap[ií]tulo/
            output << "### #{tag.text.truncate}"
            output << ""
          elsif tag.text.downcase =~ /secci[oó]n/
            state = :section
            next
          else
            # Special chapter
            output << "### #{tag.text.truncate}"
            output << ""
          end
        elsif tag.name == "p"
          # TODO: Allow internal anchors
          if tag.children.first.name == "u"
            anchor = tag.children.first.children.first
            article_number = anchor.text.truncate.gsub(/º/, "")
            article_content = tag.children[1..-1].map{|t| t.text}.join.truncate.gsub(/^[\W]+/, "")
            output << "__#{article_number}__. #{article_content}"
            output << ""
          else
            content = tag.children.map{|t| t.text}.join.truncate
            output << "#{content}"
            output << ""
          end
        elsif tag.name == "table"
          rows = tag.search("./tr")
          rows.each do |row|
            cols = row.search("./td")
            if cols.size == 2 || (cols.size == 3 && !cols[0].text.empty?)
              item_number = cols[0].text.truncate.gsub(/(?:º\)|º|\))/, ".")
              if cols.size == 2
                content_index = 1
              else
                content_index = 2
              end
              item_content = cols[content_index].children.map{|t| t.text}.join.truncate
              if item_number.empty?
                output << "   #{item_content}"
              else
                output << "#{item_number} #{item_content}"
              end
              output << ""
            elsif cols.size == 3
              item_number = cols[1].text.truncate.gsub(/(?:º\)|º|\))/, ".")
              item_content = cols[2].children.map{|t| t.text}.join.truncate
              if item_number.empty?
                output << "      #{item_content}"
              else
                output << "   #{item_number} #{item_content}"
              end
              output << ""
            end
          end
        end
        tags.shift
      when :error
        output << ">>> error"
        output << tag
        tags.shift
      else
        tags.shift
      end
    end
    output.join("\n")
  end
end
