module Core
  class ProjectVersion < ApplicationRecord
    RECORDED_ASSOCS = %w[card critical_technologies direction_of_sciences
                         research_areas].freeze
    belongs_to :project, inverse_of: :project_versions
    serialize :object_changes, type: Hash
    serialize :object, type: Hash

    def self.project_hash(project)
      RECORDED_ASSOCS.map do |a|
        rel = project.public_send(a)
        [a, if a != 'card'
              rel.to_a.map { |o| { 'id' => o.id, 'name' => o.name } }
            else
              rel&.attributes || {}
            end]
      end.to_h.merge(project.attributes)
    end

    def self.ids(arr)
      arr.map { |k| k['id'] }
    end

    def self.plain_diff(init, final)
      (init.keys | final.keys).map do |a|
        [a, [init[a], final[a]]] if init[a].to_s != final[a].to_s
      end.compact.to_h
    end

    def self.difference(init, final)
      diff = plain_diff(init.except(*RECORDED_ASSOCS),
                        final.except(*RECORDED_ASSOCS))
      RECORDED_ASSOCS.map do |a|
        [a, if init[a].is_a? Array
              i = ids(init[a])
              f = ids(final[a])
              i.sort == f.sort ? {} : [i, f]
            else
              plain_diff(init[a], final[a])

            end]
      end.select { |_k, v| v != {} }.to_h.merge(diff)
    end

    def self.user_update(project)
      if project.valid?
        old_project = project.id ? Core::Project.find(project.id) : Core::Project.new
        init = project_hash(old_project)
        project.save!
        final = project_hash(project)
        diff = difference(init, final)
        return true if diff.empty?

        project.project_versions.create!(object: init, object_changes: diff)
        true
      else
        false
      end
    end

    def self.trigger_event(project, event)
      init = project_hash(project)
      transaction do
        return false unless project.send("may_#{event}?")

        project.send("#{event}!")
      end

      final = project_hash(project)
      project.project_versions.create!(object: init,
                                       object_changes: difference(init, final))
    end
  end
end
