require_dependency "cloud_computing/application_controller"

module CloudComputing::Admin
  class TemplateKindsController < CloudComputing::Admin::ApplicationController
    def index
      @template_kinds = CloudComputing::TemplateKind.order(:lft)
      respond_to do |format|
        format.html do
          render 'cloud_computing/template_kinds/index'
        end
        format.json do
          render json: { records: @template_kinds.page(params[:page])
                                                 .per(params[:per]),
                         total: @template_kinds.count }
        end
      end
    end

    def jstree
      @template_kinds = CloudComputing::TemplateKind.order(:lft)
      a = @template_kinds.map do |k|
        { id: k.id, text: k.name, parent: k.parent_id || '#' }
      end
      render json: a
    end


    def show
      @template_kind = CloudComputing::TemplateKind.find(params[:id])
      respond_to do |format|
        format.html do
          render 'cloud_computing/template_kinds/show'
        end
        format.json { render json: @template_kind }
      end
    end

    def create
      @template_kind = CloudComputing::TemplateKind.new(template_kind_params)
      if @template_kind.save
        render plain: t('.added_successfully', kind: @template_kind.to_s)
        # respond_with(@template_kind, status: 201, default_template: :show)
      else
        render plain: @template_kind.errors.full_messages.join('. '), status: 422
      end
    end

    def edit
      @template_kind = CloudComputing::TemplateKind.find(params[:id])
    end

    def load_templates
      load_virtual_machine_template_kind

      results = @template_kind.load_templates
      unless results[0]
        redirect_to [:admin, @template_kind], flash: { error: results.slice(1..-1) }
      end

      strings = t('.added_templates')
      results.slice(1..-1).each do |template|
        strings += '<br>'
        string = "id: #{template.id}, name: #{template.name}, nebula_id: #{template.identity}"
        strings += helpers.link_to(string, [:admin, template])
      end

      redirect_to [:admin, @template_kind], flash: { info: strings.html_safe }
    end

    def add_necessary_attributes
      load_virtual_machine_template_kind
      message = @template_kind.my_and_descendant_templates.where
                          .not(identity: nil).map do |template|
        results = CloudComputing::OpennebulaTask.add_necessary_attributes(template.identity)
        link = helpers.link_to("\##{template.id}", [:admin, template])
        success = results[0]
        if success
          [t('.updated_successfully'), link]
        else
          [t('.errors_found'), link, results.slice(1..-1)]
        end.join(' | ')
      end.join('<br>')
      redirect_to [:admin, @template_kind], flash: { info: message.html_safe }
    end

    def edit_all
    end


    def update
      @template_kind = CloudComputing::TemplateKind.find(params[:id])
      respond_to do |format|
        format.html do
          if @template_kind.update(template_kind_params)
            redirect_to [:admin, @template_kind]
          else
            render :edit
          end
        end
        format.text do
          if @template_kind.update(template_kind_params)
            render plain: t('.updated_successfully', kind: @template_kind.to_s)
          else
            render plain: @template_kind.errors.full_messages.join('. '), status: 422
          end
        end
      end
    end

    def destroy
      @template_kind = CloudComputing::TemplateKind.find(params[:id])
      @template_kind.destroy!
      render plain: t('.destroyed_successfully', kind: @template_kind.to_s)
    end

    private

    def load_virtual_machine_template_kind
      @template_kind = CloudComputing::TemplateKind.find(params[:id])

      unless @template_kind.virtual_machine?
        redirect_to [:admin, @template_kind], flash: { error: 'errors' }
        return
      end
    end


    def template_kind_params
      #Order is of params is important
      params.require(:template_kind).permit(*CloudComputing::TemplateKind
                                           .locale_columns(:name, :description),
                                           :parent_id,:id, :name, :child_index,
                                           :name, :cloud_class,
                                           conditions_attributes: %i[id from_multiplicity
                                             to_multiplicity to_type to_id kind _destroy])
    end
  end
end
