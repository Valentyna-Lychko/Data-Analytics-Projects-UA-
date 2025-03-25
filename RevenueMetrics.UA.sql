-- Цей SQL-запит створено для проєкту RevenueMetrics

with revenue_month as (
    -- Створюємо тимчасову таблицю з місячними доходами, об'єднаними за користувачами та іграми
    select
        date(date_trunc('month', payment_date)) as payment_month, -- Округлюємо дату платежу до місяця
        user_id, -- Ідентифікатор користувача
        game_name, -- Назва гри
        sum(revenue_amount_usd) as total_revenue -- Сумуємо загальний дохід за місяць
    from project.games_payments gp
    group by 1,2,3 -- Групуємо за місяцем, користувачем і грою
),
revenue_lag_lead_months as (
    -- Додаємо колонки для попередніх і наступних місяців та їх доходів
    select
        *,
        date(payment_month - interval '1' month) as previous_claendar_month, -- Попередній календарний місяць
        date(payment_month + interval '1' month) as next_claendar_month, -- Наступний календарний місяць
        lag(total_revenue) over(partition by user_id order by payment_month) as previous_paid_month_revenue, -- Доходи за попередній платіжний місяць
        lag(payment_month) over(partition by user_id order by payment_month) as previous_paid_month, -- Попередній платіжний місяць
        lead(payment_month) over(partition by user_id order by payment_month) as next_paid_month, -- Наступний платіжний місяць
        lead(total_revenue) over(partition by user_id order by payment_month) as next_total_revenue -- Доходи за наступний платіжний місяць
    from revenue_month
),
revenue_metrics as (
    -- Вираховуємо метрики доходів, зокрема нових клієнтів, втрату клієнтів і розширення доходів
    select
        payment_month, -- Місяць платежу
        user_id, -- Ідентифікатор користувача
        game_name, -- Назва гри
        total_revenue, -- Загальний дохід
        previous_claendar_month, -- Попередній календарний місяць
        next_claendar_month, -- Наступний календарний місяць
        previous_paid_month_revenue, -- Доходи за попередній місяць
        previous_paid_month, -- Попередній платіжний місяць
        next_paid_month, -- Наступний платіжний місяць
        next_total_revenue, -- Доходи за наступний місяць
        case 
            when previous_paid_month is null 
                then total_revenue -- Дохід як новий, якщо немає попередніх платежів
        end as new_mrr,
        case 
            when previous_paid_month = previous_claendar_month 
                and total_revenue > previous_paid_month_revenue 
                then total_revenue - previous_paid_month_revenue -- Розширення доходу
        end as exprension_mrr,
        case 
            when previous_paid_month = previous_claendar_month 
                and total_revenue < previous_paid_month_revenue 
                then total_revenue - previous_paid_month_revenue -- Зменшення доходу
        end as contraction_mrr,
        case 
            when previous_paid_month != previous_claendar_month 
                and previous_paid_month is not null
                then total_revenue -- Доходи від повернення клієнтів
        end as back_from_churn_revenue,
        case 
            when next_paid_month is null 
            or next_paid_month != next_claendar_month
                then total_revenue -- Дохід від клієнтів, які втратили підписку
        end as churned_revenue,
        case 
            when next_paid_month is null 
            or next_paid_month != next_claendar_month
                then next_claendar_month -- Розрахунок дати втрати клієнта
        end as culc_churn
    from revenue_lag_lead_months
)
-- Завершальний запит із приєднанням додаткової інформації про користувачів
select
    rm.*, -- Усі колонки з таблиці метрик доходів
    gpu.language as user_language, -- Мова користувача
    gpu.age as user_age, -- Вік користувача
    gpu.has_older_device_model, -- Наявність старої моделі пристрою
    previous_claendar_month, -- Попередній календарний місяць
    next_claendar_month, -- Наступний календарний місяць
    previous_paid_month_revenue, -- Доходи за попередній платіжний місяць
    previous_paid_month, -- Попередній платіжний місяць
    next_paid_month, -- Наступний платіжний місяць
    next_total_revenue -- Доходи за наступний місяць
from revenue_metrics rm
left join project.games_paid_users gpu using(user_id); -- Приєднання таблиці з даними про користувачів
