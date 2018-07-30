module WithoutPagination
  extend ActiveSupport::Concern
  #pr.arel.ast.cores.any?{ |pr| pr.public_send(:top)  }
  def display_all_applied?
    params[:q] && params[:q][:display_all]
  end

  def without_pagination(name)
    unless display_all_applied?
      relation = instance_variable_get("@#{name}").page(params[:page])
      instance_variable_set("@#{name}", relation)
    end
  end

  included do
    helper_method :display_all_applied?
  end
end
ActionController::Base.include WithoutPagination
