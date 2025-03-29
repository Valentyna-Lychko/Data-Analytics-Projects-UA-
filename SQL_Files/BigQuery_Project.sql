--Аналіз eCommerce у BigQuery
--Дані, отримані з Google Analytics 4 (GA4), аналізувалися для:

-- 1. Формування таблиць із подіями, сесіями та покупками користувачів

SELECT 
    timestamp_micros(event_timestamp) AS event_timestamp, -- Перетворення часу події з мікросекунд у формат дати та часу
    user_pseudo_id, -- Унікальний псевдоідентифікатор користувача
    (
        SELECT value.int_value 
        FROM a.event_params 
        WHERE key = 'ga_session_id'
    ) AS session_id, -- Ідентифікатор сесії користувача, взятий із параметрів події
    event_name, -- Назва події (наприклад, перегляд товару, додавання в кошик, покупка)
    geo.country AS country, -- Країна, де була здійснена подія, згідно геолокації
    device.category AS device_category, -- Категорія пристрою (desktop,mobile,  tablet)
    traffic_source.source AS source, -- Джерело трафіку (напр., google, shop.googlemerchandisestore.com, <Other>)
    traffic_source.medium AS medium, -- Тип трафіку (напр., organic, cpc, referral, <Other>)
    traffic_source.name AS campaign -- Назва рекламної кампанії (напр., direct, organic, <Other>)
