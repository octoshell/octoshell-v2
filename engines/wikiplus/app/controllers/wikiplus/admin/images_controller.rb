module Wikiplus
  class Admin::ImagesController < Admin::ApplicationController

    before_filter :check_abilities, except: [:index, :show]

    def index
      @images = Image.all
      @img = Image.new
    end

    def show
      @image = Image.find(params[:id])
    end

    def new
      @image = Image.new
    end

    def create
      @image = Image.new(page_params)
      if !@image.save
        flash_message :alert, @image.errors
      end
      redirect_to [:admin, :images] #[:admin, @image]
    end

    def update
      @image = Image.find(params[:id])
      if @image.update(page_params)
        redirect_to [:admin, @image]
      else
        render :edit
      end
    end

    def destroy
      @image = Image.find(params[:id])
      @image.remove_image!
      @image.save
      @image.destroy
      redirect_to admin_images_path
    end

    private

    def check_abilities
      authorize! :manage, :pages
    end

    def page_params
      params.require(:image).permit(:video, :image)
    end

  end
end
