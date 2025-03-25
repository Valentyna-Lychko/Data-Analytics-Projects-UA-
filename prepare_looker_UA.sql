-- Цей SQL-запит розроблено для проєкту SQLLookerStudio.
-- Він використовується для завантаження даних у Looker Studio.

-- CTE: З'єднання даних із таблиць Facebook
WITH facebook_home AS (
    SELECT *
    FROM facebook_campaign fc 
    LEFT JOIN facebook_ads_basic_daily fabd ON fc.campaign_id = fabd.campaign_id -- З'єднання з даними про денні покази
    LEFT JOIN facebook_adset fa ON fa.adset_id = fabd.adset_id -- З'єднання з даними про набори оголошень
),

-- CTE: Об'єднання даних Facebook та Google Ads
campaign_name_daily AS (
    SELECT 
        ad_date, -- Дата показу реклами
        campaign_name, -- Назва рекламної кампанії
        spend, -- Витрати
        impressions, -- Кількість показів
        clicks, -- Кількість кліків
        value -- Загальна вартість конверсій
    FROM facebook_home
    UNION -- Об'єднання з даними Google Ads
    SELECT 
        ad_date, 
        campaign_name,
        spend,
        impressions,
        clicks,
        value
    FROM public.google_ads_basic_daily
)

-- Підсумковий запит: Агрегація даних за датою та кампанією
SELECT 
    ad_date, -- Дата показу реклами
    campaign_name, -- Назва кампанії
    SUM(spend) AS spend, -- Загальні витрати на рекламу
    SUM(impressions) AS impressionsc, -- Загальна кількість показів
    SUM(clicks) AS clicks, -- Загальна кількість кліків
    SUM(value) AS value -- Загальна вартість конверсій
FROM campaign_name_daily
WHERE clicks > 0 -- Фільтр: включаються лише дні з кліками
GROUP BY 
    ad_date, -- Групування за датою
    campaign_name -- Групування за назвою кампанії
ORDER BY ad_date DESC; -- Сортування за спаданням дати




	
