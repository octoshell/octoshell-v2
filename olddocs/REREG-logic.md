Соображения по логике блокировки по результатам перерегистрации
-------------------

1. Завершение перерегистрации

Статус отчёта
  accepted                ОК
  submitted               ОК
  assessing               ОК
  assessed                Проверить оценки

  can_not_be_submitted    Нужно отдельно провести ревизию (администратор?)

  pending                 Блок
  rejected                Блок
  exceeded                Ошибка!

2. Закрытие перерегистрации (оценка отчётов завершена)
  accepted                ОК

  submitted               Уведомление админу
  assessing               Уведомление админу
  assessed                Проверить оценки

  can_not_be_submitted    Нужно отдельно провести ревизию (администратор?)

  pending                 Блок
  rejected                Блок
  exceeded                Блок

3. Проверка оценок

Если оценок нет - ошибка
Если хотя бы одна (illustration_points, statement_points, summary_points) меньше 3 - блок (если статус active или suspended)

Мысли по блокировкам и т.п.
---------------------------

Статус blocked для пользователя и проекта не должен быть выделенным,
надо сделать сущность "блокировка" с причиной, датой, автором.
Если у проекта (пользователя) есть активная блокировка, он автоматически в статусе 'blocked'. Точнее, надо определять статус проекта методом is_active? (не 'active?'), все смены статуса могут быть выполнены несмотря на статус блокировки.


open file
