### Revenue Metrics

**Revenue Metrics - Показники доходу**

- **Головна ідея проєкту:** Створити дашборд для аналізу грошових надходжень на проекті. За його допомогою продуктові менеджери будуть відслідковувати динаміку змін грошових надходжень та робити верхньорівневий аналіз факторів цих змін.
- **Функціонал:** Візуалізація грошових надходжень, верхньорівневий аналіз факторів, інтерактивна зміна параметрів для аналізу.
- **Стек технології:** PostgreSQL та Tableau.

![](https://github.com/Valentyna-Lychko/Data-Analytics-Projects-UA-/blob/main/Dashboards_PNG/Analysis_Revenue_Metrics_Dashboard_All.png)

---

### Розрахунок метрик та підготовка до візуалізації в Tableau

- Результат SQL запиту вивантажено CSV файл і підключено до Tableau.
- Побудовано графіки і створено дашборд.
- Дашборд містить фільтри за датою, мовою користувача та віком користувача.

![](https://github.com/Valentyna-Lychko/Data-Analytics-Projects-UA-/blob/main/Dashboards_PNG/MRR_PaidUser.png)

---

### Розраховані показники:

- **Total Revenue** – Загальний дохід
- **Monthly Recurring Revenue (MRR)** - Щомісячний повторюваний дохід
- **Paid Users** - Платні користувачі
- **Average Revenue Per Paid User (ARPPU)** - Середній дохід на платного користувача
- **New Paid Users** - Нові платні користувачі
- **New MRR** - Новий щомісячний повторюваний дохід
- **Churned Users** - Відтік користувачів
- **Churned Revenue** - Втрачений дохід від відтоку
- **Expansion MRR** - Зростання щомісячного повторюваного доходу
- **Contraction MRR** - Зменшення щомісячного повторюваного доходу
- **Customer LifeTime (LT)** - Тривалість життя клієнта
- **Customer LifeTime Value (LTV)** - Цінність життєвого циклу клієнта

![](https://github.com/Valentyna-Lychko/Data-Analytics-Projects-UA-/blob/main/Dashboards_PNG/NewMRR_NewPaidUser.png)

---

### Revenue Analysis - Аналіз доходів

**Total Revenue (Загальний дохід):** Це загальна сума доходу, яку компанія отримала за певний період часу. Вона включає всі джерела доходу, такі як продажі, підписки, та інші надходження.

![](https://github.com/Valentyna-Lychko/Data-Analytics-Projects-UA-/blob/main/Dashboards_PNG/ChurnedRevenue_ChurnedUsers.png)

---

### Аналіз доходів та активності платних користувачів

**Monthly Recurring Revenue (MRR):** Визначає загальну суму доходу від платних користувачів протягом місяця, включаючи регулярні платежі за підписки або послуги. Важлива метрика для аналізу та прогнозування доходів, а також для оцінки стабільності та прибутковості бізнес-моделі.

**Paid Users:** Показує кількість унікальних користувачів, які здійснили платежі за продукт чи послугу протягом місяця. Метрика допомагає вимірювати ефективність стратегій монетизації, утримання користувачів та зростання бізнесу.

![](https://github.com/Valentyna-Lychko/Data-Analytics-Projects-UA-/blob/main/Dashboards_PNG/Exprension_Contraction_MRR.png)

Разом ці метрики дають уявлення про дохідність, стабільність бізнесу та активність користувачів у використанні платних послуг.

---

### Аналіз нових платників та їхнього внеску у щомісячний дохід

**New MRR:** Ця метрика вказує на суму повторюваного доходу, який був згенерований новими платниками протягом відповідного місяця. Вона відображає приріст нових платників та їхній внесок у загальний дохід компанії за певний період.

**New Paid Users:** Ця метрика показує кількість користувачів, які вперше почали платити за продукт або послугу у відповідний період часу. Вона вказує на зростання клієнтської бази та ефективність стратегій залучення нових платників компанією.

![](https://github.com/Valentyna-Lychko/Data-Analytics-Projects-UA-/blob/main/Dashboards_PNG/LT_LTV.png)

---

### Аналіз втраченого доходу та користувачів

**Churned Revenue:** Загальна сума коштів, яку компанія втратила через втрату клієнтів протягом певного періоду часу. Це всі втрачені доходи від користувачів, які припинили платні підписки або інше платне використання продукту.

**Churned Users:** Кількість користувачів, які припинили використання платних послуг або продуктів компанії протягом відповідного періоду.

![](https://github.com/Valentyna-Lychko/Data-Analytics-Projects-UA-/blob/main/Dashboards_PNG/ARPPU_PaidUser.png)

---

### Висновки

Метою проєкту було створення системи аналізу та візуалізації ключових метрик ефективності бізнесу з використанням SQL та Tableau. Отримані навички роботи з фінансовими метриками дозволили ефективно аналізувати ключові метрики бізнесу та приймати обґрунтовані стратегічні рішення на основі фактичних даних.

---


---


### Матеріали проєкту

- [SQL код](https://github.com/Valentyna-Lychko/Data-Analytics-Projects-UA-/blob/main/SQL_Files/RevenueMetricsUA.sql) – файл із SQL-запитом, який використовувався для обробки даних.
- [PDF презентація](https://github.com/Valentyna-Lychko/Data-Analytics-Projects-UA-/blob/main/Dashboards_and_Reports/Analysis_Revenue_Metrics.pdf) – файл із коротким описом і візуалізацією результатів.
- [Revenue Analysis PDF](https://github.com/Valentyna-Lychko/Data-Analytics-Projects-UA-/blob/main/Dashboards_and_Reports/REVENUE_ANALYSIS.pdf) – статичне зображення дашборда, яке демонструє ключові показники аналізу доходів.
- [Дашборд у Tableau Public](https://public.tableau.com/app/profile/valentyna.lychko/viz/AnalysisRevenueMetrics/REVENUEANALYSIS) – інтерактивний дашборд із аналізом.
