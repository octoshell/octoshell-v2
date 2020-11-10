# coding: utf-8
module Support
  class FieldsController < Support::ApplicationController
    before_action :require_login

    def show

      authorize!(:access, Topic) if params[:admin] == 'true'


      @field = Field.find(params[:id])


      if @field.model_collection?
        admin = params[:admin] == 'true'
        hash = { name: @field.name }
        model_field =  ModelField.all[@field.model_collection.to_sym]

        if model_field.type_source(admin)
          hash[:source] = instance_exec(current_user, &model_field.type_source(admin))
        else
          hash[:field_options] = model_field.type_query(admin).call(current_user).map do |elem|
            { id: elem.id, text: elem.send(model_field.human) }
          end
        end
        render json: hash
      else
        render json: { name: @field.name,
                       field_type: @field.kind,
                       field_options: @field.field_options }
      end
    end
  end
end
