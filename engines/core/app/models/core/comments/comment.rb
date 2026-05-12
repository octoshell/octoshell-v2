module Core
  module Comments
    class Comment < ApplicationRecord
      self.table_name = 'core_comments'

      belongs_to :author,
                 class_name: '::User',
                 foreign_key: :author_id,
                 inverse_of: :comments

      belongs_to :cluster, class_name: 'Core::Cluster'

      
      def system
        cluster
      end

      def system=(v)
        self.cluster = v
      end

      has_many :comment_nodes,
               class_name: 'Core::Comments::CommentNode',
               foreign_key: :comment_id,
               inverse_of: :comment,
               dependent: :destroy

      has_many :nodes,
               through: :comment_nodes,
               class_name: 'Core::Analytics::Node',
               source: :node

      has_many :comment_tags,
               class_name: 'Core::Comments::CommentTag',
               foreign_key: :comment_id,
               inverse_of: :comment,
               dependent: :destroy

      has_many :tags,
               through: :comment_tags,
               class_name: 'Core::Comments::Tag',
               source: :tag

      enum :severity, {
        info: 0,
        warning: 1,
        incident: 2
      }, prefix: :severity

      validates :title, presence: true
      validates :valid_from, presence: true
      validates :severity, presence: true
      validates :system, presence: true
      validates :author, presence: true

      validates :reason_group_id, presence: true, on: :create
      validates :reason_id, presence: true, on: :create
      validate  :reason_belongs_to_group, on: :create

      validate :valid_to_not_before_valid_from

      scope :recent_first, -> { order(valid_from: :desc, created_at: :desc) }
      scope :current, ->(moment = Time.current) {
        where('valid_from <= ? AND (valid_to IS NULL OR valid_to >= ?)', moment, moment)
      }

      REASON_GROUPS = [
        { id: 1, name: 'Нештатные ситуации', reasons: [
          { id: 101, name: 'Аномально высокая уличная температура' },
          { id: 102, name: 'Отключение/недоступность части системы охлаждения' },
          { id: 103, name: 'Ограничение энергоснабжения' },
          { id: 104, name: 'Аварийная ситуация (общее)' },
          { id: 105, name: 'Снижение производительности сети межсоединений' },
          { id: 106, name: 'Массовый отказ части вычислительных узлов' },
          { id: 107, name: 'Недоступность/проблемы с узлами логина' },
          { id: 108, name: 'Недоступность/нестабильность системы очередей' }
        ]},
        { id: 2, name: 'Изменение режима работы СКЦ', reasons: [
          { id: 201, name: 'Выделены ресурсы для больших задач' },
          { id: 202, name: 'Выделены ресурсы для приоритетных проектов' },
          { id: 203, name: 'Введение в эксплуатацию нового оборудования' },
          { id: 204, name: 'Временное снижение пользовательских лимитов' },
          { id: 205, name: 'Включен режим бенчмарков / тестирования производительности' },
          { id: 206, name: 'Ресурсы выделены под образовательные нужды (курсы, мастер-классы)' },
          { id: 207, name: 'Тестирование новых настроек системного ПО' }
        ]},
        { id: 3, name: 'Профилактические и ремонтные работы', reasons: [
          { id: 301, name: 'Обновление системного ПО' },
          { id: 302, name: 'Изменения в настройках файловой системы' },
          { id: 303, name: 'Обновление системы поддержки функционирования СКЦ' },
          { id: 304, name: 'Профилактика/ремонт дисковой подсистемы' },
          { id: 305, name: 'Работы с сетевой инфраструктурой' },
          { id: 306, name: 'Работы с энергоснабжением / UPS' },
          { id: 307, name: 'Работы с системой охлаждения' },
          { id: 308, name: 'Замена/расширение вычислительных узлов' },
          { id: 309, name: 'Плановые работы в машинном зале' }
        ]}
      ].freeze

      private

      def valid_to_not_before_valid_from
        return if valid_to.blank? || valid_from.blank?
        errors.add(:valid_to, 'не может быть раньше даты начала действия') if valid_to < valid_from
      end

      def reason_belongs_to_group
        return if reason_group_id.blank? || reason_id.blank?

        allowed = Core::Comments::Comment::REASON_GROUPS
                    .find { |g| g[:id].to_i == reason_group_id.to_i }
        ok = allowed && allowed[:reasons].any? { |r| r[:id].to_i == reason_id.to_i }

        errors.add(:reason_id, 'не соответствует выбранной категории') unless ok
      end
    end
  end
end