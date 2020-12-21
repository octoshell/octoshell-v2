module CloudComputing
  class OpennebulaTask
    def self.add_necessary_attributes(template_id)
      results = OpennebulaClient.template_info(template_id)
      return results unless results[0]

      public_key_path = get_setting(:public_key_path)
      public_key = File.read(public_key_path)
      context = Hash.from_xml(results[1])['VMTEMPLATE']['TEMPLATE']['CONTEXT']
      context = context.merge('USER' => 'root',
                              'SSH_PUBLIC_KEY' => public_key)
      OpennebulaClient.update_context_for_template(template_id, context)
    end

    def self.instantiate_vm(position)
      template_id = position.item.identity
      results = OpennebulaClient.template_info(template_id)
      return results unless results[0]

      hash = {}
      hash['DISK'] = Hash.from_xml(results[1])['VMTEMPLATE']['TEMPLATE']['DISK']
      hash_from_position(hash, position)
      value_string = to_value_string(hash, "\n")
      (1..position.amount).map do
        n_i = position.nebula_identities.create!
        name = "#{position.holder.id}-#{position.id}-#{n_i.id}"
        results = OpennebulaClient.instantiate_vm(template_id, name, value_string)
        if results[0]
          unless n_i.update(identity: results[1])
            results << n_i.errors.to_h
          end
          n_i.api_logs.create!(log: results, position: n_i.position)
        else
          n_i.destroy
          position.api_logs.create!(log: results)

        end
        results
      end
    end

    def self.to_value_string(hash, delim)
      hash.map do |key, value|
        if value.is_a? Hash
          "#{key}=[#{to_value_string(value, ',')}]"
        else
          "#{key}=\"#{value}\""
        end
      end.join(delim)
    end

    def self.hash_from_position(hash, position)
      position.resource_positions.with_identity.each do |r_p|
        assign_identity(hash, r_p.resource.resource_kind.identity, r_p.value)
      end
      position.item.resources.where(editable: false).each do |resource|
        assign_identity(hash, resource.resource_kind.identity, resource.value)
      end
      hash
    end

    def self.assign_identity(hash, identity, value)
      if identity == 'MEMORY'
        hash['MEMORY'] = (value * 1024).to_i
      elsif identity == 'DISK=>SIZE'
        hash['DISK'] ||= {}
        hash['DISK']['SIZE'] = value.to_i * 1024
      elsif identity == 'CPU'
        hash['CPU'] = value.to_i
      end
    end

    def self.get_setting(value)
      settings_hash = Rails.application.secrets.cloud_computing || {}
      settings_hash[value]
    end

  end
end
