module WithoutPagination
  extend ActiveSupport::Concern
  #pr.arel.ast.cores.any?{ |pr| pr.public_send(:top)  }
  def display_all_applied?
    params[:q] && params[:q][:display_all]
  end
  included do
    helper_method :display_all_applied?
  end
end
ActionController::Base.include WithoutPagination
