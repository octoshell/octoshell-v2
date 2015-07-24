module Core
  class Admin::SuretiesController < Admin::ApplicationController
    before_filter :setup_default_filter, only: :index

    def index
      @search = Surety.search(params[:q])
      @sureties = @search.result(distinct: true).page(params[:page])
    end

    def show
      @surety = find_surety(params[:id])
      respond_to do |format|
        format.html
        format.rtf do
          send_data @surety.generate_rtf
        end
      end
    end

    def find
      @surety = find_surety(params[:id])
      redirect_to @surety
    rescue ActiveRecord::RecordNotFound
      redirect_to sureties_path, alert: t("flash.alerts.surety_not_found")
    end

    def activate
      @surety = find_surety(params[:surety_id])
      if @surety.activate
        redirect_to_surety @surety
      else
        redirect_to_surety_with_alert @surety
      end
    end

    def close
      @surety = find_surety(params[:surety_id])
      if @surety.close
        redirect_to_surety @surety
      else
        redirect_to_surety_with_alert @surety
      end
    end

    def confirm
      @surety = find_surety(params[:surety_id])
      if @surety.confirm
        redirect_to_surety(@surety)
      else
        redirect_to_surety_with_alert(@surety)
      end
    end

    def reject
      @surety = find_surety(params[:surety_id])
      if @surety.reject
        redirect_to_surety(@surety)
      else
        redirect_to_surety_with_alert(@surety)
      end
    end

    def edit_template
      @rtf = File.read("#{Core::Engine.root}/config/sureties/surety.rtf")
    end

    def rtf_template
      File.open("#{Core::Engine.root}/config/sureties/surety.rtf", "w+") do |f|
        f.write params[:template]
      end
      redirect_to template_admin_sureties_path, notice: t("flash.template_loaded")
    end

    def default_rtf
      File.open("#{Rails.root}/config/sureties/surety.rtf", "w+") do |f|
        f.write File.read("#{Core::Engine.root}/config/sureties/surety.rtf.default")
      end
      redirect_to template_admin_sureties_path, notice: t("flash.template_recreated")
    end

    def download_rtf_template
      send_data File.read("#{Core::Engine.root}/config/sureties/surety.rtf"), type: "application/msword"
    end

    def load_scan
      @surety = Surety.find(params[:surety_id])
      if @surety.load_scan(params[:file])
        redirect_to [:admin, @surety], notice: t("flash.scan_uploaded")
      else
        redirect_to [:admin, @surety, :scan], alert: @surety.errors.full_messages.to_sentence
      end
    end

    def new_scan
      @surety = Surety.find(params[:surety_id])
    end

    private

    def find_surety(id)
      Surety.find(id)
    end

    def redirect_to_surety_with_alert(surety)
      redirect_to [:admin, surety], alert: surety.errors.full_messages.to_sentence
    end

    def redirect_to_surety(surety, options = {})
      redirect_to [:admin, surety], options
    end

    def setup_default_filter
      params[:q] ||= { state_in: ["confirmed"] }
    end
  end
end
