require_dependency "pack/application_controller"

module Pack
  class Admin::VersionsController < Admin::ApplicationController
    before_filter :check_abilities, except: [:index, :show]

    # GET /versions
    

    def new  
      @version = Version.new()
      @package = Package.find(params[:package_id])
      @clusters = Core::Cluster.all
      @bs= @clusters.map do |item|
        
       
        
       

        
        {:Bol => false, :name => item.name, :id => item.id, :Active => false   }
        
        
        
      end
    end

    def create

      @version = Version.new(version_params)
      @version.package_id=params[:package_id]
      if @version.save
        @my_params=params
         @my_params[:id]=@version.id.to_s
         cluster_ver_update(@my_params)
        redirect_to admin_package_path(params[:package_id])

      else
        render :new
      end
    end

    def edit
      
      @package = Package.find(params[:package_id])
      @version = Version.includes(clustervers: :core_cluster).find(params[:id])
      @clustervers = @version.clustervers #Clusterver.where(version_id: params[:id])
      @clusters = Core::Cluster.all
      @bs= @clusters.map do |item|
        @clusterver=@clustervers.find_by core_cluster_id: item.id
        if @clusterver
          active_bool= @clusterver.active
        else
          active_bool=false
        end

        
        {:Bol => (@clusterver!=nil), :name => item.name, :id => item.id, :Active => active_bool   }
        
        
        
      end

    end
    
    








    
    def cluster_ver_update(params)
       
      @version = Version.includes(clustervers:[:core_cluster]).find(params[:id])
      @clustervers = @version.clustervers
      @clusters = Core::Cluster.all
     
      
        my_hash= params[:version][:bs]

        
        my_hash.each do |key,value|

            ex=@clustervers.exists?(core_cluster_id: key.to_i)
             y= (value[:exist]=='1')

            #kaminaru
            if ex != y
              
             
            
              if !y
                
                
                @cur=@clustervers.find_by(core_cluster_id: key.to_i)
                @cur.destroy
              else 
                    
                @cur = @version.clustervers.create(core_cluster_id: key.to_i)
                              
              end
            end
              if y

                  @cur=@clustervers.find_by(core_cluster_id: key.to_i )
                  @cur.active=(value[:active]=='1' ) 
                  @cur.save
            
              end
           
             
        
          end
    end


    def update
      
      @version = Version.find(params[:id])
      
      if @version.update(version_params) 
        cluster_ver_update(params) 
        redirect_to admin_package_path(params[:package_id])
      else
        render :edit
      end
    end

    def destroy
      @version = Version.find(params[:id])
      @version.destroy
      redirect_to admin_package_path(params[:package_id])
    end

    private

    def check_abilities
     authorize! :manage, :packages
    end

    def version_params
      params.require(:version).permit(:name, :description,:r_up,:r_down,:bs)
    end
  end
end
