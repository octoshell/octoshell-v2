# module Core
#   require ""
#   describe JoinOrgs do
#     # describe "#load_test_data" do
#     #   it "is smoke test" do
#     #     JoinOrgs.load_test_data('joining-orgs_2017_11-2.ods')
#     #     puts Core::Organization.find(497).inspect
#     #   end
#     # end
#     describe "#merge_from_table" do
#       it "is smoke test" do
#         JoinOrgs.load_test_data('joining-orgs_2017_11-2.ods')
#
#         table = Roo::Spreadsheet.open('joining-orgs_2017_11-2.ods')
#         rows = table.sheet(0).to_a
#         rows.delete_at(0)
#
#         # 1
#         expect(rows).to include [497, "Московский государственный университет имени М.В.Ломоносова",
#                                  81, "биологический факультет", nil, nil, nil, "Биологический факультет"]
#         # Переименование
#         expect(OrganizationDepartment.find(81).name).to eq "биологический факультет"
#
#         # 2
#         expect(rows).to include [497, "Московский государственный университет имени М.В.Ломоносова",
#                                  83, "Кафедра океанологии", nil, 55, nil, nil]
#         # Сливаем с географическим факультетом(подразделение, находящееся в той же организации)
#         @user = create_admin
#         @ocean = OrganizationDepartment.find_by!(name: "Кафедра океанологии")
#         @ocean_employment = Core::Employment.new user: @user,
#                                                  organization: @ocean.organization,
#                                                  organization_department: @ocean
#         @ocean_employment.save!
#
#         #3
#         expect(rows).to include [945, "[дубль, будет удалён] Московский Государственный Университет им. М.В. Ломоносова",
#                                  103, "МГУ", 497, "x", nil, nil]
#         # Сливание с организацией
#         @department1 = OrganizationDepartment.find(103)
#         @employment = Core::Employment.new user: @user,
#                                                  organization: @department1.organization,
#                                                  organization_department: @department1
#         @employment.save!
#
#         #4
#         Core::Organization.find_by!(name: 'Научный Исследовательский Центр Электронной и Вычислительной техники')
#
#
#
#
#
#
#         JoinOrgs.merge_from_table('joining-orgs_2017_11-2.ods')
#         msu = Core::Organization.MSU
#         departments = msu.departments
#         names = departments.map(&:name)
#         expect(names).to include('Научно-исследовательский вычислительный центр')
#         expect(names).not_to include('географический')
#
#         # 1
#         expect(OrganizationDepartment.find(81).name).to eq "Биологический факультет"
#
#         # 2
#         @ocean_employment.reload
#         expect(OrganizationDepartment.find_by name: "Кафедра океанологии").to eq nil
#         expect(@ocean_employment.organization_department_id).to eq 55
#         expect(@ocean_employment.organization_id).to eq 497
#
#         # 3
#         @employment.reload
#         expect(@employment.organization_department_id).to eq nil
#         expect(@employment.organization_id).to eq 497
#
#         #4
#         expect(Core::Organization.find_by name: 'Научный Исследовательский Центр Электронной и Вычислительной техники').to eq nil
#         names = Core::Organization.find(414).departments.map(&:name)
#         expect(names).to include 'Научный Исследовательский Центр Электронной и Вычислительной техники'
#       end
#     end
#   end
# end
