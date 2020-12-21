require_dependency "cloud_computing/application_controller"

module CloudComputing
  class Admin::ItemKindsController < Admin::ApplicationController
    def index
      @item_kinds = ItemKind.order(:lft)
      respond_to do |format|
        format.html
        format.json do
          render json: { records: @item_kinds.page(params[:page])
                                                 .per(params[:per]),
                         total: @item_kinds.count }
        end
      end
    end

    def jstree
      @item_kinds = ItemKind.order(:lft)
      a = @item_kinds.map do |k|
        { id: k.id, text: k.name, parent: k.parent_id || '#' }
      end
      render json: a
    end


    def show
      @item_kind = CloudComputing::ItemKind.find(params[:id])
      respond_to do |format|
        format.html
        format.json { render json: @item_kind }
      end
    end

    def create
      @item_kind = CloudComputing::ItemKind.new(item_kind_params)
      if @item_kind.save
        render plain: t('.added_successfully', kind: @item_kind.to_s)
        # respond_with(@item_kind, status: 201, default_template: :show)
      else
        render plain: @item_kind.errors.full_messages.join('. '), status: 422
      end
    end

    def edit
      @item_kind = CloudComputing::ItemKind.find(params[:id])
    end

    def load_templates
      load_virtual_machine_item_kind

      results = @item_kind.load_templates
      unless results[0]
        redirect_to [:admin, @item_kind], flash: { error: results.slice(1..-1) }
      end

      strings = t('.added_items')
      results.slice(1..-1).each do |item|
        strings += '<br>'
        string = "id: #{item.id}, name: #{item.name}, nebula_id: #{item.identity}"
        strings += helpers.link_to(string, [:admin, item])
      end

      redirect_to [:admin, @item_kind], flash: { info: strings.html_safe }
    end

    def add_necessary_attributes
      load_virtual_machine_item_kind
      message = @item_kind.my_and_descendant_items.where
                          .not(identity: nil).map do |item|
        results = CloudComputing::OpennebulaTask.add_necessary_attributes(item.identity)
        link = helpers.link_to("\##{item.id}", [:admin, item])
        success = results[0]
        if success
          [t('.updated_successfully'), link]
        else
          [t('.errors_found'), link, results.slice(1..-1)]
        end.join(' | ')
      end.join('<br>')
      redirect_to [:admin, @item_kind], flash: { info: message.html_safe }
    end

    def edit_all
    end


    def update
      @item_kind = CloudComputing::ItemKind.find(params[:id])
      respond_to do |format|
        format.html do
          if @item_kind.update(item_kind_params)
            redirect_to [:admin, @item_kind]
          else
            render :edit
          end
        end
        format.text do
          if @item_kind.update(item_kind_params)
            render plain: t('.updated_successfully', kind: @item_kind.to_s)
          else
            render plain: @item_kind.errors.full_messages.join('. '), status: 422
          end
        end
      end
    end

    # def update
    #   @item_kind = CloudComputing::ItemKind.find(params[:id])
    #   if @item_kind.update(item_kind_params)
    #     redirect_to [:admin, @item_kind]
    #   else
    #     render :edit
    #   end
    # end

    def destroy
      @item_kind = CloudComputing::ItemKind.find(params[:id])
      @item_kind.destroy!
      render plain: t('.destroyed_successfully', kind: @item_kind.to_s)
    end

    private

    def load_virtual_machine_item_kind
      @item_kind = CloudComputing::ItemKind.find(params[:id])

      unless @item_kind.virtual_machine?
        redirect_to [:admin, @item_kind], flash: { error: 'errors' }
        return
      end
    end


    def item_kind_params
      #Order is of params is important
      params.require(:item_kind).permit(*CloudComputing::ItemKind
                                           .locale_columns(:name, :description),
                                           :parent_id,:id, :name, :child_index,
                                           :name, :cloud_type,
                                           conditions_attributes: %i[id min max
                                           to_type to_id kind _destroy])
    end
  end
end
