module Reports
  require 'main_spec_helper'
  describe ConstructorService do

    it '#class_info' do
      ConstructorService.class_info(['Core::Project']).inspect
    end

    it "usual select" do
      # puts User.all.to_a.map(&:email).inspect
      create(:city, title_ru: 'Воронеж')
      hash = {
                "class_name"=>"Core::City",
                "attributes"=>{"0"=>{"value"=>"core_cities.title_ru", "label"=>"core_cities.title_ru|string"}}
              }
      expect(ConstructorService.new(hash).to_a).to eq [{"core_cities.title_ru"=>"Москва"}, {"core_cities.title_ru"=>"Воронеж"}]
    end

    it "usual select" do
      # puts User.all.to_a.map(&:email).inspect
      # create(:city, title_ru: 'Воронеж')
      hash = {
                "class_name"=>"Core::City",
                "attributes"=>{"0"=>{"value"=>"core_cities.title_ru", "label"=>"core_cities.title_ru|string"},
                               "1"=>{"value"=>"UPPER(core_cities.title_ru)", "alias" => "u"}}
              }
      expect(ConstructorService.new(hash).to_a).to eq [{"core_cities.title_ru"=>"Москва", "u" => "МОСКВА"}]

      # expect(ConstructorService.new(hash).to_a).to eq [{"core_cities.title_ru"=>"Москва"}, {"core_cities.title_ru"=>"Воронеж"}]
    end


    it "order by query" do
      create(:city, title_ru: 'Воронеж')
      hash = {"class_name"=>"Core::City", "attributes"=>{"0"=>{"value"=>"core_cities.title_ru",
        "label"=>"core_cities.title_ru|string", "order"=>"ASC"}}}
      puts ConstructorService.new(hash).to_sql
      expect(ConstructorService.new(hash).to_a).to eq [{"core_cities.title_ru"=>"Воронеж"}, {"core_cities.title_ru"=>"Москва"}]
    end

    it 'selects count' do
      create(:city, title_ru: 'Воронеж')
      hash = {"class_name"=>"Core::City", "attributes"=>{"0"=>{"value"=>"core_cities.id",
          "label"=>"core_cities.id|integer", "aggregate"=>"COUNT"}}}

      expect(ConstructorService.new(hash).to_a).to eq [{"count_core_cities.id"=>'2'}]

    end

    it '#to_csv' do
      create(:city, title_ru: 'Воронеж')
      hash = {"class_name"=>"Core::City", "attributes"=>{"0"=>{"value"=>"core_cities.id",
          "label"=>"core_cities.id|integer", "aggregate"=>"COUNT"}}}

      puts ConstructorService.new(hash).to_csv.inspect

    end


    it "group by select" do
      country = create(:country, title_en: 'Germany')
      create(:city, title_en: 'Hamburg', country: country)
      create(:city, title_en: 'Frankfurt', country: country)
      hash = {"class_name"=>"Core::City", "attributes"=>{"0"=>{"value"=>"core_cities.country_id",
         "label"=>"country_id|integer", "order"=>"GROUP"}, "1"=>{"value"=>
           "core_cities.id", "label"=>"id|integer", "aggregate"=>"COUNT"}}}
      expect(ConstructorService.new(hash).to_a).to match_array [{"core_cities.country_id"=>country.id.to_s, "count_core_cities.id"=>2.to_s},
        {"core_cities.country_id"=>'1', "count_core_cities.id"=>'1'}]
    end

    it ".convert_left_to_inner" do
      hash =  {"accesses"=>{"join_type"=>"left", "project"=>{"join_type"=>"left",
              "card"=>{"join_type"=>"inner"}}, "fields"=>{"join_type"=>"left"}}}

      ConstructorService.convert_left_to_inner(hash)

      expect(hash).to eq("accesses"=>{"join_type"=>"inner", "project"=>{"join_type"=>"inner",
              "card"=>{"join_type"=>"inner"}}, "fields"=>{"join_type"=>"left"}})

    end
    it "queries with joins" do
      # country = create(:country, title_en: 'Germany')
      # create(:city, title_en: 'Hamburg', country: country)
      # create(:city, title_en: 'Frankfurt', country: country)

      hash = {"class_name"=>"Core::City", "attributes"=>{"0"=>{
        "value"=>"core_cities.title_ru", "label"=>"core_cities.title_ru|string"}, "1"=>{
          "value"=>"organizations.projects.title",
          "label"=>"organizations.projects.title|string"}},
          "association"=>{"organizations"=>{"join_type"=>"inner",
            "projects"=>{"join_type"=>"left"}}}}

      puts ConstructorService.new(hash).to_a
            # expect(ConstructorService.new(hash).to_a).to eq [{"country_id"=>country.id, "count_id"=>2},
            #   {"country_id"=>1, "count_id"=>1}]

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
      # puts ConstructorService.new(hash).to_sql
      constructor = ConstructorService.new(hash)
      # ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)
      puts constructor.count.inspect.blue
      puts ConstructorService.new(hash).to_a
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

      puts Core::OrganizationKind.all.to_a.inspect
      puts ConstructorService.new(params).to_sql.inspect.blue
      puts ConstructorService.new(params).to_a.inspect
      # ConstructorService.new(params).to_a.inspect


    end

    it "rewrites having for db" do
      org1 = create(:organization, name: 'org1')
      org2 = create(:organization, name: 'org2')
      kind_name_ru = org1.kind.name_ru
      params = {"class_name"=>"Core::Organization", "attributes"=>{"0"=>{"value"=>"kind.name_ru",
             "label"=>"kind.name_ru|string"}, "1"=>{"value"=>"core_organizations.name", "label"=>"core_organizations.name|string"}},
             "association"=>{"list"=>"kind", "kind"=>{"join_type"=>"inner"}},
             "where"=>"kind.name_ru = '#{kind_name_ru}'", "per"=>"20"}
      puts ConstructorService.new(params).to_a.inspect
    end

    it "rewrites on for db" do
      # org1 = create(:organization, name: 'org1')
      # org2 = create(:organization, name: 'org2')
      # kind_name_ru = org1.kind.name_ru
      params = {"class_name"=>"Core::Cluster", "attributes"=>{"0"=>{"value"=>"core_clusters.admin_login",
        "label"=>"core_clusters.admin_login|string"}}, "association"=>
        {"custom-join-1557265646481"=>{"join_table"=>"Core::Cluster",
          "alias"=>"c_core_clusters", "join_type"=>"inner",
          "on"=>"core_clusters.id=c_core_clusters.id"}}, "per"=>"20"}
      puts ConstructorService.new(params).to_a.inspect
    end
    it "rewrites for db" do
      params = {"class_name"=>"Core::Project", "attributes"=>{"0"=>{"value"=>"organization.departments.name",
        "label"=>"organization.departments.name|string"}}, "association"=>{"list"=>
          "organization", "organization"=>{"join_type"=>"inner",
        "list"=>"departments", "departments"=>{"join_type"=>"inner"}}}, "per"=>"20"}
      puts ConstructorService.new(params).to_a.inspect

    end
    it "rewrites for db2" do
      params = {"class_name"=>"Core::Organization", "attributes"=>{"0"=>{"value"=>
        "city.title_en", "label"=>"city.title_en|string"}},
        "association"=>{"list"=>"kind", "city"=>{"join_type"=>"inner"},
        "kind"=>{"join_type"=>"inner"}}, "per"=>"20"}
      puts ConstructorService.new(params).to_a.inspect

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

      puts ConstructorService.new(params).to_a.inspect

    end






  end
end
