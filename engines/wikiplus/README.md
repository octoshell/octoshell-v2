# Octoshell Wiki

Модуль предоставляет возможность создавать страницы справки в формате Markdown.

## Инструкция по установке и настройке:

Установить пакет ffmpegthumbnailer. Для debuan/ubuntu выполнить команду:

    sudo apt install ffmpegthumbnailer

В Gemfile базового приложения дописать

```ruby
gem "wikiplus"
```

В консоли, в корне базового приложения, а затем в engines/wikiplus

```bash
bundle install
```

Затем

```bash
bundle exec rake wikiplus:create_abilities
```

В базовом приложении организовать путь к плагину, используя хелпер `wikiplus.root_path`.
Пример можно увидеть в octoshell-basic `app/decorators/controllers/application_controller_decorator.rb` метод `wiki_item`.

Подразумевается, что в системе существует механизм авторизации доступа с двумя ролями: администратор и обычный пользователь. Администратор создаёт/редактирует страницы справки, пользователи могут смотреть.
Пример настроек также в octoshell-basic `app/decorators/controllers/application_controller_decorator.rb` метод `ability`.

This project uses MIT-LICENSE.
