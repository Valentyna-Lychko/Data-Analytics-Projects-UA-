# SQL та Looker Studio

## Опис проєкту
Цей проєкт демонструє практичне застосування SQL у PostgreSQL та BigQuery для роботи з даними, а також створення інтерактивних дашбордів у Looker Studio. Як приклад використано дані рекламних кампаній на платформах Facebook і Google Ads, а також взаємодії користувачів eCommerce-платформи. Дашборди ілюструють можливості Looker Studio для інтеграції з базами даних, забезпечуючи зручний доступ до інформації та її обробку.

При написанні SQL-запитів були використані загальні табличні вирази (CTE), віконні функції (window functions), операції об'єднання даних (JOIN, UNION), функції агрегації, функції для роботи з датами та текстом, а також умовно-логічні функції (Conditional Functions).

---

## SQL у PostgreSQL: маркетингові метрики
Робота з даними рекламних платформ Facebook і Google Ads включала два підходи:

### 1. SQL-запит для Looker Studio
- Об’єднання та агрегування даних рекламних кампаній.
- Завантаження до Looker Studio для розрахунку метрик: CTR, CPC, CPM і ROMI.  
[SQL для Looker Studio](https://github.com/Valentyna-Lychko/Data-Analytics-Projects-UA-/blob/main/SQL_Files/prepare_looker_UA.sql)

### 2. Розширений SQL-аналіз
- Розрахунок метрик та їх динаміки безпосередньо у SQL.
- Аналіз відсоткових змін між місяцями.
  
[Розширений SQL-аналіз](https://github.com/Valentyna-Lychko/Data-Analytics-Projects-UA-/blob/main/SQL_Files/metrics_trends_UA.sql)

### Метрики
У проєкті продемонстровано два методи обчислення метрик: у SQL-запитах та за допомогою обчислюваних полів (calculated fields) у Looker Studio. Зокрема:
- **CPC (Cost per Click)** = Ad Spend / Clicks
- **CPM (Cost per Mille)** = (Ad Spend * 1000) / Impressions
- **CTR (Click-Through Rate)** = (Clicks / Impressions) * 100
- **ROMI (Return on Marketing Investment)** = (Value - Ad Spend) / Ad Spend * 100

---

## SQL у BigQuery: аналіз eCommerce
Дані, отримані з Google Analytics 4 (GA4), використовувалися для:
- Формування таблиць із подіями, сесіями та покупками користувачів.
- Розрахунку коефіцієнтів конверсій між етапами воронки.
- Аналізу джерел трафіку та активності користувачів.
- Вивчення взаємозв’язку між активністю користувачів і їх покупками.
- Підготовки даних для візуалізації у Looker Studio.  
[SQL у BigQuery для eCommerce](https://github.com/Valentyna-Lychko/Data-Analytics-Projects-UA-/blob/main/SQL_Files/BigQuery_Project.sql)

---

## Візуалізація у Looker Studio
Looker Studio забезпечила інтерактивний аналіз даних:

### 1. Маркетингові метрики з PostgreSQL
- Динаміка витрат і рентабельності.
- Зміна кількості кампаній у часі.
- Порівняння ключових метрик у розрізі кампаній.
   
![](https://github.com/Valentyna-Lychko/Data-Analytics-Projects-UA-/blob/main/Dashboards_PNG/Marketing_metrics_with_looker.png)


### 2. eCommerce-дані з BigQuery
- Воронки конверсій для аналізу етапів відвідувачів від перегляду товару до покупки.
- Активність користувачів за джерелами трафіку, частотою сесій і конверсіями.
  
![](https://github.com/Valentyna-Lychko/Data-Analytics-Projects-UA-/blob/main/Dashboards_PNG/eCommerce_BigQuery.png)


---

## Результати
- У PostgreSQL виконано об'єднання даних з Facebook і Google Ads, які завантажено до Looker Studio для аналізу.
- Реалізовано два сценарії розрахунку метрик: у SQL-запитах PostgreSQL та через обчислювані поля Looker Studio.
- У BigQuery оброблено дані eCommerce, підключено їх до Looker Studio для інтерактивного аналізу.
- Створено дашборди для візуалізації рекламних кампаній та поведінки користувачів eCommerce-платформи.

---

## Посилання на ресурси
- [SQL для Looker Studio](https://github.com/Valentyna-Lychko/Data-Analytics-Projects-UA-/blob/main/SQL_Files/prepare_looker_UA.sql)
- [Розширений SQL-аналіз](https://github.com/Valentyna-Lychko/Data-Analytics-Projects-UA-/blob/main/SQL_Files/metrics_trends_UA.sql)
- [SQL для eCommerce](https://github.com/Valentyna-Lychko/Data-Analytics-Projects-UA-/blob/main/SQL_Files/BigQuery_Project.sql)
- [Дашборд маркетингові метрики в Looker Studio](https://github.com/Valentyna-Lychko/Data-Analytics-Projects-UA-/blob/main/Dashboards_PNG/Marketing_metrics_with_looker.png)
- [Дашборд eCommerce-дані в Looker Studio](https://github.com/Valentyna-Lychko/Data-Analytics-Projects-UA-/blob/main/Dashboards_PNG/eCommerce_BigQuery.png)

---

## Висновок

1. **SQL: Потужний інструмент**  
   PostgreSQL та BigQuery забезпечують ефективне агрегування, обробку даних і розрахунок складних метрик. У цьому проєкті були опрацьовані дані рекламних кампаній на платформах Facebook і Google Ads, а також взаємодії користувачів eCommerce-платформи.  

2. **Looker Studio: Інтеграція та візуалізація**  
   Looker Studio демонструє можливості інтеграції з різними базами даних, такими як PostgreSQL та BigQuery, забезпечуючи доступність даних для подальшого аналізу. Інструмент дозволяє створювати інтерактивні дашборди для глибшого розуміння аналітики.  

3. **Гнучкий підхід до обчислення метрик**  
   Метрики були розраховані як у SQL (PostgreSQL та BigQuery), так і за допомогою обчислюваних полів у Looker Studio, що дає змогу вибирати найбільш зручний інструмент залежно від завдань.
   

```
