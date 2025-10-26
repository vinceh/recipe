class HtmlToTextConverter
  require 'nokogiri'

  def initialize(html)
    @html = html
  end

  def convert
    doc = Nokogiri::HTML(@html) { |config| config.noblanks }

    # Remove noise elements: scripts, styles, ads, navigation, comments, etc.
    remove_noise_elements(doc)

    # Find main content area - try common recipe containers first
    content = find_main_content(doc)
    return '' unless content

    # Add newlines after block-level elements to preserve structure
    add_structural_newlines(content)

    # Extract pure text and normalize whitespace
    extract_and_normalize_text(content)
  end

  private

  def remove_noise_elements(doc)
    doc.css('script, style, nav, header, footer, aside, iframe,
             noscript, meta, link, svg,
             .ad, .advertisement, .ads, .social-share, .comments,
             .newsletter, .popup, .modal, .sidebar, .widget,
             [class*="nav"], [class*="menu"], [class*="related"],
             [class*="widget"], [class*="banner"], [class*="ad"]').remove
  end

  def find_main_content(doc)
    # Try common recipe containers in priority order
    content = doc.at_css('article,
                          [role="main"],
                          .recipe,
                          [itemtype*="Recipe"],
                          .post-content,
                          .entry-content,
                          main')

    # Fallback to body if nothing specific found
    content ||= doc.at_css('body')

    content
  end

  def add_structural_newlines(content)
    content.css('p, div, li, h1, h2, h3, h4, h5, h6, br, tr, td,
                 article, section, header, footer').each do |elem|
      elem.add_next_sibling(Nokogiri::XML::Text.new("\n", content.document))
    end
  end

  def extract_and_normalize_text(content)
    text = content.text
      .gsub(/[ \t]+/, ' ')           # Multiple spaces/tabs to single space
      .gsub(/\n[ \t]+/, "\n")        # Remove leading spaces after newlines
      .gsub(/\n{3,}/, "\n\n")        # Max 2 consecutive newlines
      .strip

    # Limit content size to 50KB
    text.length > 50_000 ? text[0...50_000] : text
  end
end
