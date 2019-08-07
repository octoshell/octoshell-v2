module Wikiplus
  module PagesHelper

  	def show_page(page)
      l=[]
  		page.subpages.each do |subpage|
  			l.append(subpage.test())
        if show_page(subpage) != []
          l.append(show_page(subpage))
        end
  		end
      return l
  	end

    def link_to_image(record)
      if record.image?
        k = record.image.url
        return k.to_str
      end
    end

    def nested_list(elements, &block)
      return "" if elements.blank?
      html = '<ul>'
      elements.each do |el|
        html << "<li id='element_#{el.id}' class=\"hlist\">"
        html << capture(el,&block)
        html << nested_list(el.subpages, &block)
        html << '</li>'
      end
      html << '</ul>'
      html.html_safe
    end
  end
end
