require_dependency "pack/application_controller"

module Pack
  class Admin::OptionsCategoryController < Admin::ApplicationController
  	def index

  		#OptionsCategory.create(category: "second")
  		@records=OptionsCategory.page(params[:page]).per(2)
  		respond_to do |format|
  			format.html
  			format.js{
  				 ajax_paginator(@records)
  			}
  		end
  	end
  	def edit_many
  		@records=OptionsCategory.page(params[:page]).per(2)
  		respond_to do |format|
  			format.html
  			format.js{
  				 ajax_paginator(@records,'#form_table')
  			}
  		end
  	end

    
  	def update_many

  		
  		@records=OptionsCategory.where(id: params[:options].keys).to_a
  		
  		params[:options].each do |key,value|

  				 @records.detect{ |r| r.id.to_s == key.to_s}.attributes= value.permit(:category)
  				 
  		end
  		b=true
  		ActiveRecord::Base.transaction do 
  			@records.each do  |r| 
  				if !r.save 
  					raise ActiveRecord::Rollback
  					b=false
  				end 
  			end		
  		end
  		
  		if b
			redirect_to admin_options_category_index_path
		else
			render :edit_many
		end
  			
  		
  		

  	end
  end
end
