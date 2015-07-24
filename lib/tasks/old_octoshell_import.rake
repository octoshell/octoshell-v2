# encoding: utf-8

namespace :import do
  task :fill_sessions_for_user_surveys => :environment do
    Sessions::Survey.find_each do |survey|
      survey.user_surveys.update_all(session_id: survey.session_id)
    end
  end

  # Импортирует сканы из старого octoshell.
  # NOTE: Запускать разово при переходе на новую версию!
  # Сначала чистим все сканы в новой версии (если такие как-то были созданы).
  # Потом перебираем все поручительства (уже импортированные через дамп),
  # собираем опять же импортированные тикеты из старого шела.
  # Забираем аттачи от тикетов и передаём их сканам для поручительства.
  # Трём тикет, т.к. такого рода тикетов в новой системе быть не должно.
  task :surety_scans => :environment do
    puts "deleting existing scans..."
    Core::SuretyScan.delete_all
    puts "importing scans from tickets..."
    Core::Surety.transaction do
      Core::Surety.find_each do |surety|
        Support::Ticket.where(surety: surety).each do |ticket|
          surety.scans.create!(image: File.open(ticket.export_attachment.file.path)) if ticket.export_attachment.present?
          ticket.destroy
        end
      end
    end
  end

  task :ticket_attachments => :environment do
    Support::Ticket.find_each do |ticket|
      ticket.update(attachment: File.open(ticket.export_attachment.file.path)) if ticket.export_attachment.present?
    end
  end

  task :reply_attachments => :environment do
    Support::Reply.find_each do |reply|
      reply.update(attachment: File.open(reply.export_attachment.file.path)) if reply.export_attachment.present?
    end
  end

  task :report_materials => :environment do
    Sessions::Report.find_each do |report|
      report.update(materials: File.open(report.export_materials.file.path)) if report.export_materials.present?
    end
  end

  task :surety_states_fix => :environment do
    Core::Surety.where(state: "filling").update_all(state: "generated")
  end

  # Перезаполняем статусы тикетов по видам:
  # 1. Со статусом "active"
  #   1.1. Без ответов — "pending"
  #   1.2. С ответами — "answered_by_reporter"
  # 2. Со статусом "answered" — "answered_by_support"
  task :ticket_states_fix => :environment do
    # 1.1.
    ids = Support::Ticket.includes(:replies).where(support_replies: {ticket_id: nil}).where(state: "active").pluck(:id)
    Support::Ticket.where(id: ids).update_all(state: "pending")
    # 1.2.
    ids = Support::Ticket.joins(:replies).where(state: "active").pluck(:id)
    Support::Ticket.where(id: ids).update_all(state: "answered_by_reporter")
    # 2.
    Support::Ticket.where(state: "answered").update_all(state: "answered_by_support")
  end

  task :create_documents_for_active_sureties => :environment do
    Core::Surety.with_state(:active).map(&:save_rft_document)
  end

  task :add_admin_login_and_keys_for_clusters => :environment do
    Core::Cluster.find_each do |cluster|
      cluster.generate_ssh_keys
      cluster.update(admin_login: "octo")
    end
  end

  task :create_cluster_quotas_and_accesses => :environment do
    cpu_quota_kind = Core::QuotaKind.create!(name: "CPU", measurement: "часов")
    gpu_quota_kind = Core::QuotaKind.create!(name: "GPU", measurement: "часов")
    hdd_space_quota_kind = Core::QuotaKind.create!(name: "Место на HDD", measurement: "Гб")

    Core::Cluster.transaction do
      Core::Cluster.find_each do |cluster|
        cluster.quotas.create!(quota_kind: cpu_quota_kind, value: 1000)
        cluster.quotas.create!(quota_kind: gpu_quota_kind, value: 1000)
        cluster.quotas.create!(quota_kind: hdd_space_quota_kind, value: 50)
      end

      Core::Request.find_each do |request|
        request.fields.create!(quota_kind: cpu_quota_kind, value: request.cpu_hours)
        request.fields.create!(quota_kind: gpu_quota_kind, value: request.gpu_hours)
        request.fields.create!(quota_kind: hdd_space_quota_kind, value: request.hdd_size)

        Core::Request.create_access_for(request) if request.active?
      end
    end
  end
end
