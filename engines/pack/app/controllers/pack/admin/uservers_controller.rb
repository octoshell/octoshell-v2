require_dependency "pack/application_controller"

module Pack
  class Admin::UserversController < Admin::ApplicationController
#    autocomplete :user, :email
    before_action :set_userver, only: [:show, :edit, :update, :destroy]

    # GET /uservers
    

    def get_projects
      
       @out = Core::Project.finder(params[:q])
      render json: { records: @out.page.per(params[:per]), total: @out.count }
    end
    # GET /uservers/1
    def show
    end

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

    # GET /uservers/new
    def new
      @userver = Userver.new
    end

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
                    
                @cur = Userver.create(version_id: key.to_i , user_id:  params[:email],end_lic: value[:date]   )
                if !@cur.save
                  render plain: "ERROR"
                  return
                end                
              end
            end
              if (y && ex)

                  @cur=Userver.find_by  version_id: key.to_i, user_id: params[:email] 
                  @cur.end_lic    = value[:date].to_s 
                  @cur.save
            
              end
           
             
        
          end
          render :nothing => true
    end

    def edit_projects
       
      
      @projvers = Projectsver.where(core_project_id: params[:project] )
      
     
      
        my_hash= params[:projvers]

        
        my_hash.each do |key,value|

            ex=@projvers.exists?(version_id: key.to_i)
            if value[:allow]=='0'
              
                 y=false
            else
                y=true
            end
            #kaminaru
              

            if ex != y
              
             
            
              if !y
                
                
                @cur=@projvers.find_by( version_id: key.to_i )
                @cur.destroy
              else 
                    
                @cur = Projectsver.create(version_id: key.to_i , core_project_id:  params[:project],end_lic: value[:date]  )
                if !@cur.save
                  render plain: "ERROR"
                  return
                end                
              end
            end
              if (y && ex)

                  @cur=Projectsver.find_by  version_id: key.to_i, core_project_id: params[:project] 
                  @cur.end_lic    = value[:date].to_s 
                  @cur.save
            
              end
           
             
        
          end
          render :nothing => true
    end



    def get_vers
      
      
      @package=Package.find(params[:pack])
       print(@package.name)
      @versions=Version.where(package_id:@package.id)
      
      @uservers=Userver.where(user_id: params[:user_id])
      if @versions

         @vers_list= @versions.map do |item|
        
          ex=@uservers.exists?(version_id: item.id)
          if ex
            date=(@uservers.find_by version_id: item.id  ).end_lic
          else
            date="No lic date set"
          end  

        
          {:allow => ex, :name => item.name, :id => item.id, :date => date  }
        
        end  
         
      end

    
      
     
              
         render json: @vers_list
        
    end  


    def get_project_vers
      
      
      @package=Package.find(params[:pack])
       print(@package.name)
      @versions=Version.where(package_id:@package.id)
      
      @projectsvers=Projectsver.where(core_project_id: params[:project_id])
      if @versions

         @vers_list= @versions.map do |item|
        
          ex=@projectsvers.exists?(version_id: item.id)
        
          if ex
            date=(@projectsvers.find_by version_id: item.id  ).end_lic
          else
            date="No lic date set"
          end  

        
          {:allow => ex, :name => item.name, :id => item.id, :date => date   }
        
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
    def create
      @userver = Userver.new(userver_params)

      if @userver.save
        redirect_to @userver, notice: 'Userver was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /uservers/1
    def update
      if @userver.update(userver_params)
        redirect_to @userver, notice: 'Userver was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /uservers/1
    def destroy
      @userver.destroy
      redirect_to uservers_url, notice: 'Userver was successfully destroyed.'
    end

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
