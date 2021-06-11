module Jobstat
  module AbnormalJobChecker
    CHECKER_PREFIX = '[                abnormal_job_checker                ]'

    def add_notice(job, user)
      note=Core::Notice.create(
        sourceable: user,
        message: view_context.link_to(job.drms_job_id, jobstat.job_path(job)),
        linkable: job,
        category: 1)
      note.save!
      logger.info "#{CHECKER_PREFIX}: new notice for #{job.drms_job_id}"
    end

    def remove_notice(job, user)
      Core::Notice.where(sourceable: user, linkable: job, category: 1).destroy_all
    end

    def group_match(job, user)
      job.get_rules(user).each { |r|
        return true if r['group'] == 'disaster'
      }
      return false
    end

    def check_job(job)
#      logger.info "#{CHECKER_PREFIX}: checking job #{job.id}: state = #{job.state}, end_time = #{job.end_time}"

      member = Core::Member.where(login: job.login).take
      return unless member

      user = member.user
      remove_notice(job, user)

      if group_match(job, user) && job.end_time > Time.new && job.state == 'RUNNING'
        add_notice(job, user)
      else
      end
    end
  end
end
