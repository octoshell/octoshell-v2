# Ответ на отчет
module Sessions
  class ReportReply < ActiveRecord::Base
    belongs_to :report
    belongs_to :user, class_name: Sessions.user_class

    validates :report, :user, :message, presence: true

    after_create :notify_users

    def notify_users
      # Определяем получателей сообщения:
      # Берём автора отчёта и эксперта, если он есть.
      # Добавляем туда id всех пользователей, уже поучаствовавших в
      # обсуждении и убираем оттуда автора данного сообщения.
      receiver_ids = (
        [report.author_id, report.expert_id] + report.replies.map(&:user_id) - [user_id]
      ).compact.uniq

      receiver_ids.each do |uid|
        Sessions::MailerWorker.perform_async(:report_reply, [uid, report.id])
      end
    end
  end
end
