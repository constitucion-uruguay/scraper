module ScraperHelper
  def truncate_spaces(text)
    text.gsub(/\n/, ' ').split.join(' ')
  end

  def flatten_all_text_descendants(tag)
    truncate_spaces tag.xpath(".//text()").map(&:text).join(" ")
  end
end
