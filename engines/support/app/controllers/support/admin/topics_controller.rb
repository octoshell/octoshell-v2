module Support
  class Admin::TopicsController < Admin::ApplicationController
    def index
      @search = Topic.search(params[:q])
      @topics = @search.result(distinct: true).page(params[:page])
    end

    def show
      @topic = Topic.find(params[:id])
    end

    def new
      @topic = Topic.new() #topic_params)
    end

    def create
      @topic = Topic.new(topic_params)
      if @topic.save
        redirect_to [:admin, @topic]
      else
        render :new
      end
    end

    def edit
      @topic = Topic.find(params[:id])
    end

    def update
      @topic = Topic.find(params[:id])
      if @topic.update(topic_params)
        redirect_to [:admin, @topic]
      else
        render :edit
      end
    end

    private

    def topic_params
      params.require(:topic).permit(*Topic.locale_columns(:name, :template),
                                    :parent_id, :visible_on_create, tag_ids: [],
                                    field_ids: [], user_topics_attributes: %i[id _destroy required user_id]
                                    )
    end
  end
end
