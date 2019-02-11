class MarkdownService
  def initialize
    @renderer = Redcarpet::Render::HTML.new
    @markdown = Redcarpet::Markdown.new(@renderer)
  end

  def to_html(markdown)
    @markdown.render(markdown)
  end

  def self.to_html(markdown)
    new.to_html(markdown)
  end
end
