require_dependency "pack/application_controller"

module Pack
  class UserversController < ApplicationController
#    autocomplete :user, :email
    before_action :set_userver

   
    def manage_access

      
     
      
      respond_to do |format|

        format.html{
          @pack_names= Package.all.select(:name,:id)
          
        } # index.html.erb
        format.json {  
              @users_json = User.finder(params[:q])
         render json: { records: @users_json.page.per(params[:per]), total: @users_json.count }
          #render :json => @users_json
        }
      end
    end 
    
    def index

      
     
      
      respond_to do |format|

        format.html{
          @pack_names= Package.all.select(:name,:id)
          
        } # index.html.erb
        format.json {  
              @users_json = User.finder(params[:q])
         render json: { records: @users_json.page.per(params[:per]), total: @users_json.count }
          #render :json => @users_json
        }
      end
    end 

    # GET /uservers/new
    

    # GET /uservers/1/edit
    
    def edit
       
      
      @uservers = Userver.where(user_id: params[:email] )
      
     
      
        my_hash= params[:vers]

        
        my_hash.each do |key,value|

            ex=@uservers.exists?(version_id: key.to_i)
            if value[:allow]=='0'
              
                 y=false
            else
                y=true
            end
            #kaminaru
              

            if ex != y
              
             
            
              if !y
                
                
                @cur=@uservers.find_by( version_id: key.to_i )
                @cur.destroy
              else 
                    
                @cur = Userver.create(version_id: key.to_i , user_id:  params[:email]  )
                if !@cur.save
                  render plain: "ERROR"
                  return
                end                
              end
            end
              if y

                 # @cur=@clustervers.find_by(cluster_id: key.to_i, version_id: params[:id] )
                  #@cur.active=(value[:active]=='1' ) 
                  #@cur.save
            
              end
           
             
        
          end
    end
    def get_vers
     
      
      @package=Package.find(params[:pack])
       print(@package.name)
      @versions=Version.where(package_id:@package.id)
      
      @uservers=Userver.where(user_id: params[:user_id])
      if @versions

         @vers_list= @versions.map do |item|
        
          ex=@uservers.exists?(version_id: item.id)
        

        
          {:allow => ex, :name => item.name, :id => item.id   }
        
        end  
         
      end
      
      respond_to do |format|

        format.html{
          
        } 
        format.json {  
              
         render json: @vers_list
          
        }
      end 
    end  
    # POST /uservers
   

    # PATCH/PUT /uservers/1
    
    # DELETE /uservers/1
    

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_userver
       authorize! :manage, :packages
      end

      # Only allow a trusted parameter "white list" through.
      def userver_params
        params.require(:userver).permit(:version_id, :user_id, :end_lic)   
      end
  end
end
