# Octoshell Authentication

Модуль аутентификации пользователей в системе.
За работу с пользователями отвечает модель `User`.

## Инструкция по установке и настройке:

В Gemfile базового приложения дописать

```ruby
gem "authentication"
```

В консоли, в корне базового приложения

```bash
bundle install
```

Там же

```bash
bundle exec rails g authentication:install
```

This project uses MIT-LICENSE.
