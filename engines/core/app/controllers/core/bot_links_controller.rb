require_dependency "core/application_controller"

module Core
  class BotLinksController < ApplicationController
    skip_before_action :require_login
    before_action :set_bot_link, only: [:show, :edit, :update, :destroy]

    # GET /bot_links
    def index
      @bot_links = BotLink.all
    end

    # GET /bot_links/1
    def show
    end

    # GET /bot_links/new
    def new
      @bot_link = BotLink.new
    end

    # GET /bot_links/1/edit
    def edit
    end

    def generate
      user_id = params[:bot_link_id]

      # disactive other tokens of this user
      BotLinksHelper.disactive_tokens(user_id)

      # create new bot link
      @bot_link = BotLink.new
      @bot_link.token = BotLinksHelper.generate_unique_token
      @bot_link.active = true
      @bot_link.user_id = user_id

      # save new bot
      @bot_link.save
      redirect_to @bot_link, show_notice: true
    end

    # POST /bot_links
    def create
      @bot_link = BotLink.new(bot_link_params)

      if @bot_link.save
        redirect_to @bot_link, show_notice: true
      else
        render :new
      end
    end

    # PATCH/PUT /bot_links/1
    def update
      if @bot_link.update(bot_link_params)
        redirect_to @bot_link, show_notice: true
      else
        render :edit
      end
    end

    # DELETE /bot_links/1
    def destroy
      @bot_link.destroy
      redirect_to bot_links_url, show_notice: true
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_bot_link
        @bot_link = BotLink.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def bot_link_params
        params.require(:bot_link).permit(:user_id, :token, :active)
      end
  end
end
