module Wiki
  module ApplicationHelper
    def markdown(text)
      Kramdown::Document.new(text, filter_html: true).to_html.html_safe
    end
  end
end
