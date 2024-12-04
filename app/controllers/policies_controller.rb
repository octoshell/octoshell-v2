class PoliciesController < ApplicationController
  def new
    @policy = Policy.new
  end

  def create
    @policy = Policy.new(policy_params)
    if @policy.save
      redirect_to @policy, notice: 'Policy was successfully created.'
    else
      render :new
    end
  end

  private

  def policy_params
    params.require(:policy).permit(:title, :document)
  end
end