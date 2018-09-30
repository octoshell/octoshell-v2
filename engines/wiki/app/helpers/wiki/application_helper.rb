module Wiki
  module ApplicationHelper
    def markdown(text)
      CommonMarker.render_html(text, :DEFAULT).html_safe
    end
  end
end
