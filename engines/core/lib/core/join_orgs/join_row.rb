module Core
  module JoinOrgs
    class JoinRow
      def initialize(row)
        @row = row
        @org_id, @org_name, @dep_id, @dep_name,
        @rep_org_id, @rep_dep_id, @rep_org_name, @rep_dep_name = *row
        puts "Proccessing #{row}"
      end

      def find
        @model_instance = if @dep_id
                           Organization.find(@org_id)
                           OrganizationDepartment.find(@dep_id)
                         else
                           Organization.find(@org_id)
                         end

      end

      # Нужно при слиянии подразделения с корневой организацией
      def to_org_x_nil
        @rep_org_id ? @rep_org_id : @org_id
      end

      def case_rep_id
        case @rep_dep_id
        when Integer
          if @rep_dep_name
            OrganizationDepartment.find(@rep_dep_id)
                                  .update!(name: @rep_dep_name, checked: true)
          end
          [:merge_to_existing_department!, to_org_x_nil, @rep_dep_id]
        when 'x'
          if @rep_dep_name
            raise ArgumentError,
                  "При слияние с организацией имя подразделения замены
                   должно быть пустым: #{@row.inspect}"
          end
          [:merge_to_organization!, to_org_x_nil]
        when nil
          if @rep_dep_name
            [:merge_to_new_department!, @rep_org_id, @rep_dep_name]
          elsif @rep_org_id.is_a? Integer
            [:merge_to_new_department!, @rep_org_id]
          elsif @rep_org_id == 'x'
            unknown = Organization.create_or_find_unknown
            [:merge_to_organization!, unknown.id]
          else
            puts "Strange input #{@row}".red
            :"don't update"
          end
        else
          raise ArgumentError,
                "Неверное значение в поле замена подразделения: #{@row.inspect}"
        end
      end

      def choose_method
        if @rep_org_id && @model_instance.is_a?(Organization)

        end
        # if @model_instance.is_a?(Organization) && !@model_instance.city ||
        #    @model_instance.is_a?(OrganizationDepartment) && !@model_instance.organization.city
        #   puts "NO CITY IN organization with id=#{@model_instance.id}".red
        #   return
        # end

        if @rep_org_name
          Organization.find(to_org_x_nil).update!(name: @rep_org_name, checked: true)
        end
        if @rep_org_id || @rep_dep_id
          case_rep_id
        else
          if @rep_dep_name
            OrganizationDepartment.find(@dep_id).update!(name: @rep_dep_name,
                                                         checked: true)
          elsif @dep_id
            OrganizationDepartment.find(@dep_id).update!(checked: true)
          end
          :"don't update"
        end
      end

      def apply_method
        find
        args = choose_method
        @model_instance.send(*args) unless args == :"don't update"
      end
    end
  end
end
