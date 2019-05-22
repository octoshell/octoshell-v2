
module Wikiplus
  class ImagesController < ApplicationController

    before_filter :check_abilities, except: [:index, :show]

    def index
      @images = Image.all
    end

    def show
      @image = Image.find(params[:id])
    end

    def new
      @image = Image.new
    end

    def create
      @image = Image.new(page_params)
      if @image.save
        redirect_to @image
      else
        render :new
      end
    end

    def update
      @image = Image.find(params[:id])
      if @image.update(page_params)
        redirect_to @image
      else
        render :edit
      end
    end

    def destroy
      @image = Image.find(params[:id])
      @image.remove_image!
      @image.save
      @image.destroy
      redirect_to images_path
    end

    private

    def check_abilities
      authorize! :manage, :pages
    end

    def page_params
      params.require(:image).permit(:image)
    end

  end
end
