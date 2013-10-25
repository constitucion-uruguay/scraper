# encoding: UTF-8

require "nokogiri"
require "open-uri"

class String
  def truncate
    return self.gsub(/\n/, ' ').split.join(' ')
  end
end

class Scraper

  ARTICLE_INDEX_PATTERN = /^(Artículo \d+)\W+/i
  ITEM_INDEX_PATTERN    = /^((\d+|[a-zA-Z]'?))[\.º)\-]+\s/

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
        elsif tag.name == "p"
          output << tag.text.truncate
          output << ""
        end
        tags.shift
      when :section
        if tag.name == "h4"
          if tag.text.downcase =~ /secci[oó]n/
            output << "## #{tag.text.truncate}"
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
            # if it's not a chapter nor a section it's a special section
            # that must me treated as a chapter
            output << "## #{tag.text.truncate}"
            output << ""

            tags.shift
          end
        elsif tag.name == "p"
          # TODO: Allow internal anchors
          output << parse_paragraph_with_article(tag)
          output << ""
        elsif tag.name == "table"
          tag = tag.first_element_child if tag.first_element_child.element? && tag.first_element_child.name == "tbody"
          rows = tag.search("./tr")
          rows.each do |row|
            output << parse_row_with_item(row);
            output << ""
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

  private

  def parse_paragraph_with_article(paragraph)
    text = paragraph.xpath(".//text()").map(&:text).join(" ").truncate;
    text.gsub(ARTICLE_INDEX_PATTERN, '__\1__. ')
  end

  def parse_row_with_item(row)
    text = row.xpath(".//td//text()").map(&:text).join(" ").truncate;
    text.gsub(ITEM_INDEX_PATTERN, '\1) ')
  end

end
