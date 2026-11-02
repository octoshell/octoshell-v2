require 'main_spec_helper'

feature 'Project resource controls', js: false do
  background do
    @user = create(:user)
    @organization = create(:organization, checked: true)
    @organization.employments.create!(user: @user)
    sign_in(@user)
  end

  scenario 'shows active resource control details under the cluster name' do
    cluster = create(:cluster)
    project = create(:project, owner: @user)
    access = Core::Access.create!(project: project, cluster: cluster)
    quota_kind = Core::QuotaKind.create!(
      api_key: 'node_hours',
      name_ru: 'Узлочасы',
      name_en: 'Node hours'
    )

    active_control = Core::ResourceControl.new(
      access: access,
      status: 'active',
      started_at: Date.new(2025, 1, 15)
    )
    active_control.resource_control_partitions.build(partition: cluster.partitions.first)
    active_control.resource_control_fields.build(
      quota_kind: quota_kind,
      limit: 1000,
      cur_value: 250
    )
    active_control.save!

    blocked_control = Core::ResourceControl.new(
      access: access,
      status: 'blocked',
      started_at: Date.new(2025, 1, 12)
    )
    blocked_control.resource_control_partitions.build(partition: cluster.partitions.second)
    blocked_control.resource_control_fields.build(
      quota_kind: quota_kind,
      limit: 2000,
      cur_value: 2000
    )
    blocked_control.save!

    disabled_control = Core::ResourceControl.new(
      access: access,
      status: 'disabled',
      started_at: Date.new(2025, 1, 10)
    )
    disabled_control.resource_control_partitions.build(partition: cluster.partitions.third)
    disabled_control.resource_control_fields.build(
      quota_kind: quota_kind,
      limit: 500,
      cur_value: 100
    )
    disabled_control.save!

    visit core.project_path(project)

    within('#accesses') do
      expect(page).to have_content('Доступ к ресурсам СКЦ МГУ')
      expect(page).to have_content(cluster.name)
    end

    within('#resource-controls') do
      expect(page).to have_content('Статистика использования ресурсов')
      expect(page).to have_content('Обновление информации о потраченных ресурсах происходит раз в день.')
      expect(page).to have_content('Активен')
      expect(page).to have_content('Заблокирован')
      expect(page).to have_content('Отслеживание начато с')
      expect(page).to have_content(cluster.partitions.first.name)
      expect(page).to have_content(cluster.partitions.second.name)
      expect(page).to have_content('25%')
      expect(page).to have_content('250.0')
      expect(page).to have_content('1000.0')
      expect(page).to have_content('100%')
      expect(page).to have_content('2000.0')
      expect(page).not_to have_content('Отключён админом')
      expect(page).not_to have_content(cluster.partitions.third.name)
    end

    sign_out
    sign_in(create(:admin))
    visit core.admin_project_path(project)

    within('#resource-controls') do
      expect(page).to have_content('Статистика использования ресурсов')
    end
  end
end
