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
        if is_main_title?(tag)
          output << parse_main_title(tag)
        elsif is_section_title?(tag)
          state = :section
          next
        elsif is_main_subtitle?(tag)
          # main subtitle
          output << parse_main_subtitle(tag)
        end
        tags.shift
      when :section
        if is_section_title?(tag)
          output << parse_section_title(tag)
        elsif is_chapter_title?(tag)
          state = :chapter
          next
        elsif is_section_subtitle?(tag)
          # section subtitle
          output << parse_section_subtitle(tag)
        end
        tags.shift
      when :special_section
        if is_special_section_title?(tag)
          output << parse_special_section_title(tag)
        elsif is_special_section_part_title?(tag)
          output << parse_special_section_part_title(tag)
        elsif is_article?(tag)
          output << parse_article(tag)
        elsif is_item_list?(tag)
          output << parse_item_list(tag)
        elsif is_chapter_title?(tag)
          state = :chapter
          next
        elsif is_section_title?(tag)
          state = :section
          next
        end
        tags.shift
      when :chapter
        if is_chapter_title?(tag)
          output << parse_chapter_title(tag)
        elsif is_article?(tag)
          output << parse_article(tag)
        elsif is_item_list?(tag)
          output << parse_item_list(tag)
        elsif is_section_title?(tag)
          state = :section
          next
        elsif is_special_section_title?(tag)
          state = :special_section
          next
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

  def is_main_title?(tag)
    tag.name == "h2"
  end

  def is_main_subtitle?(tag)
    tag.name == "h4" || tag.name == "p"
  end

  def is_section_title?(tag)
    tag.name == "h4" && tag.text =~ /secci[oó]n/i
  end

  def is_section_subtitle?(tag)
    tag.name == "h4"
  end

  def is_chapter_title?(tag)
    tag.name == "h4" && tag.text =~ /cap[ií]tulo/i
  end

  def is_special_section_title?(tag)
    tag.name == "h4" && tag.text =~ /DISPOSICIONES TRANSITORIAS/i
  end

  def is_special_section_part_title?(tag)
    tag.name == "h4" && tag.text =~ /[IVXLCDM]+/i
  end

  def is_article?(tag)
    tag.name == "p"
  end

  def is_item_list?(tag)
    tag.name == "table"
  end

  def parse_main_title(tag)
    tag.text.truncate << "\n" << "=" * tag.text.length << "\n"
  end

  def parse_main_subtitle(tag)
    tag.xpath(".//text()").map(&:text).join(" ").truncate << "\n";
  end

  def parse_section_title(tag)
    "## #{tag.text.truncate}\n"
  end

  def parse_section_subtitle(tag)
    tag.xpath(".//text()").map(&:text).join(" ").truncate << "\n";
  end

  def parse_chapter_title(tag)
    "### #{tag.text.truncate}\n"
  end

  def parse_special_section_title(tag)
    "## #{tag.text.truncate}\n"
  end

  def parse_special_section_part_title(tag)
    "### #{tag.text.truncate}\n"
  end

  def parse_item_list(tag)
    tag = tag.first_element_child if tag.first_element_child.element? && tag.first_element_child.name == "tbody"
    rows = tag.search("./tr")
    output = []
    rows.each do |row|
      output << parse_row_with_item(row) << ""
    end
    output.join("\n")
  end

  def parse_article(paragraph)
    text = paragraph.xpath(".//text()").map(&:text).join(" ").truncate;
    text.gsub(ARTICLE_INDEX_PATTERN, '__\1__. ') << "\n"
  end

  def parse_row_with_item(row)
    text = row.xpath(".//td//text()").map(&:text).join(" ").truncate;
    text.gsub(ITEM_INDEX_PATTERN, '\1) ')
  end

end
