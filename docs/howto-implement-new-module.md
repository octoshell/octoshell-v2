# How to implement new Octoshell module

Let assume, that you want to create new octoshell module 'Foo'. Here are instructions for most important parts of this.

## Create engine and models/view/controllers

First, you need to go to the root dir and execute:

    bundle exec rails plugin new foo --mountable

Then create a scaffold or models, views and controllers as you wish. Let's create a scaffold for the model 'Bar' with one field 'name'. Go into 'engines/foo' and execute:

    bundle exec rails g scaffold bar name:string

Next, you should fix a controller. Change a string with class definition to:

    class ApplicationController < ::ApplicationController

## Remember about locale!

Create `engines/foo/config/locales/en.yml` and `engines/foo/config/locales/en.yml` files. Fill them carefully, do not place any text/labels directly into your view files.

## Annotate models

Execute this:

    bundle exec annotate -p top --model-dir engines/foo/app/models/foo

## Add menu point

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

## Admin pages

If you want to add pages for administrators, you need to:

### Create folders:
  - 'engines/foo/app/controllers/foo/admin'
  - 'engines/foo/app/views/foo/admin'

### Create admin controller(s):
Create engines/foo/app/controllers/foo/admin/application_controller.rb

    module Foo
      class Admin::ApplicationController < Api::ApplicationController
        protect_from_forgery with: :exception
      end
    end


In engines/foo/app/controllers/foo/admin/bar_controller.rb

    module Api
      class Admin::AccessKeysController < Admin::ApplicationController
      ...

In views and controllers remember to change links in urls like this:

- bootstrap_form_for [:admin, @bar]
- link_to '...', [:admin, @bar]
- link_to 'new bar', new_admin_bar_path
- redirect_to [:admin, @bar]

### Add route lines

Something like this:

    namespace :admin do
      resources :bar
      resources :baz
    end

## Add menu points

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

# Access

All access rights are managed by MayMay gem. To create new Access object create rake task:

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

Then you can add to admin controllers this:

    before_action :authorize_admins
    def authorize_admins
      authorize!(:access, :foo) # here 'foo' is the same as in Ability.create
    end


# Things to remember!!

- run `ROOT/after_change.sh` after you've add any migrations
- run `i18n-tasks health` in ROOT, periodically, to check/fix your locales
- run `bundle exec annotate -p top --model-dir engines/foo/app/models/foo`


# Howtos

## Create has_and_belongs_to_many table:

If you need to create has_and_belongs_to_many relation between Bar and Baz models in Foo module, execute this:

    bundle exec rails g migration create_foo_bar_baz

Then open created migration and fill in:

    create_table :foo_bar_bazs, :id => false do |t|
      t.belongs_to :bar
      t.belongs_to :baz
    end

Note ':id => false' and plural name of new table.

## Show markdown text

Use this helper:

    = markdown @text

If you need to insert editor with preview, then do this:

Put your text into textarea like this:

    = bootstrap_form_for @my_model do |f|
      = markdown_area f, @my_model.text
