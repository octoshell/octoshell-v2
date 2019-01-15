module Wiki
  module ApplicationHelper
    def markdown(text)
      CommonMarker.render_html(text, [:DEFAULT],[:table,:autolink,:strikethrough]).html_safe
    end
  end
end
