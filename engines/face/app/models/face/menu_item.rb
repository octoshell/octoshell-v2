module Face
  class MenuItem
    include ActiveModel::Model

    attr_accessor :name, :url, :regexp

    def active?(current_url)
      if regexp.present?
        regexp =~ current_url
      else
        url == current_url
      end
    end
  end
end
