function markdown_ru_locale(exports){
  return {
    name : "en",
    description : "Open source online Markdown editor.",
    tocTitle    : "Table of Contents",
    toolbar : {
        undo             : "Отменить(Ctrl+Z)",
        redo             : "Повторить(Ctrl+Y)",
        bold             : "Полужирный",
        del              : "Зачеркнутый",
        italic           : "Курсив",
        quote            : "Цитата",
        ucwords          : "Первые буквы слов перевести в верхний регистр",
        uppercase        : "Выделенный текст перевести в верхний регистр",
        lowercase        : "Выделенный текст перевести в нижний регистр",
        h1               : "Заголовок 1",
        h2               : "Заголовок 2",
        h3               : "Заголовок 3",
        h4               : "Заголовок 4",
        h5               : "Заголовок 5",
        h6               : "Заголовок 6",
        "list-ul"        : "Неупорядоченный лист",
        "list-ol"        : "Упорядоченный лист",
        hr               : "Горизонтальная линия",
        link             : "Ссылка",
        "reference-link" : "Ссылка",
        image            : "Изображение",
        code             : "Код",
        "preformatted-text" : "Форматированный текст / блоки кода (отступ с Tab)",
        "code-block"     : "Блок кода (мультиязычный)",
        table            : "Таблица",
        datetime         : "Datetime",
        emoji            : "Emoji",
        "html-entities"  : "HTML-объекты",
        pagebreak        : "Разрыв страницы",
        watch            : "Unwatch",
        unwatch          : "Watch",
        preview          : "HTML Превью (Нажмите Shift + ESC для выхода)",
        fullscreen       : "Полноэкранный режим (Нажмите ESC для выхода)",
        clear            : "Очистить",
        search           : "Найти",
        help             : "Помощь",
        info             : "О " + exports.title
    },
    buttons : {
        enter  : "Ввести",
        cancel : "Отменить",
        close  : "Закрыть"
    },
    dialog : {
        link : {
            title    : "Ссылка",
            url      : "Адрес",
            urlTitle : "Заголовок",
            urlEmpty : "Ошибка: Пожалуйста заполните адрес ссылки."
        },
        referenceLink : {
            title    : "Ссылка",
            name     : "Название",
            url      : "Адрес",
            urlId    : "ID",
            urlTitle : "Заголовок",
            nameEmpty: "Ошибка: Название ссылки не может быть пустым.",
            idEmpty  : "Ошибка: Пожалуйста введите id ссылки.",
            urlEmpty : "Ошибка: Пожалуйста введите адрес ссылки."
        },
        image : {
            title    : "Изображение",
            url      : "Адрес",
            link     : "Ссылка",
            alt      : "Заголовок",
            uploadButton     : "Загрузить",
            imageURLEmpty    : "Ошибка: адрес картинки не может быть пустым.",
            uploadFileEmpty  : "Ошибка: изображение не может быть пустым!",
            formatNotAllowed : "Ошибка: можно загружать только изображения, загрузите изображение с разрешенным форматом:"
        },
        preformattedText : {
            title             : "Отформатированный текст / Коды",
            emptyAlert        : "Ошибка: Пожалуйста заполните отформатированный текст или код."
        },
        codeBlock : {
            title             : "Блок кода",
            selectLabel       : "Языки: ",
            selectDefaultText : "Выберите код языка...",
            otherLanguage     : "Другие коды",
            unselectedLanguageAlert : "Ошибка: Пожалуйста введите код языка.",
            codeEmptyAlert    : "Ошибка: Пожалуйста введите код."
        },
        htmlEntities : {
            title : "HTML-объекты"
        },
        help : {
            title : "Помощь"
        }
    }
  }
};
