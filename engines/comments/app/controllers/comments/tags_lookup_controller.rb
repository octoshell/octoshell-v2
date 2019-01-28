require_dependency "comments/application_controller"

module Comments
  class TagsLookupController < ApplicationController
    before_action :check_abilities, only: %i[edit update]

    def index
      q_form
      @q = Tagging.allowed(current_user.id)
      if params[:q]
        context_id = params[:q].delete(:context_id_eq)
        if context_id == 'without_context'
          @q = @q.where(context_id: nil)
        elsif context_id != 'all' && context_id.present?
          @q = @q.where(context_id: context_id)
        end
      end
      @q = @q.ransack(params[:q])
      @taggings = @q.result(distinct: true).page(params[:page]).per(50)
      @q.context_id_eq = context_id
    end

    def show
      @tag = Tag.find(params[:id])
      q_form
      @q = @tag.taggings.join_user_groups(current_user.id)
      if params[:q]
        context_id = params[:q].delete(:context_id_eq)
        if context_id == 'without_context'
          @q = @q.where(context_id: nil)
        elsif context_id != 'all' && context_id.present?
          @q = @q.where(context_id: context_id)
        end
      end
      @q = @q.ransack(params[:q])
      @taggings = @q.result(distinct: true).page(params[:page])
                    .per(10).includes({ user: :profile }, :context)
      @q.context_id_eq = context_id
    end

    def edit
      @tag = Tag.find(params[:id])
    end

    def update
      @tag = Tag.find(params[:id])
      if @tag.update(tag_params)
        redirect_to tags_lookup_path(@tag)
      else
        render :edit
      end
    end

    def destroy
      @tagging = Tagging.where(id: params[:id]).join_user_groups(current_user.id).first
      if @tagging.can_update?(current_user.id)
        @tagging.destroy
        @tag = Tag.find_by(id: @tagging.tag_id)
        if @tag
          redirect_to tags_lookup_path(@tag)
        else
          redirect_to tags_lookup_index_path
        end
      else
        not_authorized
      end
    end


    private

    def tag_params
      params.require(:tag).permit(:name)
    end

    def q_form
      @models_list = []
      ModelsList.to_a.each_with_index do |item, i|
        @models_list << [ModelsList.to_a_labels[i], item]
      end
      @contexts = Context.allow_read(current_user.id).to_a
      @contexts << OpenStruct.new(id: 'all', name: t('comments.tags.q.all'))
      @contexts << OpenStruct.new(id: 'without_context', name: t('comments.tags.q.without_context'))

    end

    def not_authorized
      redirect_to main_app.root_path, alert: t('flash.not_authorized')
    end
  end
end
