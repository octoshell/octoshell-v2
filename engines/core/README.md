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

В production.rb обязательно должны быть следующие строки:

``` ruby
  config.assets.js_compressor = Uglifier.new(harmony: true) # Поддержка ES6
```

Прекомпиляция командой rake assets:precompile javascript-файлов может занимать довольно много времени, а иногда и занимать слишком много памяти для вашей машины. При установленном NodeJS можно ускорить этот процесс следующей командой:
``` bash
  RAILS_ENV=production bundle exec rake assets:precompile EXECJS_RUNTIME='Node' JRUBY_OPTS="-J-d32 -X-C"
 ```

## Обновленный core
Были добавлены новые валидации. Проверить, что старые объекты валидны, можно с помощью raketasks этого модуля. Они снабжены небольшим комментарием, зачем они нужны.
Все скрипты необходимо запускать с source!!!!
Запустить все проверки:
``` bash
	source engines/core/scripts/bash/merge/check.sh
 ```
 После редактирования организаций в веб-интерфейсе их нужно проверить, поэтому это выделено еще и в отдельный скрипт:
 ``` bash
 	source engines/core/scripts/bash/merge/check_organizations.sh
  ```


## Инструкция по слиянию организации и подразделений:
Положить в корень octoshell таблицу, будем считать её имя таковым: joining-orgs_2017_11-2.ods
Для слияния:
```bash
rake RAILS_ENV=production core:merge[joining-orgs_2017_11-2.ods]
```
Или скриптом(его можно вызвать откуда угодно)
``` bash
 source engines/core/scripts/bash/merge/merge.sh  joining-orgs_2017_11-2.ods
 ```


This project uses MIT-LICENSE.
