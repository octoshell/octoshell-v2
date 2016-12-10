require_dependency "pack/application_controller"

module Pack
  class VersionsController < Admin::ApplicationController
    before_filter :check_abilities, except: [:index, :show]

    # GET /versions
    

    def new
      @method="post"    
      @version = Version.new()
      @clusters = Core::Cluster.all
      counter=0
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
        redirect_to package_path(params[:package_id])

      else
        render :new
      end
    end

    def edit
      @method="put"
      @version = Version.find(params[:id])
      @clustervers = Clusterver.where(version_id: params[:id])
      @clusters = Core::Cluster.all
      counter=0
      @bs= @clusters.map do |item|
        counter=counter+1
        ex=@clustervers.exists?(cluster_id: item.id)
        if ex
          active_bool= @clustervers.find_by(cluster_id: item.id).active
        else
          active_bool=false
        end

        
        {:Bol => ex, :name => item.name, :id => item.id, :Active => active_bool   }
        
        
        
      end

     
    end
    def cluster_ver_update(params)
       
      @version = Version.find(params[:id])
      @clustervers = Clusterver.where(version_id: params[:id])
      @clusters = Core::Cluster.all
     
      
        my_hash= params[:version][:bs]

        
        my_hash.each do |key,value|

            ex=@clustervers.exists?(cluster_id: key.to_i)
            if value[:exist]=='0'
              
                 y=false
            else
                y=true
            end
            #kaminaru
              

            if ex != y
              
             
            
              if !y
                
                
                @cur=@clustervers.find_by(cluster_id: key.to_i, version_id: params[:id] )
                @cur.destroy
              else 
                    
                @cur = Clusterver.create(cluster_id: key.to_i, version_id: params[:id] )
                if !@cur.save
                  render plain: "ERROR"
                end                
              end
            end
              if y

                  @cur=@clustervers.find_by(cluster_id: key.to_i, version_id: params[:id] )
                  @cur.active=(value[:active]=='1' ) 
                  @cur.save
            
              end
           
             
        
          end
    end


    def update
      
      @version = Version.find(params[:id])
      
      if @version.update(version_params) 
        cluster_ver_update(params) 
        redirect_to package_path(params[:package_id])
      else
        render :edit
      end
    end

    def destroy
      @version = Version.find(params[:id])
      @version.destroy
      redirect_to package_path(params[:package_id])
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
