Русская версия ниже.
For russian version see below.

# README
Octoshell - access management system for HPC centers. This project is based on Ruby on Rails framework(4.2)
https://users.parallel.ru/


## Installation and starting

We assume, that all below is doing as user `octo` (or root, if it is said 'as root'). You can use another user. Please, note, that linux account `octo` and database role `octo` are not connected, but we prefer to use the same name for both cases. You can create user by command like `adduser octo`

1. install packages as root (under debian/ubuntu: `sudo apt-get install -y git curl wget build-essential libssl-dev libreadline-dev zlib1g-dev sudo yarn`)
1. install as root redis (under debian/ubuntu: `sudo apt-get install -y redis-server redis-tools`)
1. install postgresql (under debian/ubuntu: `sudo apt-get install -y postgresql postgresql-server-dev-all`)
1. as root add database user octo: `sudo -u postgres bash -c "psql -c \"CREATE USER octo WITH PASSWORD 'HERE_COMES_YOUR_DESIRED_PASSWORD';\""`
1. as root set database password: `sudo -u postgres psql` then enter `\password octo` and enter password. Exit with `\q`.
1. enable and start redis and postgresql (e.g. `systemctl enable redis; systemctl enable postgresql; systemctl start redis; systemctl start postgresql`)
1. check if your postgresql is listening 127.0.0.1 port 5432 (e.g. `ss -lpn |grep 5432`). If it is not, check postgresql config files (in debian/ubuntu - /etc/postgresql/VERSION/main/postgresql.conf, 'port' parameter)
1. create databases: `for database in new_octoshell new_octoshell_test new_octoshell_development; do sudo -u postgres createdb -O octo $database; done`
1. as user install rbenv (e.g. `curl https://raw.githubusercontent.com/rbenv/rbenv-installer/master/bin/rbenv-installer | bash`)
1. make sure rbenv is loaded automatically, by adding to ~/.bashrc these lines:
```
  export PATH=~/.rbenv/bin:$PATH
  eval "$(rbenv init -)"
```
1. reopen your terminal session or execute lines from point above in console
1. install ruby:
```
  rbenv install 2.5.1
  rbenv global 2.5.1
```
1. execute `gem install bundler --version '< 2.0'`
1. execute `git clone https://github.com/octoshell/octoshell-v2.git`
1. go into cloned directory `cd octoshell-v2`
1. execute `bundle install`
1. copy `config/database.yml.example` into `config/database.yml`
1. fill database parameters and password in `config/database.yml`
1. execute `bundle exec rake db:setup`
1. execute `bundle exec rake assets:precompile` (Downloading pages without precompilation  and   config.assets.debug = true can take significant amount of time)

Now you can test all in **development** mode, just execute `./dev` and wait for 'Use Ctrl-C to stop'. Open 'http://localhost:5000/' to access application.
To test delayed actions, such as email send, cluster sync, start sidekiq in development mode: `dev-sidekiq`.

Enter as admin with login `admin@octoshell.ru` and password `123456`

To run in **production** mode:

1. as root install nginx (`sudo apt-get install nginx`)
1. as root copy nginx config file (`cp nginx-octo.conf /etc/nginx/sites-enabled/`), restart nginx (`systemctl restart nginx`)
1. as root move your app into /var/www: `mkdir /var/www/octoshell2; mv ~octo/octoshell-v2 /var/www/octoshell2/current`)
1. Start production sidekiq: `./run-sidekiq`
1. Start production server: `./run`
1. To add cluster sync you should login to your cluster as root, create new user 'octo'. Login as `admin@octoshell.ru` in web-application. Go to "Admin/Cluster control" and edit "Test cluster". Copy `octo` public key from web to /home/octo/.ssh/authorized_keys.

Best way is to test in development mode and then do deploy on production (or stage) server. See **Deploy** section for more details.

## Notes

### Wikiplus module

For correct work of images and video uploading you'll need to install imagemagick and ffmpegthumbnailer packages.

## Hacks

### Localization

