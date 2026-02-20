-- создание таблиц report слоя

create table report.calendar (
  date_id INT not null,
  date_actual DATE not null,
  day_of_month INT not null,
  month_name VARCHAR(9) not null,
  year INT not null
);

create table report.sales_by_date (
	sales_date_rn int not null,
	sales_date_title varchar(50) not null,
	amount float not null
);