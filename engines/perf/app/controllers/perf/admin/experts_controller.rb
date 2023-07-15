module Perf::Admin
  class ExpertsController < Perf::ApplicationController
    include Perf::ApplicationHelper
    before_action :octo_authorize!
    def show
      params[:order] ||= 'node_hours'
      params[:state] = Array(params[:state]).select(&:present?)
      set_place
      @project = Core::Project.find(params[:id])
      @session = Sessions::Session.order(id: :desc).first
      @records = Perf::Comparator.new(@session.id).show_project_stat(params[:state], @place).execute
      @project_names = Core::Project.where(id: @records.map { |pr| pr['id'] }).to_a.group_by(&:id)

      @records.each do |pr|
        pr['name'] = @project_names[pr['id']].first.title
      end
      all_results = Perf::Comparator.new(@session.id).by_jobs_in_days(@project.id).execute
      results = Perf::Comparator.new(@session.id).by_jobs_in_days_and_state(@project.id).execute
      @states = results.group_by { |row| row['state'] }
      @states['ALL'] = all_results
      set_brief_table
    end

    private

    def set_brief_table
    @brief_table = Rails.cache.read("project_stat_#{@session.id}")
    return if @brief_table

    Perf::Worker.perform_async(:count_project_stats, @session.id)
    end

    def set_place
      order = params[:order]
      order_to_place_hash =  {
          'node_hours' => 's_place_node_hours',
          'share_node_hours' => 's_share_place_node_hours',
          'jobs' => 's_place_jobs',
          'share_jobs' => 's_share_place_jobs',
      }
      @place = order_to_place_hash[order]
    end

  end
end
