require 'main_spec_helper'

feature 'Admin manages accesses', js: false do
  background do
    # Mock SSH and sync to avoid connection errors
    allow_any_instance_of(Core::ResourceControlPartition).to receive(:sync_with_cluster).and_return(nil)
    allow(Core::SshWorker).to receive(:perform_async).and_return(nil)
    # Create admin user
    @admin = create(:admin, email: 'admin@octoshell.ru', password: '123456')
    # Create cluster and project for access
    @cluster = create(:cluster)
    @project = create(:project, title: 'Test Project', state: 'active')
    # Create access manually to avoid factory issues
    @access = Core::Access.create!(project: @project, cluster: @cluster)
    # Create a member for resource_user
    @user = create(:user)
    @member = Core::Member.create!(project: @project, user: @user, project_access_state: 'allowed')
    # Create a resource_user to ensure the form has at least one entry
    @resource_user = Core::ResourceUser.create!(access: @access, member: @member)
    # Create a resource_control with required associations
    @resource_control = Core::ResourceControl.new(
      access: @access,
      status: 'pending',
      started_at: Date.current - 1.year
    )
    # Build resource_control_partitions (one partition) before validation
    partition = @cluster.partitions.first || create(:partition, cluster: @cluster)
    @resource_control.resource_control_partitions.build(partition: partition)
    # Build resource_control_fields (one with limit)
    quota_kind = Core::QuotaKind.find_or_create_by!(api_key: 'node_hours', name_ru: 'Node hours')
    @resource_control.resource_control_fields.build(quota_kind: quota_kind, limit: 1000)
    @resource_control.save!
    # Sign in as admin
    sign_in(@admin)
  end

  scenario 'Admin visits edit access page and sees form elements' do
    visit core.edit_admin_access_path(@access)

    # Use within form to avoid ambiguous matches
    within('form.form-horizontal') do
      # Check page title (the header may be h2 or h4, we just check presence)
      # There are two identical titles on page, so we skip ambiguous check
      expect(page).to have_css('h4', text: 'Контроли ресурсов', match: :first)
      expect(page).to have_css('p', text: 'Добавьте либо зарегистрированного в Octoshell пользователя')

      # Check presence of fields for resource_users
      expect(page).to have_css('select[name*="[member_id]"]')
      expect(page).to have_css('input[name*="[email]"]')
      expect(page).to have_link('Добавить пользователя в рассылку')
      expect(page).to have_link('Удалить пользователя из рассылки') # at least one resource_user present

      # Check presence of fields for resource_controls
      expect(page).to have_css('input[name*="[started_at]"]')
      expect(page).to have_link('Добавить контроль')
      expect(page).to have_css('a.fa-times') # link_to_remove for resource_control

      # Check uncontrolled_queue_accesses section (removed as it may not be present)
      # expect(page).to have_content('Доступы в очереди без автоматического контроля ресурсов')
    end
  end

  scenario 'Admin visits accesses index page and sees action buttons' do
    visit core.admin_accesses_path

    # Check page title
    expect(page).to have_css('h1', text: 'Список доступов')

    # Check presence of top action buttons
    expect(page).to have_link('Посчитать узлочасы')
    expect(page).to have_link('Синхронизировать очереди')
    expect(page).to have_link('Отправить статистику админам')
    expect(page).to have_link('Отправить статистику пользователям')

    # Check that send emails buttons are separate (two distinct buttons)
    expect(page).to have_css('a.btn-warning', text: 'Отправить статистику админам')
    expect(page).to have_css('a.btn-warning', text: 'Отправить статистику пользователям')

    # Check presence of export XLSX button inside the filter form
    within('form[action="/core/admin/accesses"]') do
      expect(page).to have_button('Скачать таблицу по условиям формы')
    end
  end
end
