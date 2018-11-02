# README
Octoshell - access management system for HPC centers. This project is based on Ruby on Rails framework(4.2)
https://users.parallel.ru/


## Installation and starting

We assume, that all below is doing as user `octo` (or root, if it is said 'as root'). You can use another user. Please, note, that linux account `octo` and database role `octo` are not connected, but we prefer to use the same name for both cases.

1. install packages as root (under debian/ubuntu: `sudo apt-get install -y git build-essential libssl-dev libreadline-dev zlib1g-dev`)
1. install as root redis (under debian/ubuntu: `sudo apt-get install redis`)
1. install postgresql (under debian/ubuntu: `sudo apt-get install postgresql postgresql-server-dev-all`)
1. install rbenv (e.g. `curl https://raw.githubusercontent.com/rbenv/rbenv-installer/master/bin/rbenv-installer | bash`)
1. as root add database user octo: `sudo -u postgres createuser -s octo`
1. as root set database password: `sudo -u postgres psql` then enter `\password octo` and enter password. Exit with `\q`.
1. Enable and start redis and postgresql (e.g. `systemctl enable redis; systemctl enable postgresql; systemctl start redis; systemctl start postgresql`)
1. make sure rbenv is loaded automatically, by adding to ~/.bashrc these lines:

```
  export PATH=~/.rbenv/bin:$PATH
  eval "$(rbenv init -)"
```
1. reopen your terminal session or execute lines from point above in console
1. install ruby:

```
  rbenv install 2.5.1
  rbenv local 2.5.1
```

1. execute `gem install bundler`
1. execute `bundle install`
1. execute `git clone https://github.com/octoshell/octoshell-v2.git`
1. go to cloned directory (`cd octoshell-v2`)
1. copy `config/database.yml.example` into `config/database.yml`
1. fill database parameters and password in `config/database.yml`
1. execute `bundle install`
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

## Hacks

### Localization

Currently  Octoshell supports 2 locales: ru (Russian) and en (English). Other locales can be added, but your code should support  at least these 2 locales. "Static" content must be used with `I18n.t` method. Database data is translated using [Traco gem](https://github.com/barsoom/traco). Validation is designed with  `validates_translated` method (`lib/model_translation/active_record_validation.rb`), perfoming validation of data stored in current locale columns.


Users table has the  'language' column. User's working language is stored here. `lib/localized_emails` contains code for emails localization. Email locale depends on user language. If you want to send an email to unregistered user, 'en' locale will be chosen. You can preview your emails with [Rails Email Preview gem](https://github.com/glebm/rails_email_preview).

[I18n-tasks gem](https://github.com/glebm/i18n-tasks) is used to manage locales in the project. But native gem is not designed to work with Rails engines. `lib/relative_keys_extension.rb` extends gem to find missing keys.

### Front-end

javascript libraries: jquery, handlebars, select2 and alpaca.js(for building forms).


We use [bootstrap-forms gem](https://github.com/bootstrap-ruby/bootstrap_form)  to create static forms. Select2 can build lists using remote data. You can use `autocomplete_field` method  (`engines/face/lib/face/custom_autocomplete_field.rb`) to prepopulate select2 field(if you use remote data).
Example:

		= bootstrap_form_for @search, method: :get, url: admin_users_path, layout: :horizontal do |f|
		  = f.autocomplete_field :id_in,{ label: User.model_name.human, source: main_app.users_path, include_blank: true} do |val|
		    -User.find(val).full_name_with_email ## if id_in is not blank, Selected value will contain all users' full names.

### Notificators

You may need to notify administrators using support tickets (requests). Special class was designed to do it. Its functionality is very similar to ActionMailer::Base class (`engines/support/lib/support/notificator.rb`). Example: `engines/core/app/notificators/core/notificator.rb  engines/core/lib/core/checkable.rb`. Be careful with the `topic_name` method. It must be used only inside "action" method like `Notificator.check`. Pay special attention that the `new` method is not used here explicitly and method_missing is used to set correct options.    


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

# README
Базовое приложение для модульной версии octoshell.

## Установка и запуск

1. установить rbenv (например `curl https://raw.githubusercontent.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash`)
1. install ruby:
    rbenv install 2.5.1
    rbenv local 2.5.1
1. `gem install bundler`
1. `bundle install`
1. установить redis
1. установить postgresql
1. `git clone`
1. добавить пользователя БД octo: `sudo -u postgres createuser -s octo`
1. установить пароль для пользоватедя БД: `sudo -u postgres psql` then enter `\password octo` and enter password. Exit with `\q`.
1. прописать пароль в `config/database.yml`
1. `bin/rake db:setup`
1. запустить тесты (по желанию): `bin/rspec .`
1. После прогона сидов создастся тестовый «кластер». Для синхронизации с ним необходимо доступ на него под пользователем root. Затем залогиниться в приложение как администратор `admin@octoshell.ru`. В «Админке проектов» зайти в раздел «Управление кластерами» и открыть Тестовый кластер. Скопировать публичный ключ админа кластера (по умолчанию `octo`) в `/home/octo/.ssh/authorized_keys`.
1. Запустить sidekiq: `./run-sidekiq`
1. Запустить сервер: `./run`
1. Войти по адресу `http://localhost:3000/` с логином `admin@octoshell.ru` и паролем `123456`

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

