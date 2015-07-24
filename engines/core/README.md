# Octoshell Core

Модуль предоставляет работу с проектами и кластерами.
Пользователь создаёт проект. Администратор создаёт кластеры.
Пользователь делает запрос на ресурсы на кластере, администратор рассматривает заявку и подтверждает/отклоняет её.
После подтверждения заявки на ресурс, для проекта выделяется Доступ к ресурсам.
Реализована синхронизация проектов с кластерами через доступы.

Для работы модулю необходима информация о том, какой класс в системе представляет пользователей системы (по умолчанию `User`).
Реализована авторизация пользователей.

## Инструкция по установке и настройке:

В Gemfile базового приложения дописать

```ruby
gem "core"
```

В консоли, в корне базового приложения

```bash
bundle install
```

Там же

```bash
bundle exec rails g core:install
```

установщик спросит какая модель используется для работы с пользователями (по умолчанию `User`).

Дописать в app/assets/javascripts/application.js строчку `//= require core/application` перед `require_tree .`
Аналогично в app/assets/stylesheets/application.css строчку `*= require core/application` перед `require_self`

В базовом приложении организовать путь к плагину, используя хелпер `core.root_path`.
Пример можно увидеть в octoshell-basic `app/decorators/controllers/application_controller_decorator.rb` метод `projects_item`, а также `admin_projects_item`

Подразумевается, что в системе существует механизм авторизации доступа с двумя ролями: администратор и обычный пользователь.
Пример настроек также в octoshell-basic `app/decorators/controllers/application_controller_decorator.rb` метод `ability`.

This project uses MIT-LICENSE.
