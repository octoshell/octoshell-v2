module Reports
  require 'main_spec_helper'
  describe ConstructorService do

    it '#class_info' do
      associations, associations_types, attributes, attributes_types =
        ConstructorService.class_info(['Core::Project'])

      expect(associations).to include(:organization, :kind)
      expect(associations_types).to include('organization|Organization|belongs_to')
      expect(attributes).to include('title')
      expect(attributes_types).to include('title|string')
    end

    it 'usual select' do
      create(:city, title_ru: 'Воронеж')
      hash = {
                "class_name"=>"Core::City",
                "attributes"=>{"0"=>{"value"=>"core_cities.title_ru", "label"=>"core_cities.title_ru|string"}}
              }
      expect(ConstructorService.new(hash).to_a).to match_array [{"core_cities.title_ru"=>"Москва"},
                                                                {"core_cities.title_ru"=>"Воронеж"}]
    end

    it "select with an aliased expression" do
      hash = {
                "class_name"=>"Core::City",
                "attributes"=>{"0"=>{"value"=>"core_cities.title_ru", "label"=>"core_cities.title_ru|string"},
                               "1"=>{"value"=>"UPPER(core_cities.title_ru)", "alias" => "u"}}
              }
      expect(ConstructorService.new(hash).to_a).to eq [{"core_cities.title_ru"=>"Москва", "u" => "МОСКВА"}]
    end

    it "order by query" do
      create(:city, title_ru: 'Воронеж')
      hash = {"class_name"=>"Core::City", "attributes"=>{"0"=>{"value"=>"core_cities.title_ru",
        "label"=>"core_cities.title_ru|string", "order"=>"ASC"}}}
      expect(ConstructorService.new(hash).to_a).to eq [{"core_cities.title_ru"=>"Воронеж"},
                                                       {"core_cities.title_ru"=>"Москва"}]
    end

    it 'selects count' do
      create(:city, title_ru: 'Воронеж')
      hash = {"class_name"=>"Core::City", "attributes"=>{"0"=>{"value"=>"core_cities.id",
          "label"=>"core_cities.id|integer", "aggregate"=>"COUNT"}}}

      expect(ConstructorService.new(hash).to_a).to eq [{"count_core_cities.id"=>2}]
    end

    it '#to_csv' do
      create(:city, title_ru: 'Воронеж')
      hash = {"class_name"=>"Core::City", "attributes"=>{"0"=>{"value"=>"core_cities.id",
          "label"=>"core_cities.id|integer", "aggregate"=>"COUNT"}}}

      csv = CSV.parse(ConstructorService.new(hash).to_csv)
      expect(csv).to eq [["count_core_cities.id"], ["2"]]
    end

    it "group by select" do
      country = create(:country, title_en: 'Germany')
      create(:city, title_en: 'Hamburg', country: country)
      create(:city, title_en: 'Frankfurt', country: country)
      hash = {"class_name"=>"Core::City", "attributes"=>{"0"=>{"value"=>"core_cities.country_id",
         "label"=>"country_id|integer", "order"=>"GROUP"}, "1"=>{"value"=>
           "core_cities.id", "label"=>"id|integer", "aggregate"=>"COUNT"}}}
      expect(ConstructorService.new(hash).to_a).to match_array [{"core_cities.country_id"=>country.id, "count_core_cities.id"=>2},
        {"core_cities.country_id"=>1, "count_core_cities.id"=>1}]
    end

    it "queries with joins" do
      hash = {"class_name"=>"Core::City", "attributes"=>{"0"=>{
        "value"=>"core_cities.title_ru", "label"=>"core_cities.title_ru|string"}, "1"=>{
          "value"=>"organizations.projects.title",
          "label"=>"organizations.projects.title|string"}},
          "association"=>{"organizations"=>{"join_type"=>"inner",
            "projects"=>{"join_type"=>"left"}}}}

      sql = ConstructorService.new(hash).to_sql
      expect(sql).to include('INNER JOIN "core_organizations"')
      expect(sql).to include('LEFT OUTER JOIN "core_projects"')
      expect(sql).to include('core_projects.title AS "core_projects.title"')
      expect(ConstructorService.new(hash).to_a).to be_an(Array)
    end

    it "group by with assocations" do
      org1 = create(:organization, name: 'org1')
      org2 = create(:organization, name: 'org2')
      create(:organization_department, organization: org1)
      create(:organization_department, organization: org1)
      create(:organization_department, organization: org2)
      create(:organization_department, organization: org2)
      create(:organization_department, organization: org2)

      hash = {"class_name"=>"Core::Organization", "attributes"=>{"0"=>{"value"=>"core_organizations.name",
              "label"=>"core_organizations.name|string", "order"=>["GROUP"]},
              "1"=>{"value"=>"departments.id", "label"=>"departments.id|integer", "aggregate"=>"COUNT"}},
              "association"=>{"list"=>"departments", "departments"=>{"join_type"=>"inner"}}}
      constructor = ConstructorService.new(hash)

      expect(constructor.count).to eq 2
      expect(constructor.to_a).to match_array [
        {"core_organizations.name"=>"org1", "count_departments.id"=>2},
        {"core_organizations.name"=>"org2", "count_departments.id"=>3}
      ]
    end

    it "performs custom inner join with base table" do
      org1 = create(:organization, name: 'org1')
      org2 = create(:organization, name: 'org2')

      params = {"class_name"=>"Core::Organization", "attributes"=>{"0"=>{"value"=>"core_organizations.name",
                "label"=>"core_organizations.name|string"}, "1"=>{"value"=>"c_core_organization_kinds.name_ru",
                "label"=>"c_core_organization_kinds.name_ru|string"}}, "association"=>
                {"custom-join-1557138479832"=>{"join_table"=>"Core::OrganizationKind",
                  "alias"=>"c_core_organization_kinds", "join_type"=>"inner",
                  "on"=>"core_organizations.kind_id= c_core_organization_kinds.id"}}}

      expect(ConstructorService.new(params).to_a).to contain_exactly(
        {"core_organizations.name"=>"org1", "c_core_organization_kinds.name_ru"=>org1.kind.name_ru},
        {"core_organizations.name"=>"org2", "c_core_organization_kinds.name_ru"=>org2.kind.name_ru}
      )
    end

    it "rewrites having for db" do
      org1 = create(:organization, name: 'org1')
      create(:organization, name: 'org2')
      kind_name_ru = org1.kind.name_ru
      params = {"class_name"=>"Core::Organization", "attributes"=>{"0"=>{"value"=>"kind.name_ru",
             "label"=>"kind.name_ru|string"}, "1"=>{"value"=>"core_organizations.name", "label"=>"core_organizations.name|string"}},
             "association"=>{"list"=>"kind", "kind"=>{"join_type"=>"inner"}},
             "where"=>"kind.name_ru = '#{kind_name_ru}'", "per"=>"20"}
      result = ConstructorService.new(params).to_a

      expect(result).to include({"kind.name_ru"=>kind_name_ru, "core_organizations.name"=>"org1"})
      expect(result.map { |row| row["kind.name_ru"] }).to all(eq(kind_name_ru))
    end

    it "rewrites on for db" do
      create(:cluster)
      params = {"class_name"=>"Core::Cluster", "attributes"=>{"0"=>{"value"=>"core_clusters.admin_login",
        "label"=>"core_clusters.admin_login|string"}}, "association"=>
        {"custom-join-1557265646481"=>{"join_table"=>"Core::Cluster",
          "alias"=>"c_core_clusters", "join_type"=>"inner",
          "on"=>"core_clusters.id=c_core_clusters.id"}}, "per"=>"20"}

      expect(ConstructorService.new(params).to_a).to eq [{"core_clusters.admin_login"=>"root"}]
    end

    it "rewrites for db" do
      params = {"class_name"=>"Core::Project", "attributes"=>{"0"=>{"value"=>"organization.departments.name",
        "label"=>"organization.departments.name|string"}}, "association"=>{"list"=>
          "organization", "organization"=>{"join_type"=>"inner",
        "list"=>"departments", "departments"=>{"join_type"=>"inner"}}}, "per"=>"20"}

      sql = ConstructorService.new(params).to_sql
      expect(sql).to include('INNER JOIN "core_organizations"')
      expect(sql).to include('INNER JOIN "core_organization_departments"')
      expect(sql).to include('core_organization_departments.name AS')
      expect(ConstructorService.new(params).to_a).to be_an(Array)
    end

    it "rewrites for db2" do
      org = create(:organization)
      params = {"class_name"=>"Core::Organization", "attributes"=>{"0"=>{"value"=>
        "city.title_en", "label"=>"city.title_en|string"}},
        "association"=>{"list"=>"kind", "city"=>{"join_type"=>"inner"},
        "kind"=>{"join_type"=>"inner"}}, "per"=>"20"}

      expect(ConstructorService.new(params).to_a).to include({"city.title_en"=>org.city.title_en})
    end

    it "gets users who use gpu" do
      params = {"class_name"=>"User", "alias"=>"users", "attributes"=>{"0"=>
        {"value"=>"surveys.values.field.name_ru", "label"=>"surveys.values.field.name_ru|text"},
        "1"=>{"value"=>"surveys.values.value", "label"=>"surveys.values.value|text"},
        "2"=>{"value"=>"users.id", "label"=>"users.id|integer"},
        "3"=>{"value"=>"surveys.session.description_ru", "label"=>"surveys.session.description_ru|text",
          "order"=>["DESC"]}, "4"=>{"value"=>"users.email", "label"=>"users.email|string"}},
          "association"=>{"list"=>"surveys", "surveys"=>{"join_type"=>"inner",
            "list"=>"session", "values"=>{"join_type"=>"inner", "list"=>"field",
              "field"=>{"join_type"=>"inner"}}, "session"=>{"join_type"=>"inner"}}},
              "where"=>"surveys.values.field.name_en LIKE '%GPU%' AND surveys.values.value IS NOT NULL", "per"=>"20"}

      constructor = ConstructorService.new(params)
      expect(constructor.to_sql).to include('INNER JOIN "sessions_user_surveys"')
      expect(constructor.to_sql).to include('INNER JOIN "sessions_survey_values"')
      expect(constructor.to_sql).to include('INNER JOIN "sessions_survey_fields"')
      expect(constructor.to_sql).to include('INNER JOIN "sessions_sessions"')
      expect(constructor.to_a).to be_an(Array)
    end

  end
end
