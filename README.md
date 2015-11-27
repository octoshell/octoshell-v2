# README
Base application for modular version of Octoshell.

## Installation and starting

1. `git clone`
2. install rbenv, install jruby-1.7.18
3. `bundle install`.
4. `bin/rake db:setup`
5. optional run tests: `bin/rspec .`
6. Start delayed_job (used for email sending).
7. After "seeds" example cluster will be created. You should login to your cluster as root, create new user 'octo'. Login as `admin@octoshell.ru` in web-application. Go to "Admin/Cluster control" and edit "Test cluster". Copy `octo` public key from web to /home/octo/.ssh/authorized_keys.
8. `bundle exec sidekiq`

# README
Базовое приложение для модульной версии octoshell.

## Установка и запуск

1. `git clone`
2. Поставить rbenv, установить jruby-1.7.18
3. `bundle install`.
4. `bin/rake db:setup`
5. Для запуска спеков: `bin/rspec .`
6. Для рассылки почты используется delayed_job: запустить обработчик очереди.
7. После прогона сидов создастся тестовый «кластер». Для синхронизации с ним необходимо доступ на него под пользователем root. Затем залогиниться в приложение как администратор `admin@octoshell.ru`. В «Админке проектов» зайти в раздел «Управление кластерами» и открыть Тестовый кластер. Скопировать публичный ключ админа кластера (по умолчанию `octo`) в /home/octo/.ssh/authorized_keys.
8. `bundle exec sidekiq`
9. Синхронизация доступна для проектов с Доступами из-под учётки администратора. Логи синхронизации доступны на странице кластера из-под учётки администратора.
10. Процедура деплоя сделана через mina: `bundle exec mina deploy`.
