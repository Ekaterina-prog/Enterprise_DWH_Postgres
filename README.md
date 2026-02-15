Архитектура

1. Source Layer
   PostgreSQL база dvdrental
   Подключение через postgres_fdw
   Данные импортированы в схему film_src

2. Staging Layer
   Схема: staging
   Назначение:
   промежуточное хранение данных
   минимальная обработка
   подготовка к загрузке в core слой

Особенности:
Полная загрузка для большинства таблиц
Инкрементальная загрузка для inventory
Поддержка soft delete (поле deleted)
Контроль загрузки через таблицу staging.last_update

Реализованные таблицы:
film
inventory
rental
payment
staff
address
city
store

Staging слой не содержит бизнес-логики и surrogate keys.

3. Core Layer (Star Schema)
   Реализована звездная схема по методологии Kimball.

Схема: core

Измерения (Dimensions)
dim_date
Календарное измерение, генерируется процедурой core.load_date.
Содержит:
день, месяц, квартал, год
week_of_year, ISO week
first/last day of period
признак выходного дня
dim_inventory

Измерение с реализацией Slowly Changing Dimension Type 2.

Поддерживает историзацию через:
effective_date_from
effective_date_to
is_active

При изменении записи создаётся новая версия строки с сохранением истории.
dim_staff

Измерение сотрудников.
Реализована стратегия полной перезагрузки.

Факты (Facts)
fact_payment
Факт платежей:
сумма оплаты
связь с датой оплаты
связь с сотрудником
связь с инвентарём

fact_rental
Факт аренды:
количество операций
сумма
дата аренды
дата возврата
Фактовые таблицы используют surrogate keys измерений.

4. Data Mart Layer

Схема: report

Реализованы агрегированные витрины:
report.sales_date — продажи по датам
report.sales_film — продажи по фильмам

Процедуры:
report.sales_date_calc()
report.sales_film_calc()

Стратегия загрузки

Используется гибридная стратегия:
Инкрементальная загрузка для staging.inventory
SCD Type 2 для core.dim_inventory
Полная перезагрузка для фактов
Генерация календаря через отдельную процедуру
