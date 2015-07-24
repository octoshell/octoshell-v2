module Core
  class Access < ActiveRecord::Base
    belongs_to :project
    belongs_to :cluster

    has_many :fields, class_name: "AccessField", inverse_of: :access, dependent: :destroy
    accepts_nested_attributes_for :fields

    validates :project, :cluster, presence: true

    state_machine initial: :opened do
      state :opened
      state :closed

      event :close do
        transition :opened => :closed
      end

      event :reopen do
        transition :closed => :opened
      end
    end

    def quota_resources_info
      fields.map(&:to_s).join(" | ")
    end

    # Требования к теребоньке.
    #
    # Выполнять все действия в по одному ssh-соединению
    # логировать все команды и результаты выполнения
    # синхронизовать проект
    # синхронизовать участников проекта
    # для участников проекта закидывать ключи через scp

    def synchronize!
      Synchronizer.new(self).run!
    end
  end
end
