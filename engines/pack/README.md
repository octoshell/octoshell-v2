# Octoshell Pack

Модуль предоставляет возможность ввести учет программных продуктов.

## Инструкция по установке и настройке:

Прежде всего, должны быть установлены модули Core, Support, Face, Authentication
В Gemfile базового приложения дописать

```ruby
gem "pack",             path: 'engines/pack'
```
В config/routes.rb базового приложения дописать

```ruby
mount Pack::Engine, :at => "/pack"

```

В config/initializers/asets.rb базового приложения дописать

```ruby
Rails.application.config.assets.precompile += %w( pack/pack.css )

```
В консоли, в корне базового приложения

```bash
bundle install
```

Там же

```bash
bundle exec rake  pack:install
```


В app/decorators/controllers/application_controller_decorator.rb  дописать:

 В методе user_submenu_items:

```ruby
menu.add_item(Face::MenuItem.new({name: "Пакеты",
                                      url: pack.root_path,
                                      regexp: /pack/}))

```

В методе admin_submenu_items:
```ruby

menu.add_item(Face::MenuItem.new({name: "Пакеты",
                                      url: pack.admin_root_path,
                                      regexp: /pack\/admin/}))  if may? :manage, :packages

```

Также добавить в очередь sidekiq:


```bash
 -q pack_worker 
```



В whenever(config/schedule.rb):
```ruby

every 1.day do
	rake "pack:expired"
   
end
```

Добавить в config/locales/ru.yml

 packages:
      manage: Полный доступ к Пакетам


Для того,чтобы работала аякс пагинация,нужно поправить view для каминари:

В app/views/kaminari

Везде добавить  opts = { remote: remote}

Пример:

```ruby
 link_to raw(t "views.pagination.first"), url,opts = { remote: remote}

```


В engines/support/app/views/support/admin/tickets/show.html.slim в любом разумном месте дописать следующее:

```ruby
= link_to t("actions.edit_access"), pack.admin_access_path(@ticket.pack_accesses.first), class: "btn btn-default"  if @ticket.pack_accesses.exists?
```
Это нужно для того,чтобы администратор из тикета сразу мог перейти к редактированию доступа.




This project uses MIT-LICENSE.
