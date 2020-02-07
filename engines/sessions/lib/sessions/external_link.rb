module Sessions
  class ExternalLink
    @links = []

    class << self
      attr_accessor :links
      def link?(link)
        links.include?(link)
      end
    end
  end
  if Support.respond_to?(:project_class)
    ExternalLink.links << :project
  end
end
