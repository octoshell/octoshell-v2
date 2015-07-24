module Support
  class Admin::ReplyTemplatesController < Admin::ApplicationController
    def index
      @search = ReplyTemplate.search(params[:q])
      @reply_templates = @search.result(distinct: true).page(params[:page])
    end

    def show
      @reply_template = ReplyTemplate.find(params[:id])
    end

    def new
      @reply_template = ReplyTemplate.new(reply_template_params)
    end

    def create
      @reply_template = ReplyTemplate.new(reply_template_params)
      if @reply_template.save
        redirect_to [:admin, @reply_template]
      else
        render :new
      end
    end

    def edit
      @reply_template = ReplyTemplate.find(params[:id])
    end

    def update
      @reply_template = ReplyTemplate.find(params[:id])
      if @reply_template.update(reply_template_params)
        redirect_to [:admin, @reply_template]
      else
        render :new
      end
    end

    def destroy
      @reply_template = ReplyTemplate.find(params[:id])
      @reply_template.destroy
      redirect_to admin_reply_templates_path
    end

    private

    def reply_template_params
      params.require(:reply_template).permit(:subject, :message)
    end
  end
end
