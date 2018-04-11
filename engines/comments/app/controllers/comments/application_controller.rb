module Comments
  class ApplicationController < ActionController::Base
    layout 'layouts/comments/application'
    rescue_from MayMay::Unauthorized, with: :not_authorized
    before_filter :require_login

    def render_paginator(locals)
      locals.reverse_merge!(partial: 'table',
                            table: '#table_records',
                            paginator: '#ajax_paginator')
      locals[:extra_options] = locals.except(:partial, :table, :paginator, :records)
      locals[:records] = { records: locals.delete(:records) } unless locals[:records].is_a? Hash
      render 'helpers/render_paginator', format: :js, locals: locals
    end

    def not_authorized
      redirect_to main_app.root_path, alert: t('flash.not_authorized')
    end

    def not_authenticated
      redirect_to main_app.root_path, alert: t('flash.not_logged_in')
    end

    def ransackable_params
      attrs = %i[created_at_lt created_at_gt updated_at_gt updated_at_lt]
      params.require(:q).permit(attrs)
    end
  end
end
