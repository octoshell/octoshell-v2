module Wikiplus
  class Interface

    class << self
      def handle_view(view, helper, *args)
        send(helper, view, *args)
      end

      def display_wiki_link(view, name)
        page = Wikiplus.engines_links[name].first
        return '' unless page

        view.link_to page.name, view.wikiplus.page_path(page)
      end
    end
  end
end
