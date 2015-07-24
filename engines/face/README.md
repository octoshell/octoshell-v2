# Octoshell Face

Модуль отвечает за разметку и отображение приложения вцелом.
Определяет основной шаблон приложения (layout), механизм показа меню и flash-сообщений.
Стили css и базовые скрипты JavaScript также расположены в модуле см. каталоги `app/assets` и `vendor`.

## Иструкция по установке и настройке:

В Gemfile базового приложения дописать

```ruby
gem "face"
```

В консоли, в корне базового приложения

```bash
bundle install
```

Там же

```bash
bundle exec rails g face:install
```

Дописать в app/assets/javascripts/application.js строчку `//= require face/application` перед `require_tree .`
Аналогично в app/assets/stylesheets/application.css строчку `*= require face/application` перед `require_self`

This project uses MIT-LICENSE.
