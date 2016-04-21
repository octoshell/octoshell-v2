# README
Base application for modular version of Octoshell.

## Installation and starting

1. `git clone`
1. install rbenv (e.g. `curl https://raw.githubusercontent.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash`)
1. install jruby-9.0.5.0 (`rbenv install jruby-9.0.5.0`; `rbenv local jruby-9.0.5.0`)
1. `bundle install`.
1. install postgresql
1. add database user octo: `sudo -u postgres createuser -s octo`
1. set database password: `sudo -u postgres psql` then enter `\password octo` and enter password. Exit with `\q`.
1. fill database password in `config/database.yml`
1. `bin/rake db:setup`
1. optional run tests: `bin/rspec .`
1. After "seeds" example cluster will be created. You should login to your cluster as root, create new user 'octo'. Login as `admin@octoshell.ru` in web-application. Go to "Admin/Cluster control" and edit "Test cluster". Copy `octo` public key from web to /home/octo/.ssh/authorized_keys.
1. Start sidekiq: `./run-sidekiq`
1. Start server: `./run`
1. Enter as admin with login `admin@octoshell.ru` and password `12345`

# README
Базовое приложение для модульной версии octoshell.

## Установка и запуск

1. `git clone`
1. установить rbenv (e.g. `curl https://raw.githubusercontent.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash`)
1. установить jruby-9.0.5.0 (`rbenv install jruby-9.0.5.0`; `rbenv local jruby-9.0.5.0`)
1. `bundle install`.
1. установить postgresql
1. добавить пользователя БД octo: `sudo -u postgres createuser -s octo`
1. установить пароль для пользоватедя БД: `sudo -u postgres psql` then enter `\password octo` and enter password. Exit with `\q`.
1. прописать пароль в `config/database.yml`
1. `bin/rake db:setup`
1. запустить тесты (по желанию): `bin/rspec .`
1. После прогона сидов создастся тестовый «кластер». Для синхронизации с ним необходимо доступ на него под пользователем root. Затем залогиниться в приложение как администратор `admin@octoshell.ru`. В «Админке проектов» зайти в раздел «Управление кластерами» и открыть Тестовый кластер. Скопировать публичный ключ админа кластера (по умолчанию `octo`) в /home/octo/.ssh/authorized_keys.
1. Запустить sidekiq: `./run-sidekiq`
1. Запустить сервер: `./run`
1. Войти по адресу `http://localhost:3000/` с логином `admin@octoshell.ru` и паролем `12345`
1. Процедура деплоя сделана через mina: `bundle exec mina deploy`.
