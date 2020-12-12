module CloudComputing
  class ItemKind < ApplicationRecord
    acts_as_nested_set
    enum cloud_type: %i[no virtual_machine]
    has_many :conditions, as: :from, dependent: :destroy
    has_many :to_conditions, as: :to, class_name: Condition.to_s, dependent: :destroy

    has_many :items, inverse_of: :item_kind, dependent: :destroy
    # has_many :request, -> { where("#{Position.table_name}": { holder_type: Request.to_s }) },
    #                           foreign_key: 'holder_id'



    accepts_nested_attributes_for :conditions, allow_destroy: true

    translates :name, :description
    validates_translated :name, presence: true, uniqueness: { scope: :parent_id }

    validates :cloud_type, uniqueness: true, unless: :no_type?

    # before_save do
    #   descendants.each do |dec|
    #     next if dec.cloud_type == cloud_type
    #
    #     dec.cloud_type = cloud_type
    #     dec.save!
    #   end
    # end
    def self.virtual_machine_cloud_type
      find_by(cloud_type: 'virtual_machine')
    end

    def self.human_enum_name(enum_name, enum_value)
      I18n.t("activerecord.attributes.#{model_name.i18n_key}.#{enum_name.to_s.pluralize}.#{enum_value}")
    end

    def self.human_cloud_type(enum_value)
      human_enum_name(:cloud_type, enum_value)
    end

    def self.human_cloud_types
      cloud_types.keys.map do |c|
        [human_cloud_type(c), c]
      end
    end

    # def as_json(_options = nil)
    #   {id: id, text: name }
    # end


    def no_type?
      cloud_type == 'no'
    end


    def human_cloud_type
      self.class.human_cloud_type cloud_type
    end

    def child_index=(idx)
      return if new_record?

      if parent
        move_to_child_with_index(parent, idx.to_i)
      else
        move_to_root_with_index(idx.to_i)
      end
    end

    def move_to_root_with_index(index)
      roots = self.class.roots
      if roots.count == index
        move_to_right_of(roots.last)
      else
        my_position = roots.to_a.index(self)
        if my_position && my_position < index
          move_to_right_of(roots[index])
        elsif my_position && my_position == index
          # do nothing. already there.
        else
          move_to_left_of(roots[index])
        end
      end
    end

    def to_s
      name
    end
  end
end
