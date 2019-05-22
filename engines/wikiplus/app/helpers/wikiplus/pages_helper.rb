module Wikiplus
  module PagesHelper

  	def show_page(page)
  		#{}"subpage id: #{page.subpages[0]}".html_safe
      l=[]
  		page.subpages.each do |subpage|
  			logger.warn "--- #{subpage.inspect}" 
  			l.append(subpage.test())
        #logger.warn "----1-1--11--11--1-1-1_--1-1-1- #{show_page(subpage)}"
        if show_page(subpage) != []
          l.append(show_page(subpage))
        end
  		end
      return l
  		if page.subpages[0] != nil
  			return "page: #{page.subpages[0].test()} ".html_safe
  		end
  		"<div> hello <b> world</b></div>".html_safe
  	end

    def link_to_image(record)
      if record.image?
        #{}"#{link_to File.basename(record.image.url), record.image.url, target: :blank} #{number_to_human_size(record.image.size)}".html_safe
        k = record.image.url
        #{}"<img src=\"#{k.to_str}\">"
        return k.to_str
      end
    end

  end
end



