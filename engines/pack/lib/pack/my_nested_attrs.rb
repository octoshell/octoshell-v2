
require "active_support/core_ext/hash/except"
require "active_support/core_ext/object/try"
require "active_support/core_ext/hash/indifferent_access"

module Pack
  module MyNestedAttributes #:nodoc:
    class TooManyRecords < ActiveRecord::ActiveRecordError
    end

    extend ActiveSupport::Concern

    

 
    module ClassMethods
     

      
      def accepts_my_nested_attributes_for(*attr_names)
        

        attr_names.each do |association_name|
          if reflection = _reflect_on_association(association_name)
            reflection.autosave = true
            define_autosave_validation_callbacks(reflection)

            

            type = (reflection.collection? ? :collection : :one_to_one)
            generate_my_association_writer(association_name, type)
          else
            raise ArgumentError, "No association found for name `#{association_name}'. Has it been defined yet?"
          end
        end
      end

      private

        
        def generate_my_association_writer(association_name, type)
          generated_association_methods.module_eval <<-eoruby, __FILE__, __LINE__ + 1
            if method_defined?(:#{association_name}_my_attributes=)
              remove_method(:#{association_name}_my_attributes=)
            end
            def #{association_name}_my_attributes=(attributes)
              assign_my_nested_attributes_for_#{type}_association(:#{association_name}, attributes)
            end
          eoruby
        end
    end

    # Returns ActiveRecord::AutosaveAssociation::marked_for_destruction? It's
    # used in conjunction with fields_for to build a form element for the
    # destruction of this association.
    #
    # See ActionView::Helpers::FormHelper::fields_for for more info.
    
    private

      # Attribute hash keys that should not be assigned as normal attributes.
      # These hash keys are nested attributes implementation details.
      UNASSIGNABLE_KEYS = %w( id _destroy )

      # Assigns the given attributes to the association.
      #
      # If an associated record does not yet exist, one will be instantiated. If
      # an associated record already exists, the method's behavior depends on
      # the value of the update_only option. If update_only is +false+ and the
      # given attributes include an <tt>:id</tt> that matches the existing record's
      # id, then the existing record will be modified. If no <tt>:id</tt> is provided
      # it will be replaced with a new record. If update_only is +true+ the existing
      # record will be modified regardless of whether an <tt>:id</tt> is provided.
      #
      # If the given attributes include a matching <tt>:id</tt> attribute, or
      # update_only is true, and a <tt>:_destroy</tt> key set to a truthy value,
      # then the existing record will be marked for destruction.
     

      # Assigns the given attributes to the collection association.
      #
      # Hashes with an <tt>:id</tt> value matching an existing associated record
      # will update that record. Hashes without an <tt>:id</tt> value will build
      # a new record for the association. Hashes with a matching <tt>:id</tt>
      # value and a <tt>:_destroy</tt> key set to a truthy value will mark the
      # matched record for destruction.
      #
      # For example:
      #
      #   assign_nested_attributes_for_collection_association(:people, {
      #     '1' => { id: '1', name: 'Peter' },
      #     '2' => { name: 'John' },
      #     '3' => { id: '2', _destroy: true }
      #   })
      #
      # Will update the name of the Person with ID 1, build a new associated
      # person with the name 'John', and mark the associated Person with ID 2
      # for destruction.
      #
      # Also accepts an Array of attribute hashes:
      #
      #   assign_nested_attributes_for_collection_association(:people, [
      #     { id: '1', name: 'Peter' },
      #     { name: 'John' },
      #     { id: '2', _destroy: true }
      #   ])
      def assign_my_nested_attributes_for_collection_association(association_name, attributes_collection)
       
        
        options = nested_attributes_options[association_name]
        
        
        unless attributes_collection.is_a?(Hash) || attributes_collection.is_a?(Array)
          raise ArgumentError, "Hash or Array expected, got #{attributes_collection.class.name} (#{attributes_collection.inspect})"
        end

        check_record_limit!(options[:limit], attributes_collection)
         
        if attributes_collection.is_a? Hash
          keys = attributes_collection.keys
          attributes_collection = if keys.include?("id") || keys.include?(:id)
            [attributes_collection]
          else
            attributes_collection.values
          end
        end
       
        association = association(association_name)

        existing_records = if association.loaded?
          association.target
        else
          attribute_ids = attributes_collection.map { |a| a["id"] || a[:id] }.compact
          attribute_ids.empty? ? [] : association.scope.where(association.klass.primary_key => attribute_ids)
        end
        
        attributes_collection.each do |attributes|
          
          if attributes.respond_to?(:permitted?)
            attributes = attributes.to_h
          end
          attributes = attributes.with_indifferent_access

          if attributes["id"].blank?
            unless reject_new_record?(association_name, attributes)
              association.build(attributes.except(*UNASSIGNABLE_KEYS))
            end
          elsif existing_record = existing_records.detect { |record| record.id.to_s == attributes["id"].to_s }
            unless call_reject_if(association_name, attributes)
              # Make sure we are operating on the actual object which is in the association's
              # proxy_target array (either by finding it, or adding it if not found)
              # Take into account that the proxy_target may have changed due to callbacks
              target_record = association.target.detect { |record| record.id.to_s == attributes["id"].to_s }
              if target_record
                existing_record = target_record
              else
                association.add_to_target(existing_record, :skip_callbacks)
              end

              assign_to_or_mark_for_destruction(existing_record, attributes, options[:allow_destroy])
            end
          else
            unless reject_new_record?(association_name, attributes)
              item=association.build(attributes.except(*UNASSIGNABLE_KEYS))
              item.errors.add(:will_be_deleted)
            end
          end
        end
      end

     
  end
  #ActiveRecord::Base.extend MyNestedAttributes::ClassMethods 
  ActiveRecord::Base.include MyNestedAttributes
end


    
