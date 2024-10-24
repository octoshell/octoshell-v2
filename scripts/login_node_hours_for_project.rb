#Elapsed node hours by login for specified projects using sacct utility 
HOUR_SEC=3600
DAY_SEC=HOUR_SEC*24
project_ids = ARGV

members = if project_ids.any?
             Core::Member.where(project_id: project_ids) | Core::RemovedMember.where(project_id: project_ids)
          else
            Core::Member.all | Core::RemovedMember.all
          end

def node_hours
  'EXTRACT(EPOCH FROM jobstat_jobs.end_time - jobstat_jobs.start_time)
  / 3600 * jobstat_jobs.num_nodes'
end

def parse_sacct
  File.read('sacct.txt').split("\n")[1..].map do |line|
    # sacct: login nodes elapsed
    /^(.+)\|(\d+)\|((\d*)-)?(\d+):(\d+):(\d+)\|(\S+)/ =~ line or raise "error #{line}"
    seconds = $4.to_i*DAY_SEC+$5.to_i*HOUR_SEC+$6.to_i*60+$7.to_i
    # puts line
    # puts $6
    #  awdwad if $4.to_i > 0
    [$1, (seconds * $2.to_i).to_f / 3600]
  end.group_by(&:first).map { |k, v| [k, v.map(&:second).sum] }.to_h

end
hours = parse_sacct
require 'csv'
logins = members.sort_by(&:project_id).map(&:login)
jobs = Jobstat::Job.where(cluster: 'lomonosov-2', login: logins)
                   .where('submit_time >= ? ', DateTime.new(Date.current.year, 1, 1))
                   .group('login')
                   .select("SUM(#{node_hours}) AS node_hours, login")
                   .map { |j| [j.login, j['node_hours']] }.to_h

CSV.open("member_projects.csv", "w") do |csv|
  csv << %w[логин project_id название_проекта ФИО верные_узлочасы узлочасы_из_octoshell исключили_из_проекта]
  Core::Project.where(id: members.map(&:project_id))
               .includes(members: { user: :profile }, removed_members: { user: :profile })
               .each do |project|
    (project.members | project.removed_members).each do |member|
      csv << [
        member.login,
        member.project_id,
        project.title,
        member.user.full_name,
        hours[member.login],
        jobs[member.login],
        (member.is_a?(Core::RemovedMember) ? 'да' : 'нет')
      ]
    end
  end
end
