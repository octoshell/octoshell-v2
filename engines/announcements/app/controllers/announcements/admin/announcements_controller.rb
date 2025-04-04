module Announcements::Admin
  class AnnouncementsController < ApplicationController
    # before_action { authorize! :manage, :announcements }
    before_action :octo_authorize!

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

    def send_mails
      Announcement.find(params[:announcement_id]).send_mails
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
      flash_now_message(:notice, t('.blocked_email_explanation'))
      process_ransack_params
      @announcement = Announcement.find(params[:announcement_id])
      @search = Announcements.user_class.search(params[:q])
      @users = @search.result(distinct: true).includes(:profile).order(:id)
      @users = if @announcement.is_special?
                 @users.where(profiles: {receive_special_mails: true})
               else
                 @users.where(profiles: {receive_info_mails: true})
               end
      @users = @users.where(block_emails: false)
      @recipient_ids = @announcement.recipient_ids
    end

    def select_recipients
      @announcement = Announcement.find(params[:announcement_id])
      remain_ids = (((params[:selected_recipient_ids] || []).map(&:to_i) || []) +
        (@announcement.recipient_ids - params[:users_ids].split(' ').map(&:to_i))).uniq
      @announcement.update(recipient_ids: remain_ids)

      redirect_to [:admin, @announcement]
    end

    private

    def process_csv_like_params(keys, elem_format)
      q = params[:q]
      Array(keys).each do |key|
        next unless key

        sep = /[\s,;]+/
        value = q[key]
        if value =~ /^((#{elem_format})#{sep})*(#{elem_format})*$/
          q[key] = value.split(sep)
        else
          flash_message('error', t(".#{key}_error"))
        end
      end
    end

    def process_ransack_params
      return unless params[:q]
      process_csv_like_params(%w[projects_id_in projects_id_not_in], /\d+/)
      process_csv_like_params('email_in', /[a-zA-Z0-9.!\#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*/)
    end


    def announcement_params
      params.require(:announcement).permit!
    end
  end
end
