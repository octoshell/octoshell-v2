# Установка Octoshell

Базовое приложение для модульной версии octoshell.

## Быстрая установка демонстрационной версии в Docker (не для producation)

Важно: после удаление контейнера все данные пропадут.
Требования: Docker и Docker Composer

1. выполните `git clone https://github.com/octoshell/octoshell-v2.git`
1. выполните `cd octoshell-v2/docker`
1. выполните `docker-compose up -d --build`
1. откройте в браузере `127.0.0.1:35000` (логин: `admin@octoshell.ru`, пароль: `123456`)


## Установка и запуск

Далее считаем, что установка производится под пользователем `octo` (или `root`, если сказано `под рутом`). Можно использовать другое имя пользователя. Отметим, что имя пользователя и имя роли базы данных не обязаны совпадать, но мы используем одинаковые. Пользователя можно создать, например, командой `adduser octo`

1. под рутом ставим пакеты (debian/ubuntu: `sudo apt-get install -y git curl wget build-essential libssl-dev libreadline-dev zlib1g-dev sudo yarn`)
1. под рутом ставим redis (debian/ubuntu: `sudo apt-get install -y redis-server redis-tools`)
1. под рутом ставим postgresql (debian/ubuntu: `sudo apt-get install -y postgresql postgresql-server-dev-all`)
1. под рутом добавим роль для БД octo: `sudo -u postgres bash -c "psql -c \"CREATE USER octo WITH PASSWORD 'ТУТ_ПАРОЛЬ_ПОЛЬЗОВАТЕЛЯ_БД';\""`
1. под рутом добавим права octo: `sudo -u postgres bash -c "psql -c \"ALTER USER octo CREATEDB;\""`
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
|:---|:---|
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
