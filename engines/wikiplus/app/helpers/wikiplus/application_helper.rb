module Wikiplus
  module ApplicationHelper
    def markdown(text)
      CommonMarker.render_html(text, [:DEFAULT],[:table,:autolink,:strikethrough]).html_safe
    end
  end

  def show_page(page)
    "page: #{page.inspect}".html_safe
  end
  

end
