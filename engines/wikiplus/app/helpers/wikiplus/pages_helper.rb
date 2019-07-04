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
  		# if page.subpages[0] != nil
  		# 	return "page: #{page.subpages[0].test()} ".html_safe
  		# end
  		# "<div> hello <b> world</b></div>".html_safe
  	end

    def link_to_image(record)
      if record.image?
        k = record.image.url
        return k.to_str
      end
    end

  end
end