FROM 
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_2021*` a -- Вибір даних з набору таблиць за 2021 рік
WHERE 
    event_name IN ('session_start', 'view_item', 'add_to_cart', 'begin_checkout', 'add_shipping_info', 'add_payment_info', 'purchase') 
    -- Фільтр для вибору лише подій, пов'язаних із взаємодією користувачів із платформою
LIMIT 1000; -- Обмеження вибірки до перших 1000 записів


-- 2. Розрахунку коефіцієнтів конверсій між етапами воронки.

-- Формування таблиці із подіями, сесіями та покупками користувачів

WITH bq_events AS (
    SELECT
        timestamp_micros(event_timestamp) AS event_timestamp, -- Перетворення часу події з мікросекунд у стандартний формат дати та часу
        event_name, -- Назва події (наприклад, session_start, add_to_cart, purchase тощо)
        user_pseudo_id || CAST(
            (SELECT value.int_value FROM UNNEST(e.event_params) WHERE key = 'ga_session_id') AS STRING
        ) AS user_session_id, -- Унікальний ідентифікатор сесії користувача
        traffic_source.source AS source, -- Джерело трафіку 
        traffic_source.medium AS medium, -- Тип трафіку 
        traffic_source.name AS campaign -- Назва рекламної кампанії
    FROM 
        `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` e -- Дані з набору таблиць GA4 для eCommerce
    WHERE 
        event_name IN ('session_start', 'add_to_cart', 'begin_checkout', 'purchase') -- Фільтр подій за ключовими етапами
),

-- Агрегація даних для розрахунку метрик між етапами
event_name_count AS (
    SELECT
        DATE(event_timestamp) AS event_date, -- Перетворення часу події у формат дати (без часу)
        source, -- Джерело трафіку
        medium, -- Тип трафіку
        campaign, -- Назва рекламної кампанії
        COUNT(DISTINCT user_session_id) AS user_sessions_count, -- Загальна кількість сесій
        COUNT(DISTINCT CASE WHEN event_name = 'add_to_cart' THEN user_session_id END) AS added_to_cart_count, -- Кількість користувачів, які додали товар у кошик
        COUNT(DISTINCT CASE WHEN event_name = 'begin_checkout' THEN user_session_id END) AS begin_checkout_count, -- Кількість користувачів, які почали оформлення замовлення
        COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN user_session_id END) AS purchase_count -- Кількість покупок
    FROM 
        bq_events -- Дані подій користувачів, зібрані у попередньому кроці
    GROUP BY 
        1, 2, 3, 4 -- Групування за датою, джерелом, типом трафіку та кампанією
)

-- Фінальний розрахунок коефіцієнтів конверсій
SELECT 
    event_date, -- Дата події
    source, -- Джерело трафіку
    medium, -- Тип трафіку
    campaign, -- Назва кампанії
    user_sessions_count, -- Загальна кількість сесій користувачів
    ROUND(added_to_cart_count / user_sessions_count * 100, 2) AS visit_to_cart, -- Відсоток переходів до додавання в кошик
    ROUND(begin_checkout_count / user_sessions_count * 100, 2) AS visit_to_checkout, -- Відсоток переходів до оформлення замовлення
    ROUND(purchase_count / user_sessions_count * 100, 2) AS visit_to_purchase -- Відсоток переходів до покупки
FROM 
    event_name_count -- Агреговані дані із розрахунками кількості подій
ORDER BY 
    1; -- Сортування за датою подій


-- 3. Аналізу джерел трафіку та активності користувачів.

-- Формування таблиці для подій сесій користувачів, включаючи сторінки, URL та джерела трафіку
WITH bq_events AS (
    SELECT
        -- Унікальний ідентифікатор сесії користувача
        user_pseudo_id || 
        CAST(
            (SELECT value.int_value 
             FROM UNNEST(e.event_params) 
             WHERE key = 'ga_session_id') AS STRING
        ) AS user_session_id,
        
        -- Витяг шляху сторінки (page_path) із параметра page_location за допомогою регулярного виразу
        REGEXP_EXTRACT(
            (SELECT value.string_value 
             FROM UNNEST(event_params) 
             WHERE key = 'page_location'),
            r'(?:\w+\:\/\/)?[^\/]+\/([^\?#]*)'
        ) AS page_path,
        
        -- Повний URL сторінки (page_location)
        (SELECT value.string_value 
         FROM UNNEST(event_params) 
         WHERE key = 'page_location') AS page_location
    FROM 
        `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` e -- Дані з таблиць GA4 за весь 2020 рік
    WHERE
        _table_suffix BETWEEN '20200101' AND '20201231' -- Фільтр даних за періодом (весь 2020 рік)
        AND event_name = 'session_start' -- Події початку сесій користувачів
),

-- Формування таблиці для подій, пов'язаних із покупками користувачів
event_purchase AS (
    SELECT 
        -- Унікальний ідентифікатор сесії користувача
        user_pseudo_id || 
        CAST(
            (SELECT value.int_value 
             FROM e.event_params 
             WHERE key = 'ga_session_id') AS STRING
        ) AS user_session_id    
    FROM 
        `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` e -- Дані з таблиць GA4 за весь 2020 рік
    WHERE
        _table_suffix BETWEEN '20200101' AND '20201231' -- Фільтр даних за періодом (весь 2020 рік)
        AND event_name = 'purchase' -- Події здійснення покупок
)

-- Обчислення метрик активності та покупок користувачів
SELECT
    s.page_path, -- Шлях сторінки
    COUNT(DISTINCT s.user_session_id) AS sessions_count, -- Кількість унікальних сесій
    COUNT(DISTINCT p.user_session_id) AS purchases_count, -- Кількість унікальних покупок
    COUNT(DISTINCT p.user_session_id) / COUNT(DISTINCT s.user_session_id) AS cr_to_purchase -- Коефіцієнт конверсії в покупку
FROM 
    bq_events s  
    LEFT JOIN event_purchase p ON s.user_session_id = p.user_session_id -- З'єднання сесій із покупками
GROUP BY 
    1 -- Групування за шляхом сторінки
ORDER BY 
    2 DESC; -- Сортування за кількістю сесій у спадному порядку



-- 4. Вивчення зв’язку між активністю користувачів і їх покупками

-- Формування таблиці із сесіями користувачів та підрахунком кількості подій у кожній сесії
WITH user_sessions AS (
    SELECT
        -- Унікальний ідентифікатор сесії користувача
        user_pseudo_id || CAST(
            (SELECT value.int_value 
             FROM UNNEST(event_params) 
             WHERE key = 'ga_session_id') AS STRING
        ) AS session_id,
        
        -- Кількість подій у сесії
        COUNT(*) AS events_count 
    FROM 
        `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` -- Дані з таблиць GA4
    WHERE 
        _table_suffix BETWEEN '20200101' AND '20201231' -- Фільтр даних за періодом (весь 2020 рік)
    GROUP BY 
        session_id -- Групування за унікальною сесією користувача
),

-- Формування таблиці із сесіями, які завершились покупкою
purchases AS (
    SELECT
        -- Унікальний ідентифікатор сесії користувача
        user_pseudo_id || CAST(
            (SELECT value.int_value 
             FROM UNNEST(event_params) 
             WHERE key = 'ga_session_id') AS STRING
        ) AS session_id,
        
        -- Позначка сесії, яка завершилась покупкою
        1 AS purchase_flag
    FROM 
        `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` -- Дані з таблиць GA4
    WHERE 
        _table_suffix BETWEEN '20200101' AND '20201231' -- Фільтр даних за періодом (весь 2020 рік)
        AND event_name = 'purchase' -- Фільтр подій для вибору тільки покупок
)

-- Зв'язок між активністю користувачів (кількість подій у сесії) і покупками
SELECT
    u.events_count, -- Кількість подій у сесії
    COUNT(p.session_id) AS purchase_count -- Кількість покупок у сесіях із заданою активністю
FROM 
    user_sessions u
LEFT JOIN 
    purchases p ON u.session_id = p.session_id -- З'єднання таблиці сесій із таблицею покупок
GROUP BY 
    u.events_count -- Групування за кількістю подій у сесії
ORDER BY 
    u.events_count; -- Сортування за кількістю подій у сесії


-- 5. Підготовка даних для візуалізації у Looker Studio

-- Етап 1: Формування таблиці з ключовими подіями користувачів та інформацією про джерела трафіку
WITH bq_events AS (
    SELECT
        timestamp_micros(event_timestamp) AS event_timestamp, -- Конвертація часу події з мікросекунд у стандартний формат дати і часу
        event_name, -- Назва події (session_start, add_to_cart, begin_checkout, purchase)
        user_pseudo_id || CAST(
            (SELECT value.int_value 
             FROM UNNEST(e.event_params) 
             WHERE key = 'ga_session_id') AS STRING
        ) AS user_session_id, -- Унікальний ідентифікатор сесії користувача
        traffic_source.source AS source, -- Джерело трафіку (напр., google, shop.googlemerchandisestore.com, <Other>)
        traffic_source.medium AS medium, -- Тип трафіку (напр., organic, cpc, referral, <Other>)
        traffic_source.name AS campaign -- Назва рекламної кампанії (напр., direct, organic, <Other>)
    FROM 
        `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` e -- Дані з таблиць GA4 для eCommerce
    WHERE 
        event_name IN ('session_start', 'add_to_cart', 'begin_checkout', 'purchase') -- Фільтр для вибору подій, що пов'язані з воронкою продажів
),

-- Етап 2: Агрегація даних для обчислення кількості подій на кожному етапі воронки
event_name_count AS (
    SELECT
        DATE(event_timestamp) AS event_date, -- Конвертація часу події у формат дати (без часу)
        source, -- Джерело трафіку
        medium, -- Тип трафіку
        campaign, -- Назва кампанії
        COUNT(DISTINCT user_session_id) AS user_sessions_count, -- Кількість унікальних сесій
        COUNT(DISTINCT CASE WHEN event_name = 'add_to_cart' THEN user_session_id END) AS added_to_cart_count, -- Кількість сесій із додаванням товару до кошика
        COUNT(DISTINCT CASE WHEN event_name = 'begin_checkout' THEN user_session_id END) AS begin_checkout_count, -- Кількість сесій із початком оформлення замовлення
        COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN user_session_id END) AS purchase_count -- Кількість сесій із завершенням покупки
    FROM 
        bq_events -- Дані ключових подій користувачів із першого етапу
    GROUP BY 
        1, 2, 3, 4 -- Групування за датою, джерелом, типом трафіку та назвою кампанії
),

-- Етап 3: Формування таблиці етапів воронки продажів із розрахунками коефіцієнтів конверсії
funnel_stages AS (
    SELECT 
        event_date, -- Дата події
        source, -- Джерело трафіку
        medium, -- Тип трафіку
        campaign, -- Назва кампанії
        'Session Start' AS stage, -- Етап: Початок сесії
        user_sessions_count AS value, -- Кількість сесій на етапі
        100 AS conversion_rate -- Базовий коефіцієнт конверсії для першого етапу (100%)
    FROM 
        event_name_count
    UNION ALL
    SELECT 
        event_date,
        source,
        medium,
        campaign,
        'Add to Cart' AS stage, -- Етап: Додавання до кошика
        added_to_cart_count AS value, -- Кількість сесій із додаванням до кошика
        ROUND(added_to_cart_count * 100.0 / user_sessions_count, 2) AS conversion_rate -- Коефіцієнт конверсії: від сесії до кошика
    FROM 
        event_name_count
    UNION ALL
    SELECT 
        event_date,
        source,
        medium,
        campaign,
        'Begin Checkout' AS stage, -- Етап: Початок оформлення замовлення
        begin_checkout_count AS value, -- Кількість сесій із оформленням замовлення
        ROUND(begin_checkout_count * 100.0 / user_sessions_count, 2) AS conversion_rate -- Коефіцієнт конверсії: від кошика до оформлення
    FROM 
        event_name_count
    UNION ALL
    SELECT 
        event_date,
        source,
        medium,
        campaign,
        'Purchase' AS stage, -- Етап: Завершення покупки
        purchase_count AS value, -- Кількість завершених покупок
        ROUND(purchase_count * 100.0 / user_sessions_count, 2) AS conversion_rate -- Коефіцієнт конверсії: від оформлення до покупки
    FROM 
        event_name_count
)

-- Етап 4: Формування фінальної таблиці для візуалізації у Looker Studio
SELECT 
    event_date, -- Дата події
    source, -- Джерело трафіку
    medium, -- Тип трафіку
    campaign, -- Назва кампанії
    stage, -- Етап воронки продажів
    value, -- Кількість подій на етапі
    conversion_rate -- Коефіцієнт конверсії для етапу
FROM 
    funnel_stages -- Дані всіх етапів воронки продажів
ORDER BY 
    event_date, -- Сортування за датою
    CASE 
        WHEN stage = 'Session Start' THEN 1
        WHEN stage = 'Add to Cart' THEN 2
        WHEN stage = 'Begin Checkout' THEN 3
        WHEN stage = 'Purchase' THEN 4
    END; -- Сортування за етапами воронки продажів






