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
      @topic.first=
      if @topic.update(topic_params)
        redirect_to [:admin, @topic]
      else
        render :edit
      end
    end

    private

    def topic_params
      params.require(:topic).permit(:name, :parent_id, :tag_ids => [], :field_ids => [])
    end
  end
end
