require_dependency "pack/application_controller"

module Pack
  class Admin::OptionsCategoriesController < Admin::ApplicationController
  	def index

  		@records=OptionsCategory.page(params[:page]).per(2)
  		respond_to do |format|
  			format.html
  			format.js{
  				 render_paginator(@records)
  			}
        format.json do

        
        @records = OptionsCategory.where("lower(category) like lower(:q)", q: "%#{params[:q].mb_chars}%") 
        render json: { records: @records.page(params[:page])
          .per(params[:per]).map{ |v|  {text: v.category, id: v.category}  }, total: @records.count }
        end
  		end
  	end
  	

    def new  
      @option = OptionsCategory.new
      
    end

    def create
      @option = OptionsCategory.new
      if @option.update(option_params) 
       
        
        redirect_to admin_options_category_path(@option)

      else
        
        render :new
      end
    end

    def edit
       
        @option = OptionsCategory.find(params[:id])

    end

    def show 
    	 @option = OptionsCategory.find(params[:id])
    end

    def update
      
      @option = OptionsCategory.find(params[:id])
      
      if @option.update(option_params)
        redirect_to admin_options_category_path(@option)
      else
      
        render :edit
      end
    end

   	def destroy

      @option = OptionsCategory.find(params[:id])
      @option.destroy
      redirect_to admin_options_categories_path

    end

    private


    
    def option_params
    	params.require(:options_category).permit(:category)
    end
    


	end
end
