module Support
  class Admin::TagsController < Admin::ApplicationController
    def index
      @search = Tag.search(params[:q])
      @tags = @search.result(distinct: true).page(params[:page])
    end

    def show
      @tag = Tag.find(params[:id])
    end

    def new
      @tag = Tag.new
    end

    def create
      @tag = Tag.new(tag_params)
      if @tag.save
        redirect_to [:admin, @tag]
      else
        render :new
      end
    end

    def edit
      @tag = Tag.find(params[:id])
    end

    def update
      @tag = Tag.find(params[:id])
      if @tag.update(tag_params)
        redirect_to [:admin, @tag]
      else
        render :edit
      end
    end

    def merge
      @tag = Tag.find(params[:tag_id])
      @duplication = Tag.find(params[:tag].delete(:merge_id))
      if @tag.merge_with(@duplication)
        redirect_to @tag
      else
        render :show
      end
    end

    def destroy
      @tag = Tag.find(params[:id])
      @tag.destroy
      redirect_to admin_tags_path
    end

    private

    def tag_params
      params.require(:tag).permit(:name)
    end
  end
end
