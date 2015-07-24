# Octoshell Wiki

Модуль предоставляет возможность создавать страницы справки в формате Markdown.

## Инструкция по установке и настройке:

В Gemfile базового приложения дописать

```ruby
gem "wiki"
```

В консоли, в корне базового приложения

```bash
bundle install
```

Там же

```bash
bundle exec rails g wiki:install
```

В базовом приложении организовать путь к плагину, используя хелпер `wiki.root_path`.
Пример можно увидеть в octoshell-basic `app/decorators/controllers/application_controller_decorator.rb` метод `wiki_item`.

Подразумевается, что в системе существует механизм авторизации доступа с двумя ролями: администратор и обычный пользователь. Администратор создаёт/редактирует страницы справки, пользователи могут смотреть.
Пример настроек также в octoshell-basic `app/decorators/controllers/application_controller_decorator.rb` метод `ability`.

This project uses MIT-LICENSE.
