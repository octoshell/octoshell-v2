module Announcements
  class Admin::AnnouncementsController < Admin::ApplicationController
    before_filter { authorize! :manage, :announcements }
    # before_action only: %i[create update] do
    #   if announcement_params[:attachment]
    #     announcement_params[:attachment].original_filename =
    #       Translit.convert(announcement_params[:attachment].original_filename, :english)
    #   end
    # end

    helper Face::ApplicationHelper
    def index
      @announcements = Announcement.order("id desc").includes(created_by: :profile)
    end

    def show
      @announcement = Announcement.find(params[:id])
    end

    def new
      @announcement = Announcement.new
    end

    def create
      @announcement = Announcement.new(announcement_params)
      @announcement.created_by = current_user
      if @announcement.save
        redirect_to admin_announcement_show_users_path(@announcement)
      else
        render :new
      end
    end

    def edit
      @announcement = Announcement.find(params[:id])
    end

    def update
      @announcement = Announcement.find(params[:id])
      if @announcement.update_attributes(announcement_params)
        @announcement.save
        redirect_to admin_announcement_show_users_path(@announcement)
      else
        render :edit
      end
    end

    def deliver
      @announcement = Announcement.find(params[:announcement_id])
      @announcement.deliver
      @announcement.save
      redirect_to admin_announcements_path
    end

    def destroy
      @announcement = Announcement.find(params[:id])
      @announcement.destroy
      redirect_to admin_announcements_path
    end

    def test
      @announcement = Announcement.find(params[:announcement_id])
      @announcement.test_send(current_user)
      redirect_to [:admin, @announcement]
    end

    def show_users
      @announcement = Announcement.find(params[:announcement_id])
      @search = User.search(params[:q])
      @users = @search.result(distinct: true).where(:access_state=>:active).includes(:profile).order(:id)
      @users = if @announcement.is_special?
                 @users.where(profiles: {receive_special_mails: true})
               else
                 @users.where(profiles: {receive_info_mails: true})
               end
      @recipient_ids = @announcement.recipient_ids
    end

    def show_recipients
      @announcement = Announcement.find(params[:announcement_id])
      @search = User.search(params[:q])
      @users = @search.result(distinct: true).where(:access_state=>:active).includes(:profile).order(:id)
      @users = if @announcement.is_special?
                 @users.where(profiles: {receive_special_mails: true})
               else
                 @users.where(profiles: {receive_info_mails: true})
               end
      @recipient_ids = @announcement.recipient_ids
      render 'show_users'
    end

    def select_recipients
      @announcement = Announcement.find(params[:announcement_id])
      remain_ids = (((params[:selected_recipient_ids] || []).map(&:to_i) || []) +
        (@announcement.recipient_ids - params[:users_ids].split(' ').map(&:to_i))).uniq
      @announcement.update(recipient_ids: remain_ids)

      redirect_to [:admin, @announcement]
    end

    private

    def announcement_params
      params.require(:announcement).permit!
    end
  end
end
