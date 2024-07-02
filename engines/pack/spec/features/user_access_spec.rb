require 'main_spec_helper'
module Pack
  feature 'user_access', js: true do
    before(:each) do
      @user = create(:user)
      sign_in(@user)
      @project = create(:project)
      @project.members.create!(user: @user, owner: true)
      @usual_package = create(:package)
      @usual_version = create(:version, package: @usual_package)
      @usual_version2 = create(:version, package: @usual_package)

      @package = create(:package, accesses_to_package: true)
      @version = create(:version, package: @package)
      @version2 = create(:version, package: @package)

      # create(:access, who: @user, to: version)
      # create(:access, who: Group.find_by(name: 'superadmins'),
      #                            to: version, created_by: User.superadmins.first)
      # create(:access, who: Core::Project.first, end_lic: nil,
      #                            to: version, created_by: User.superadmins.first)
      @cluster = create(:cluster)
      Pack::Version.all.each do |v|
        Core::Cluster.all.each do |cluster|
          Pack::Clusterver.create!(version: v, core_cluster: cluster, active: true)
        end
      end

    end
    scenario 'request access with end_lic' do
      visit pack.versions_path
      page.find("tbody[package_id='#{@package.id}'] button").click
      select2 'alpaca1', "Проект #{@project.title}"
      to_date = (Date.today + 7).to_s
      sleep(1)
      fill_in 'alpaca23', with: to_date
      click_button 'Сохранить'
      expect(page).to have_content('Заявка успешно отправлена')
      expect(Access.where(to: @package, created_by: @user, who: @project,
                          status: 'requested', end_lic: to_date)).to exist
    end

    scenario 'request access without end_lic' do
      visit pack.versions_path
      page.find("tbody[package_id='#{@package.id}'] button").click
      select2 'alpaca1', "Проект #{@project.title}"
      choose 'Без даты окончания'
      click_button 'Сохранить'
      expect(page).to have_content('Заявка успешно отправлена')
      expect(Access.where(to: @package, created_by: @user, who: @project,
                          status: 'requested', end_lic: nil)).to exist
    end

    feature 'allowed access' do
      scenario 'show access without end_lic' do
        # visit pack.versions_path
        # $stdin.gets
        Access.create!(to: @package, created_by: @user, who: @user,
                       status: 'allowed', end_lic: nil)
        visit pack.versions_path
        page.find("tbody[package_id='#{@package.id}'] button").click
        expect(page).to have_content('У Вашего доступа нет даты окончания')
      end

      scenario 'show access with end_lic' do
        # visit pack.versions_path
        # $stdin.gets
        to_date = (Date.today + 7).to_s
        to_req_date = (Date.today + 14).to_s
        Access.create!(to: @package, created_by: @user, who: @user,
                       status: 'allowed', end_lic: to_date)
        visit pack.versions_path
        page.find("tbody[package_id='#{@package.id}'] button").click
        fill_in 'alpaca13', with: to_req_date
        click_button 'Сохранить'
        expect(page).to have_content('Заявка успешно отправлена')
      end

    end



  end
end
