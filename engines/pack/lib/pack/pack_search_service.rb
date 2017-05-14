module Pack
	class PackSearch 
		
		NOT_CHANGED = [:deleted_eq,:id_in]
		attr_reader :model_table
		def initialize search_hash,user_controller


			@user_controller= user_controller
			@model_table=search_hash.delete(:type)
			@user_access_value=search_hash.delete(:user_access)
	    	@relation= if @model_table=='packages'


		       
		        @search_hash=Hash[search_hash.except(*NOT_CHANGED)
		          .map{ |key,val| ["versions_#{key}",val]  }].
		          merge search_hash.slice(*NOT_CHANGED)  
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
				if @user_controller
					( @relation=@relation.joins("LEFT JOIN pack_versions on pack_versions.package_id=pack_packages.id") ) if model_table=='packages'
					@relation.joins("LEFT JOIN pack_accesses on pack_versions.id=pack_accesses.version_id")
				else
					@relation
				end
			end

		
		end

		def remove_joins



			@relation.joins_values.delete_if{ |j| must_delete? j  }

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

			( tables.length==1) &&  (['pack_versions','pack_accesses'].include? tables.first.table.table_name)
			# j.aliases.instance_variable_get("@tables").each do |table|
			 #	return true if 	['pack_versions','pack_accesses'].include? table.table.table_name
			 #end
			
			 #false

		end

		def must_delete_string? j

			
			j.include?('pack_versions') || j.include?('pack_accesses')

		end



		def user_access_applied?
			@user_access_value && @user_access_value!='0' && @user_access_value!=''
		end

	end
end