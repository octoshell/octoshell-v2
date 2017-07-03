module Pack
	class PackSearch 
		
		NOT_CHANGED = [:deleted_eq,:id_in]
		attr_reader :model_table
		def initialize search_hash,user_id=nil


			@user_id= user_id #Если user_id предоставлен, то это означает, что объект создан в контроллере для пользователей
			@model_table=search_hash.delete(:type) #узнаем, по чему ведется поиск: по версии или пакетам
			@user_access_value=search_hash.delete(:user_access) #Узнаем, ведется ли поиск по доступам конкретного пользователя 
	    	@relation= if @model_table=='packages'


		       
		        @search_hash=Hash[search_hash.except(*NOT_CHANGED)
		          .map{ |key,val| ["versions_#{key}",val]  }].
		          merge search_hash.slice(*NOT_CHANGED)  #Необходимо добавить приставку versions, 
		          #если поиск ведется по пакетам и ,например,  ассоциированным  кластерверсиям вложенных версий
		       	Package
	      	else 
		        
		       @search_hash=search_hash

		        Version.includes({clustervers: :core_cluster},:package)
		        
		    end




		end

		def get_results
			q=@relation.ransack(@search_hash)
			@relation=q.result(distinct: true).order(:id)
			if user_access_applied? 
				remove_joins 
				@relation.user_access @user_access_value
			else
				if @user_id #В этом случае нам обязательно нужно присоединить версии(если поиск ведется по пакетам) и доступы пользователя
					( @relation=@relation.joins("LEFT JOIN pack_versions on pack_versions.package_id=pack_packages.id") ) if model_table=='packages' 
					@relation.merge( Version.left_join_user_accesses( @user_id ) )
				else
					@relation
				end
			end

		
		end

		def remove_joins



			@relation.joins_values.delete_if{ |j| must_delete? j  } 
			# находим все join для объекта класса Relation и удаляем лишние,созданные ранзаком

		end
		def must_delete? j

			if j.class == ActiveRecord::Associations::JoinDependency

				must_delete_dependency? j

			
			else
				raise ArgumentError, 'arg must be ActiveRecord::Associations::JoinDependency' 
			end
		end


		def must_delete_dependency? j
			
			tables=j.aliases.instance_variable_get("@tables")
			
			( tables.length==1) &&  (['pack_versions','pack_accesses'].include? tables.first.table.table_name) ||
			( tables.length==2) &&  'pack_versions' ==tables.first.table.table_name && 'pack_accesses' ==tables.second.table.table_name 

			

		end

		def must_delete_string? j

			
			j.include?('pack_versions') || j.include?('pack_accesses')

		end



		def user_access_applied?
			@user_access_value && @user_access_value!='0' && @user_access_value!=''
		end

	end
end