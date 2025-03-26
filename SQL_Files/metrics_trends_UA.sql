-- Цей код об'єднує та аналізує дані рекламних кампаній із Facebook та Google Ads, розраховуючи ключові метрики (CPC, CTR, CPM, ROMI) і їхню динаміку 

-- CTE: Об'єднання даних із Facebook Campaigns
WITH facebook_home AS (
    SELECT *
    FROM facebook_campaign fc
    LEFT JOIN facebook_ads_basic_daily fabd ON fc.campaign_id = fabd.campaign_id -- З'єднання з таблицею з денними даними
    LEFT JOIN facebook_adset fa ON fa.adset_id = fabd.adset_id -- З'єднання з таблицею наборів оголошень
),

-- CTE: Створення єдиної таблиці для щоденних даних
campaign_name_daily AS (
    SELECT 
        ad_date,
        url_parameters,
        COALESCE(spend, 0) AS spend, -- Заміна NULL значень на 0 для витрат
        COALESCE(impressions, 0) AS impressions, -- Заміна NULL для показів
        COALESCE(clicks, 0) AS clicks, -- Заміна NULL для кліків
        COALESCE(value, 0) AS value -- Заміна NULL для значення конверсій
    FROM facebook_home
    UNION ALL
    SELECT 
        ad_date,
        url_parameters,
        COALESCE(spend, 0) AS spend, -- Дані з Google Ads
        COALESCE(impressions, 0) AS impressions,
        COALESCE(clicks, 0) AS clicks,
        COALESCE(value, 0) AS value
    FROM public.google_ads_basic_daily
),

-- CTE: Групування даних за місяцями та розрахунок метрик
campaign_name_monthly AS (
    SELECT
        DATE_TRUNC('month', ad_date)::date AS ad_month, -- Обрізання дати до початку місяця
        CASE 
            WHEN LOWER(SUBSTRING(url_parameters FROM 'utm_campaign=([^&#$]+)')) != 'nan'
                THEN LOWER(SUBSTRING(url_parameters FROM 'utm_campaign=([^&#$]+)')) -- Витяг utm_campaign
            ELSE NULL
        END AS utm_campaign,
        SUM(spend) AS sum_spend, -- Сума витрат
        SUM(impressions) AS sum_impressions, -- Сума показів
        SUM(clicks) AS sum_clicks, -- Сума кліків
        SUM(value) AS sum_value, -- Сума конверсій
        CASE WHEN SUM(clicks) > 0 THEN ROUND(SUM(spend)::numeric / SUM(clicks), 2) ELSE 0 END AS cpc, -- Вартість кліку
        CASE WHEN SUM(impressions) > 0 THEN ROUND(SUM(clicks)::numeric / SUM(impressions) * 100, 2) ELSE 0 END AS ctr, -- Коефіцієнт клікабельності
        CASE WHEN SUM(impressions) > 0 THEN ROUND(SUM(spend)::numeric / SUM(impressions) * 1000, 2) ELSE 0 END AS cpm, -- Вартість 1000 показів
        CASE WHEN SUM(spend) > 0 THEN ROUND(SUM(value - spend)::numeric / SUM(spend) * 100, 2) ELSE 0 END AS romi -- Рентабельність інвестицій
    FROM campaign_name_daily
    GROUP BY ad_month, utm_campaign -- Групування за місяцем і кампанією
),

-- CTE: Порівняння поточних і попередніх значень метрик
previous_month_campaign_name AS (
    SELECT
        ad_month,
        utm_campaign,
        cpc, ctr, cpm, romi,
        LAG(cpc, 1) OVER (PARTITION BY utm_campaign ORDER BY ad_month) AS previous_cpc, -- Попереднє значення CPC
        LAG(ctr, 1) OVER (PARTITION BY utm_campaign ORDER BY ad_month) AS previous_ctr, -- Попереднє значення CTR
        LAG(cpm, 1) OVER (PARTITION BY utm_campaign ORDER BY ad_month) AS previous_cpm, -- Попереднє значення CPM
        LAG(romi, 1) OVER (PARTITION BY utm_campaign ORDER BY ad_month) AS previous_romi -- Попереднє значення ROMI
    FROM campaign_name_monthly
)

-- Фінальний запит: Розрахунок відсоткових змін метрик
SELECT *,
    CASE 
        WHEN previous_cpc > 0 THEN ROUND((cpc::numeric / previous_cpc - 1), 2) -- Зміна CPC у відсотках
        WHEN previous_cpc = 0 AND cpc > 0 THEN 1
    END AS cpc_change,
    CASE 
        WHEN previous_ctr > 0 THEN ROUND((ctr::numeric / previous_ctr - 1), 2) -- Зміна CTR у відсотках
        WHEN previous_ctr = 0 AND ctr > 0 THEN 1
    END AS ctr_change,
    CASE 
        WHEN previous_cpm > 0 THEN ROUND((cpm::numeric / previous_cpm - 1), 2) -- Зміна CPM у відсотках
        WHEN previous_cpm = 0 AND cpm > 0 THEN 1
    END AS cpm_change,
    CASE 
        WHEN previous_romi > 0 THEN ROUND((romi::numeric / previous_romi - 1), 2) -- Зміна ROMI у відсотках
        WHEN previous_romi = 0 AND romi > 0 THEN 1
    END AS romi_change
FROM previous_month_campaign_name;


