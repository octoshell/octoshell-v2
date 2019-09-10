module Hardware
  class ApplicationController < ::ApplicationController
    #include AuthMayMay
    #protect_from_forgery with: :exception
    layout 'layouts/hardware/application'
  end
end
