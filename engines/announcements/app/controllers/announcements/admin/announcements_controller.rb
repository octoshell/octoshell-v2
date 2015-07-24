module Announcements
  class Admin::AnnouncementsController < Admin::ApplicationController
    before_filter { authorize! :manage, :announcements }

    def index
      @announcements = Announcement.order("id desc")
    end

    def show
      @announcement = Announcement.find(params[:id])
    end

    def new
      @announcement = Announcement.new
    end

    def create
      @announcement = Announcement.new(announcement_params)
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
        redirect_to admin_announcement_show_users_path(@announcement)
      else
        render :edit
      end
    end

    def deliver
      @announcement = Announcement.find(params[:announcement_id])
      @announcement.deliver
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
      @users = @search.result(distinct: true).with_access_state(:active).includes(:profile).order(:id)
      @users = if @announcement.is_special?
                 @users.where(profiles: {receive_special_mails: true})
               else
                 @users.where(profiles: {receive_info_mails: true})
               end
      @recipient_ids = @announcement.recipient_ids
    end

    def show_recipients
      @announcement = Announcement.find(params[:announcement_id])
      params[:q] ||= { state_in: ["active"] }
      @search = @announcement.recipients.search(params[:q])
      @users = @search.result(distinct: true).includes(:profile).order(:id)
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
      @announcement.update(recipient_ids: (params[:selected_recipient_ids] || []).map(&:to_i))

      redirect_to [:admin, @announcement]
    end

    private

    def announcement_params
      params.require(:announcement).permit!
    end
  end
end
