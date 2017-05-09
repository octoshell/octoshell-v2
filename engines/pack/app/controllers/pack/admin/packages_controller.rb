require_dependency "pack/application_controller"

module Pack
  class Admin::PackagesController < Admin::ApplicationController

  
    
    def index
    
      
     @q_form=OpenStruct.new(params[:q])
      @model_table=params[:type] || 'packages'
      model_table= if @model_table=='packages'
       Package.select("pack_packages.*")
      else 
        Version.select("pack_versions.*").includes({clustervers: :core_cluster},:version_options)
      end
      


      if @model_table=='packages' 
        permanent = [:user_access,:deleted_eq]
        q_hash=Hash[@q_form.to_h.except(*permanent)
          .map{ |key,val| ["versions_#{key}",val]  }].
          merge @q_form.to_h.slice(*permanent)  
      else 
        q_hash = @q_form.to_h
        q_hash[:package_deleted_eq] =q_hash[:deleted_eq]
        
      end
     

      @q=model_table.ransack(q_hash)
     
      @records=@q.result(distinct: true).order(:id).page(params[:page]).per(6)
      
    
      respond_to do |format|


        format.html{
          
        } # index.html.erb
        format.js { 
            
            render_paginator(@records,"#{@model_table}_table")
        }
        format.json do
          @packages = Package.finder(params[:q])    
          render json: { records: @packages.page(params[:page]).per(params[:per]), total: @packages.count } 
        end

      end
      
    end
    


    def show
    



      @package = Package.find(params[:id])




      @versions=@package.versions.page(params[:page]).per(@per).includes(clustervers: :core_cluster)

      
      
      
    end

    def new
      @package = Package.new
    end

    def create
      @package = Package.new(package_params)
      if @package.save
        redirect_to admin_package_path(@package.id)
      else
        render :new
      end
    end

    def edit
      @package = Package.find(params[:id])

    end

    def update
      
      @package = Package.find(params[:id])
      
      if @package.update(package_params)
        redirect_to admin_package_path(@package.id)
      else
      
        render :edit
      end
    end

    def destroy
      @package = Package.find(params[:id])
      if @package.deleted
        @package.destroy
      else
        @package.deleted =  true
        @package.save
      end
      redirect_to admin_packages_path
    end

    private

   

    def package_params
      params.require(:package).permit(:name, :folder, :cost,:description,:deleted,:lock_version)   
    end
    def search_params
      params.require(:search).permit(:deleted)
    end
  end
end
