module Face
  class MyMenu

    delegate :can?, :t, :current_user, to: :@controller
    include ActionDispatch::Routing::RouteSet::MountedHelpers
    #
    # MountedHelpers = ActionDispatch::Routing::RouteSet::MountedHelpers
    @instances ||= {}
    attr_reader :blocks, :name, :controller

    def self.instances
      @instances
    end

    def initialize(name = nil)
      @name = name
      @blocks = []
      @items = []
    end

    def add_item(key, name, url, *args)
      @items << MyMenuItem.new(key, name, url, self, *args)
    end

    def add_item_without_key(name, url, *args)
      @items << MyMenuItem.new(nil, name, url, self, *args)
    end


    def add_item_if_may(key, name, url, *args)
      abilities = Octoface.action_and_subject_by_path(*args.first)
      return unless can?(*abilities)

      add_item(key, name, url, *args)
      # @items << MyMenuItem.new(key, name, url, @controller, *args)
    end

    def items_from_db(controller)
      conditions = if UsersMenu.custom?(controller.current_user, name)
                     { admin: false, user: controller.current_user, menu: name }
                   else
                     { admin: true, menu: name }
                   end
      prefs = MenuItemPref.where(conditions).order(:position).to_a
      items = items(controller).dup
      results = []
      prefs.each do |pref|
        result = items.detect { |i| i.key == pref.key }
        if result
          results << result
          items.delete result
        end
      end
      results += items
      results
    end

    def items(controller)
      @controller = controller
      @items.clear if @blocks.any?
      @blocks.each do |block|
        instance_eval &block
      end
      # conditions = {user: @user, admin: true, }
      @items
    end

    def method_missing(m, *args, &block)
      @controller.send(m, *args, &block)
    end

    def self.items_for(name, &block)
      instance = @instances[name]
      if instance
        @instances[name].blocks << block
        return
      else
        if singleton_methods.include?(name)
          raise 'Please provide name which is not included in singleton_methods'
        end

        define_singleton_method(name) do |controller|
          @instances[name].items_from_db(controller)
        end
        @instances[name] = new(name)
        @instances[name].blocks << block
      end
    end

    def self.init_menu
        admin_menu = ["Пользователи", "Проекты", "Пакеты", "Поддержка",
         "Поручительства", "Заявки", "Отчёты", "Перерегистрации", "Организации", "Кластеры",
         "Логи кластеров", "Виды квот на ресурсы", "Типы проектов", "Типы организаций",
         "Группы доступа", "Причины отказа предоставления отчёта", "Направления исследований",
         "Критические технологии", "Области науки", "Статистика", "Рассылка",
         "Мониторинг очередей выполнения задач", "Страны", "Города", "Комментарии",
         "Аппаратура", "Emails", "Опции", "Журнал", "Конструктор запросов", "API",
         "Справка", "Модули Octoshell"]
         user_menu = ["Профиль", "Поддержка", "Проекты", "Перерегистрации",
                      "Пакеты", "Статистика", "Эффективность", "Комментарии",
                      "Редактировать расположение элементов меню"]

         fake_controller = Class.new(::ApplicationController) do
           def current_user
             User.superadmins.first
           end

           def can?(*_args)
             true
           end
         end
         Face::MenuItemPref.destroy_all
         Face::MyMenu.instances.each_value do |value|
           view_items = value.items(fake_controller.new).dup
           new_items = []
           if value.name == :admin_submenu
             new_items = find_items(admin_menu, view_items)
           else
             new_items = find_items(user_menu, view_items)
           end
           # raise 'new_items.count != view_items.count' if new_items.count != view_items.count
           conditions = { menu: value.name.to_s, admin: true }
           rel = Face::MenuItemPref.where(conditions)

           (new_items + view_items).map(&:key).each do |key|
             Face::MenuItemPref.create!(conditions.merge(key: key, position: rel.last_position + 1))
           end
         end
    end

    def self.find_items(menu, view_items)
      menu.map do |t|
        elem = view_items.detect do |item|
          item.name[0..(t.length - 1)] == t
        end
        raise "submenu error: #{t.inspect}" unless elem
        view_items.delete(elem)
        elem
      end
    end


    def self.validate_keys!
      fake_controller = Class.new(::ApplicationController) do
        def current_user
          User.superadmins.new
        end

        def can?(*_args)
          true
        end
      end
      @instances.each_value do |value|
        keys = value.items(fake_controller.new).map(&:key)
        key = keys.detect { |k| keys.count(k) > 1 }
        raise "#{key} is specified twice" if key
        conditions = { menu: value.name.to_s, admin: true }
        keys.each do |k|
          rel = MenuItemPref.where(conditions.merge(key: k))
          rel.first_or_create!(position: MenuItemPref.where(conditions).last_position + 1)
        end
      end
    end
  end
end
