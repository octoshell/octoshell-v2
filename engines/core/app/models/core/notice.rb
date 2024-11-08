# == Schema Information
#
# Table name: core_notices
#
#  id              :integer          not null, primary key
#  active          :boolean          default(FALSE)
#  category        :integer
#  count           :integer
#  kind            :string
#  linkable_type   :string
#  message         :text
#  show_from       :datetime
#  show_till       :datetime
#  sourceable_type :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  linkable_id     :integer
#  sourceable_id   :integer
#
# Indexes
#
#  index_core_notices_on_linkable_type_and_linkable_id      (linkable_type,linkable_id)
#  index_core_notices_on_sourceable_type_and_sourceable_id  (sourceable_type,sourceable_id)
#

module Core
  class Notice < ApplicationRecord
    belongs_to :sourceable, polymorphic: true # user or object to be noticed
    belongs_to :linkable, polymorphic: true   # extra data
    has_many :notice_show_options, dependent: :destroy

    SITE_WIDE = 0
    PER_USER = 1
    OTHER = -1
    # message:  text    = notice text
    # count:    integer = notices count if applicable
    # category: integer = 0 for wide notices,
    #                     >0 for per-user notices,
    #                     1 = simple per-user notification, 2+ = call handler...
    #                     other - undefined
    # kind:     string  = for handler selection
    # show_from: date   = when start to show (nil=now)
    # show_till: date   = when stop to show  (nil=forever)
    # active:   integer = 1(or nil) = is active now (for use in handler only)
    validates :category, :message, presence: true

    def visible?(user = nil)
      opt = notice_show_options.where(user: user).take
      !opt&.hidden
    end

    def self.register_kind(k, &block)
      @notice_handlers ||= {}
      @notice_handlers[k] = block
    end

    def self.handle(notice, user, params, request)
      return nil unless @notice_handlers

      handler = @notice_handlers[notice.kind.to_s]
      handler&.call(notice, user, params, request)
    end

    def source_name
      if sourceable.nil?
        '----'
      elsif sourceable.respond_to?(:full_name)
        sourceable.full_name
      elsif sourceable.respond_to?(:title_ru)
        sourceable.title_ru
      else
        sourceable.name_ru
      end
    end

    def self.register_def_nil_kind_handler
      Core::Notice.register_kind nil.to_s do |notice, user, _, request|
        [
          :info,
          "#{notice.message} #{notice.add_close(request)}".html_safe
        ]
      end
    end
    Core::NoticeHandlers.call

    include Core::Engine.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def add_close(request)
      link_to(
        "<i title='#{I18n.t('core.notices.hide', default: 'hide')}' \
        class='fas fa-bell-slash close'></i>".html_safe,
        hide_notice_path(id, retpath: request.fullpath), method: :post
      )
    end

    def category_str
      if category.zero?
        I18n.t('.core.admin.notices.site-wide')
      elsif category == 1
        I18n.t('.core.admin.notices.per-user')
      else
        I18n.t('.core.admin.notices.other')
      end
    end

    def self.notices_for_user(user)
      Core::Notice.where('category > 0').where(sourceable: user)
                  .or(Core::Notice.where('category < 1'))
                  .where(active: true).distinct
                  .joins(<<-SQL
        LEFT JOIN core_notice_show_options AS o ON
        core_notices.id = o.notice_id AND o.user_id = #{user.id}
      SQL
                        ).where('o.hidden IS NULL OR o.hidden = false')
                  .where('core_notices.show_from IS NULL
                    OR core_notices.show_from <= ?', DateTime.now)
                  .where('core_notices.show_till IS NULL
                    OR core_notices.show_till >= ?', DateTime.now)
    end

    def self.show_notices(current_user, params, request)
      notices_for_user(current_user).map do |notice|
        Core::Notice.handle(notice, current_user, params, request)
      end.reject(&:nil?)
    end

    def self.get_count_for_user(user)
      peruser =
        Core::Notice
        .where('category > 0')
        .where(sourceable: user, active: true)
        .count
      sitewide =
        Core::Notice
        .where('category < 1')
        .where(active: true).count
      peruser + sitewide
    end
  end
end