Currently  Octoshell supports 2 locales: ru (Russian) and en (English). Other locales can be added, but your code should support  at least these 2 locales. "Static" content must be used with `I18n.t` method. Database data is translated using [Traco gem](https://github.com/barsoom/traco). Validation is designed with  `validates_translated` method (`lib/model_translation/active_record_validation.rb`), perfoming validation of data stored in current locale columns.


Users table has the  'language' column. User's working language is stored here. `lib/localized_emails` contains code for emails localization. Email locale depends on user language. If you want to send an email to unregistered user, 'en' locale will be chosen. You can preview your emails with [Rails Email Preview gem](https://github.com/glebm/rails_email_preview).

[I18n-tasks gem](https://github.com/glebm/i18n-tasks) is used to manage locales in the project. But native gem is not designed to work with Rails engines. [See this fork](https://github.com/apaokin/i18n-tasks).
### Front-end

javascript libraries: jquery, handlebars, select2 and alpaca.js(for building forms).


We use [bootstrap-forms gem](https://github.com/bootstrap-ruby/bootstrap_form)  to create static forms. Select2 can build lists using remote data. You can use `autocomplete_field` method  (`engines/face/lib/face/custom_autocomplete_field.rb`) to prepopulate select2 field(if you use remote data).
Example:

		= bootstrap_form_for @search, method: :get, url: admin_users_path, layout: :horizontal do |f|
		  = f.autocomplete_field :id_in,{ label: User.model_name.human, source: main_app.users_path, include_blank: true} do |val|
		    -User.find(val).full_name_with_email ## if id_in is not blank, Selected value will contain all users' full names.

### Notificators

You may need to notify administrators using support tickets (requests). Special class was designed to do it. Its functionality is very similar to ActionMailer::Base class (`engines/support/lib/support/notificator.rb`). Example: `engines/core/app/notificators/core/notificator.rb  engines/core/lib/core/checkable.rb`. Be careful with the `topic_name` method. It must be used only inside "action" method like `Notificator.check`. Pay special attention that the `new` method is not used here explicitly and method_missing is used to set correct options.    

### Key-value storage for ApplicationRecord

Use "options" to extend desription  of any model.
##### Usage
1. In model (see app/models/application_record.rb for details):
        class YourModel < ApplicationRecord
          extend_with_options
        end
1. In your form use #form_for_options  and    bootstrap_nested_form_for (nested_form_for) methods:
        = bootstrap_nested_form_for :@instance do |f|
         # your  fields
        = form_for_options(f)
1. show_options helper:
        = show_options(@instance) do
         - can? :manage, :packages #user will see only options
         with admin boolean attribute set to false if he can't manage packages
         = show_options(@instance) # user will see all options for this instance
1. in your controller params:
            def your_model_params
              params.require(:your_model)
                    .permit(:your_attrs, options_attributes: options_attributes)
            end

##### Possibilities
  You can autocomplete name and value fields. Edit all name and values available for autocomplete here: /admin/options_categories




## Deploy

1. Prepare deploy server (1-10 from above)
1. Make sure you can ssh to deploy server without password
1. `git clone`
1. Rename `deploy_env.sample` to `deploy_env` and fill right environment
1. `./do_deploy_setup`
1. `./do_deploy`
1. `./deploy_copy_files`
1. `./do_after_1_deploy`
1. ssh to deploy server and start all by `systemctl start octoshell`

All deploys after this can be done by `git fetch; ./do_deploy`, and then on deploy server `systemctl restart octoshell`.

# Fork and improve!

You can help us and other users of Octoshell by writting usefull cool features etc.
Please, note, that from 2019 we are using Conventional Commits standart for commits: each commit comment should have this form:

    <type>(scope): description

    Full description. If it has two or more points, each point should start with '* '.

Types:

|Type|Description|
|---|---|
|docs 	|Documantation update|
|uix    |User interface changes|
|feat 	|New functions and features|
|fix 	|Bug fixes|
|perf 	|Performance improvement|
|refactor |Just refactoring|
|revert |Back to old code!|
|style 	|Code style fixes|
|test 	|Adding and improving tests|

Scope: one of engines or 'base' for main app or other files (README, deployment, etc).

# README

Базовое приложение для модульной версии octoshell.

## Установка и запуск

Далее считаем, что установка производится под пользователем `octo` (или `root`, если сказано `под рутом`). Можно использовать другое имя пользователя. Отметим, что имя пользователя и имя роли базы данных не обязаны совпадать, но мы используем одинаковые. Пользователя можно создать, например, командой `adduser octo`

1. под рутом ставим пакеты (debian/ubuntu: `sudo apt-get install -y git curl wget build-essential libssl-dev libreadline-dev zlib1g-dev sudo yarn`)
1. под рутом ставим redis (debian/ubuntu: `sudo apt-get install -y redis-server redis-tools`)
1. под рутом ставим postgresql (debian/ubuntu: `sudo apt-get install -y postgresql postgresql-server-dev-all`)
1. под рутом добавим роль для БД octo: `sudo -u postgres bash -c "psql -c \"CREATE USER octo WITH PASSWORD 'ТУТ_ПАРОЛЬ_ПОЛЬЗОВАТЕЛЯ_БД';\""`
1. под рутом включаем и запускаем redis и postgresql (например `systemctl enable redis; systemctl enable postgresql; systemctl start redis; systemctl start postgresql`)
1. проверяем, что postgresql слушает на 127.0.0.1 порт 5432 (например `ss -lpn |grep 5432`). Если нет, проверяем настройки postgresql (в debian/ubuntu - /etc/postgresql/VERSION/main/postgresql.conf, строчка 'port')
1. под пользователем ставим rbenv (проще всего так: `curl https://raw.githubusercontent.com/rbenv/rbenv-installer/master/bin/rbenv-installer | bash`)
1. в ~/.bashrc пользователя должны быть добавлены эти строки, чтобы работал rbenv:
```
  export PATH=~/.rbenv/bin:$PATH
  eval "$(rbenv init -)"
```
1. запускаем новое окно терминала или терминальную сессию или просто выполняем в консоли строки из предыдущего пункта.
1. ставим ruby:

```
  rbenv install 2.5.1
  rbenv global 2.5.1
```

1. выполняем `gem install bundler --version '< 2.0'`
1. выполняем `git clone https://github.com/octoshell/octoshell-v2.git`
1. переходим в созданный каталог `cd octoshell-v2`
1. выполняем `bundle install`
1. копируем `config/database.yml.example` в `config/database.yml`
1. вписываем параметры БД и пароль в `config/database.yml`
1. выполняем `bundle exec rake db:setup`
1. выполняем `bundle exec rake assets:precompile`

Теперь можно запустить всё в **development** режиме, просто выполнив `./dev` и подождав строчки 'Use Ctrl-C to stop'. В браузере открываем 'http://localhost:5000/'.
Чтобы протестировать отложенные операции, такие как рассылка email, синхронизация с кластером и т.п., запускаем sidekiq в development режиме: `dev-sidekiq`.

В браузере вводим логин `admin@octoshell.ru` и пароль `123456`

Для запуска в **production** режиме:

1. под рутом ставим nginx (`sudo apt-get install nginx`)
1. под рутом копируем конфиг nginx-а (`cp nginx-octo.conf /etc/nginx/sites-enabled/`), перезапускаем nginx (`systemctl restart nginx`)
1. под рутом перемещаем каталог приложения в /var/www: `mkdir /var/www/octoshell2; mv ~octo/octoshell-v2 /var/www/octoshell2/current`)
1. запускаем production sidekiq: `./run-sidekiq`
1. запускаем production server: `./run`
1. для синхронизации с кластером, заходим как root на кластер, создаём пользователя 'octo'. Входим как `admin@octoshell.ru` в приложение. Идём в "Admin/Cluster control" редактируем "Test cluster" (или новый). Копируем открытый ключ `octo` из web-странички в /home/octo/.ssh/authorized_keys.

Лучше всего потестировать приложение в development режиме, а потом выполнить деплой на рабочий (или тестовый) сервер, см. раздел **Деплой**.


## Деплой

1. Подготовьте сервер деплоя (пп. 1-10 из раздела "Установка...")
1. Убедитесь, что вы можете входить на сервер деплоя по ssh без пароля
1. `git clone`
1. Переименовать `deploy_env.sample` в `deploy_env` и внесите нужные правки
1. `./do_deploy_setup`
1. `./do_deploy`
1. `./deploy_copy_files`
1. `./do_after_1_deploy`
1. Войдите на сервер деплоя и запустите сервисы `systemctl start octoshell`

Последующие деплои можно выполнять командой `git fetch; ./do_deploy` и последующим перезапуском сервиса на сервере `systemctl restart octoshell`.

## Замечания

### Wikiplus

Для корректной работы с картинками и видео необходимо установить пакеты  imagemagick и ffmpegthumbnailer.

# Форкни и улучши!

Вы можете помочь нам и другим пользователям улучшить Октошелл, создав новые крутые фишки и прочее, мы всегда рады новой функциональности.
Пожалуйста, помните, что с 2019 года мы используем стандарт Conventional Commits: каждый комментарий к коммиту должен иметь вид:

    <тип>(область): описание

    Полное описание. Если в описании более одного пункта, каждый долен начинаться с '* '.

Типы:

|Type|Description|
|---|---|
|docs 	|Обновление документации|
|uix    |Исправления в интерфейсе пользователя|
|feat 	|Добавление нового функционала|
|fix 	  |Исправление ошибок|
|perf 	|Изменения направленные на улучшение производительности|
|refactor |	Правки кода без исправления ошибок или добавления новых функций|
|revert |	Откат на предыдущие коммиты|
|style 	|Правки по кодстайлу (табы, отступы, точки, запятые и т.д.)|
|test 	|Добавление тестов|

Область - один из engines или 'base' для основного приложения или других файлов (типа README, деплоя, и т.п.)
