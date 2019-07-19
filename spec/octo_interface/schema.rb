module OctoInterface
  class Person < ::ApplicationRecord
    has_and_belongs_to_many :hobbies, -> { readonly }
    has_many :articles, -> { readonly }
    has_many :friends

  end

  class Article < ::ApplicationRecord
    belongs_to :person
  end

  class Friend < ::ApplicationRecord
    belongs_to :person
  end


  class Hobby < ::ApplicationRecord
    has_and_belongs_to_many :persons
  end

  ActiveRecord::Schema.define do
    create_table :people, force: true do |t|
      t.string   :name
    end

    create_table :friends, force: true do |t|
      t.string   :name
      t.integer  :person_id
    end

    create_table :articles, force: true do |t|
      t.integer  :person_id
      t.string   :title
      t.text     :subject_header
      t.text     :body
      t.string   :type
      t.boolean  :published, default: true
    end

    create_table :hobbies, force: true do |t|
      t.integer  :article_id
      t.integer  :person_id
      t.string   :name
    end

    create_join_table :people, :hobbies, force: true
  end
end
