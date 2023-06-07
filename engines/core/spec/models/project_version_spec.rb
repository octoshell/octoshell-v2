require 'main_spec_helper'
module Core
  RSpec.describe ProjectVersion do
    describe '::project_hash' do
      it 'generates hash' do
        project = create(:project)
        puts ProjectVersion.project_hash(project)
      end

    end

    describe '::plain_diff' do
      it 'computes difference between different hashes' do
        init = {a: 'fixed', b: 'initial'}
        final = {a: 'fixed', b: 'changed'}
        expect(ProjectVersion.plain_diff(init, final)).to eq(b: ['initial', 'changed'])
      end
      it 'computes difference between equal hashes' do
        init = {a: 'fixed', b: 'fixed'}
        final = {a: 'fixed', b: 'fixed'}
        expect(ProjectVersion.plain_diff(init, final)).to eq({})
      end
    end

    describe '::difference' do
      it 'computes difference between equal project hashes' do
        project = create(:project)
        init = ProjectVersion.project_hash(project)
        final = ProjectVersion.project_hash(project)
        expect(ProjectVersion.difference(init, final)).to eq({})
      end

      it 'computes difference between different project hashes' do
        project = create(:project)
        prev_ids = project.critical_technology_ids
        init = ProjectVersion.project_hash(project)
        project.critical_technologies << create(:critical_technology)
        # project.update(title: 'new_title')
        project.card.update!(en_driver: 'new_driver')
        final = ProjectVersion.project_hash(project)
        diff = {
          'card' => {'en_driver' => ['test', 'new_driver']},
          'critical_technologies' => [prev_ids, project.critical_technology_ids]
        }
        output = ProjectVersion.difference(init, final)
        output['card'].delete('updated_at')
        expect(output).to eq diff
      end
    end

    describe '::user_update' do
      it 'saves changes after update' do
        project = create(:project)
        project.card.assign_attributes(en_driver: 'new_driver')
        raise 'Error' unless ProjectVersion.user_update(project)

        expect(ProjectVersion.last.object_changes['card'])
          .to include('en_driver' => ['test', 'new_driver'])
      end
      it 'does not save changes when validation fails' do
        project = create(:project)
        project.card.assign_attributes(en_driver: '')
        raise 'Error' if ProjectVersion.user_update(project)
      end

      it 'does not save changes when nothing is modified' do
        project = create(:project)
        expect { ProjectVersion.user_update(project) }
          .not_to change(ProjectVersion, :count)
      end


      it 'saves changes after create' do
        project = build(:project)
        raise 'Error' unless ProjectVersion.user_update(project)
        expect(ProjectVersion.last.object_changes['card'])
          .to include('en_driver' => [nil, 'test'])
      end
    end

    describe '::trigger_event' do
      it 'saves changes after trigger' do
        project = create(:project)
        ProjectVersion.trigger_event(project, :activate)
        expect(ProjectVersion.last.object_changes)
          .to include('state' => ['pending', 'active'])
      end
      it 'does not save changes when validation fails' do
        project = create(:project)
        expect { ProjectVersion.trigger_event(project, :block) }
          .not_to change(ProjectVersion, :count)
      end
    end




  end
end
