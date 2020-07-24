# Как создать модуль Octoshell

Основной способ расширения функциональности Octoshell - написание новых модулей.
Далле полагаем, что мы будем создавать модуль **Foo**. Ниже инструкции по
основным шагам его создания.

## Создайте engine и models/view/controllers

Переходим в корневой каталог Octoshell и выполняем:

    bundle exec rails plugin new foo --mountable

Теперь создаём модели/вьюхи/контроллеры. Воспользуемся scaffold-ом. Создадим
модель `Bar` с полем `name`. Переходим в 'engines/foo' и выполняем:

    bundle exec rails g scaffold bar name:string

Далее, правим контроллер, меняем строку объявления класса:

    class ApplicationController < ::ApplicationController

## Не забываем локализацию!

Создаём файлы `engines/foo/config/locales/en.yml` и `engines/foo/config/locales/en.yml`.
Аккуратно заполняем, не оставляем во view явных текстовых строк.

## Аннотация моделей

Выполните:

    bundle exec annotate -p top --model-dir engines/foo/app/models/foo

Эта команда вставит в модель описание полей из БД, что может очень пригодиться в дальнейшем.

## Добавляем пункт меню

**Тут всё устарело, скоро поменяем**

Edit engines/foo/views/layouts/foo/application_layout.slim:

    - content_for :user_engine_submenu do
        br
        ul class="nav nav-pills"
          - foo_user_submenu_items.each do |item|
            li class="#{"active" if item.active?(request.fullpath)}"
              = link_to item.name, item.url

    = render template: "layouts/application"

Edit the file ROOT/app/decorators/controllers/application_controller_decorator.rb, add following line to 'user_submenu_items':

   menu.add_item(Face::MenuItem.new(
     name: t("user_submenu.foo"),
     url: foo.foo_path))

In 'url' option you can place any url you think is appropriate. You should add a translation for 'user_submenu.foo' into ROOT/config/locales/en.yml and ROOT/config/locales/ru.yml.

If you want to add submenu, then in app/helpers/foo/application_helper define this:

    def fpp_submenu_items
      menu = Face::Menu.new
      menu.items.clear
      foo_first_submenu = Face::MenuItem.new(
        name: t("foo.engine_submenu.MYSUBMENU"),
        url: WHERE_YOU_WANT,
        regexp: /PART_OF_URL_TO_MATCH/)

      def foo_first_submenu.active?(current_url)
        /PART_OF_URL_TO_MATCH/ =~ current_url
      end
      menu.add_item(foo_first_submenu)
      menu.items
    end

## Странички админа

Если нужно добавить страницы администратора, то выполняем:

### Создаём каталоги:
  - 'engines/foo/app/controllers/foo/admin'
  - 'engines/foo/app/views/foo/admin'

### И контроллеры для админа:
Создаём engines/foo/app/controllers/foo/admin/application_controller.rb 

    module Foo
      class Admin::ApplicationController < Foo::ApplicationController
        protect_from_forgery with: :exception
      end
    end


В engines/foo/app/controllers/foo/admin/bar_controller.rb 

    require_dependency "foo/admin/application_controller"
    module Foo
      class Admin::FooController < Admin::ApplicationController
      ...

Во view и контроллерах не забываем указывать ссылки:

- bootstrap\_form\_for [:admin, @bar]
- link\_to '...', [:admin, @bar]
- link\_to 'new bar', new\_admin\_bar\_path
- redirect\_to [:admin, @bar]

### Добавляем роуты

Примерно так:

    namespace :admin do
      resources :bar
      resources :baz
    end

## И пункты в админское меню

**Тут тоже всё устарело**
Edit engines/foo/views/layouts/foo/application_layout.slim:

    - content_for :admin_engine_submenu do
        br
        ul class="nav nav-pills"
          - foo_admin_submenu_items.each do |item|
            li class="#{"active" if item.active?(request.fullpath)}"
              = link_to item.name, [:admin, item.url]

    = render template: "layouts/application"

Edit the file ROOT/app/decorators/controllers/application_controller_decorator.rb, add following line to 'admin_submenu_items':

   menu.add_item(Face::MenuItem.new(
     name: t("admin_submenu.foo"),
     url: foo.foo_path))


If you want to add submenu, then in app/helpers/foo/application_helper define this:

    def foo_admin_submenu_items
      # here all just like at foo_submenu_items
    end

# Права доступа

Управление правами делается через гем CanCanCan. Чтобы создать новое правило
доступа создайте rake task:

    engines/foo/lib/tasks/foo_tasks.rake

    namespace :foo do
      task create_abilities: :environment do
        puts 'Creating abilities for groups'
        Group.all.each do |g|
          Ability.create(action: 'manage', subject: 'foo',
                         group_id: g.id, available: g.name == 'superadmins')
        end
      end
    end

Теперь можно, например, добавить проверку в админский контроллер:

    before_action :authorize_admins
    def authorize_admins
      authorize!(:access, :foo) # here 'foo' is the same as in Ability.create
    end


# Важные вещи, не забывайте о них

- запускайте `ROOT/after_change.sh` после новых миграций
- запускайте `i18n-tasks health` чтобы проверить/обновить локализации
- запускайте `bundle exec annotate -p top --model-dir engines/foo/app/models/foo`


# Как сделать...

## Создать отношение has\_and\_belongs\_to\_many:

Чтобы создать отношение has\_and\_belongs\_to\_many между моделями Bar и Baz
в модуле Foo, выполняем:

    bundle exec rails g migration create_foo_bar_baz

Редактируем созданную миграцию:

    create_table :foo_bar_bazs, :id => false do |t|
      t.belongs_to :bar
      t.belongs_to :baz
    end

Обратите внимание на ':id => false' и множественное число **последнего**
элемента в имени таблицы.

## Показать текст в формате markdown

Используйте хелпер:

    = markdown @text

Если нужно вставить редактор с превью, пишем так:

    = bootstrap_form_for @my_model do |f|
      = markdown_area f, @my_model.text
