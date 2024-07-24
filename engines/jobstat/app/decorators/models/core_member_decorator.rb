if(klass = Octoface.role_class(:core, 'Member'))
  klass.class_eval do
    has_many :jobstat_jobs, class_name: 'Jobstat::Job', primary_key: :login, foreign_key: :login
  end
end
