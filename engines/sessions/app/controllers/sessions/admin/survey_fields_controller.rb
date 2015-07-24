module Sessions
  class Admin::SurveyFieldsController < Admin::ApplicationController
    def new
      @survey = Survey.find(params[:survey_id])
      @survey_field = @survey.fields.build
    end

    def create
      @survey = Survey.find(params[:survey_id])
      @survey_field = @survey.fields.build(survey_field_params)
      if @survey_field.save
        redirect_to [:admin, @survey]
      else
        render :new
      end
    end

    def edit
      @survey = Survey.find(params[:survey_id])
      @survey_field = @survey.fields.find(params[:id])
    end

    def update
      @survey = Survey.find(params[:survey_id])
      @survey_field = @survey.fields.find(params[:id])
      if @survey_field.update_attributes(survey_field_params)
        redirect_to [:admin, @survey]
      else
        render :edit
      end
    end

    def destroy
      @survey = Survey.find(params[:survey_id])
      @survey_field = @survey.fields.find(params[:id])
      @survey_field.destroy!
      redirect_to [:admin, @survey]
    end

    private

    def survey_field_params
      params.require(:survey_field).permit(:name, :kind, :collection, :regexp, :max_values, :weight,
                                           :required, :entity, :strict_collection, :hint)
    end
  end
end
