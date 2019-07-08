require_dependency "reports/application_controller"

module Reports
  class ConstructorController < ApplicationController
    def show
      @alpaca_raw_json = {
        class_options: ModelsList.to_a,
        class_labels: ModelsList.to_a_labels,
        ops: ConstructorService.where
      }
    end

    def class_info
      assocs = params[:assocs]
      associations, associations_labels, attributes, types = ConstructorService.class_info(assocs)
      table_name = eval(assocs.first).table_name
      render json: { attributes: attributes, types: types,
                     associations: associations,
                     associations_labels: associations_labels,
                     table_name: table_name}
    end

    def csv
      params.permit!
      @constructor = ConstructorService.new_for_csv(params.to_h)
      begin
        render json: { data: @constructor.to_csv }
      rescue ActiveRecord::StatementInvalid => e
        render status: 400, plain: e.to_s
      end
    end

    def array
      params.permit!
      begin
        @constructor = ConstructorService.new_for_array(params.to_h)
        render json: { data: @constructor.to_2d_array, page: @constructor.page,
                       pages: @constructor.pages }
      rescue ActiveRecord::StatementInvalid => e
        render status: 400, plain: e.to_s
      end
    end

    def to_sql
      params.permit!
      begin
        @constructor = ConstructorService.new_for_csv(params.to_h)
        render plain: @constructor.to_sql
      rescue ActiveRecord::StatementInvalid => e
        render status: 400, plain: e.to_s
      end
    end

  end
end
