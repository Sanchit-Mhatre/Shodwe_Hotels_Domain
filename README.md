# 🏨 Shodwe Hotels — Hospitality Analytics Dashboard

Analyzed 1,34,590 hotel bookings across 25 properties to identify ₹29.88 Crore in revenue leakage — found cancellation rate of 24.83% (5% above industry benchmark) as the primary driver, with weekday stays generating 62.7% of total revenue vs weekends.

---

## 🎯 Business Problem

Shodwe Hotels had no visibility into why revenue was underperforming across its 4-city portfolio. Management needed answers to:

- Where is revenue being lost and why?
- Which properties and room classes are underperforming?
- How does occupancy and ADR change week over week?

---

## 📊 Key Results

| KPI | Value |
|---|---|
| Total Revenue | ₹170.88 Crore |
| Revenue Lost (Leakage) | ₹29.88 Crore |
| Occupancy Rate | 57.87% |
| Cancellation Rate | 24.83% |
| ADR | ₹14,925 |
| RevPAR | ₹7,347 |
| Avg Guest Rating | 3.62 / 5 |
| Unsold Room Nights | 97,986 |

---

## 💡 Key Insights

- **₹29.88 Cr lost** to cancellations and no-shows — 14.9% of total billed revenue
- **24.83% cancellation rate** — nearly 1 in 4 bookings never happened
- **97,986 unsold room nights** — dynamic pricing opportunity worth crores
- **Weekdays drive 62.7%** of all revenue vs 37.3% on weekends

---

## 🗂️ Dataset

5 tables — 2 fact + 3 dimension — covering May to July 2022 (14 weeks) across Delhi, Mumbai, Hyderabad and Bangalore.

| Table | Rows | Description |
|---|---|---|
| fact_bookings | 1,34,590 | Individual booking transactions |
| fact_aggregated_bookings | 9,200 | Daily room capacity by property |
| dim_hotels | 25 | Hotel name, city, category |
| dim_rooms | 4 | Standard / Elite / Premium / Presidential |
| dim_date | 92 | Date, week number, weekday/weekend |

---

## 🌟 Data Model

Star schema — 6 relationships, all Many-to-One (Fact → Dimension)

```
fact_bookings ──────────── property_id ────► dim_hotels
fact_bookings ──────────── check_in_date ──► dim_date
fact_bookings ──────────── room_category ──► dim_rooms

fact_aggregated_bookings ── property_id ────► dim_hotels
fact_aggregated_bookings ── check_in_date ──► dim_date
fact_aggregated_bookings ── room_category ──► dim_rooms
```

---

## 🧹 Data Cleaning

| Table | Issue | Fix |
|---|---|---|
| fact_bookings | 23 duplicate columns | Removed all after column V |
| fact_bookings | 77,907 nulls in ratings_given | Filled with 0 |
| fact_bookings | 1,01,170 nulls in cancellation_reason | Filled with "Not Cancelled" |
| dim_date | Typo "weekeday" in 65 rows | Fixed to "weekday" |
| dim_date | Date format "01-May-22" | Converted to "2022-05-01" |



---

## 🛠️ Tech Stack

`MySQL` `Excel Power Pivot` `Tableau` `Power BI` `Python` `SQL` `DAX`

---



## 📸 Dashboard Preview

![Dashboard Overview](https://github.com/Sanchit-Mhatre/Shodwe_Hotels_Domain/blob/main/src/PowerBi%20Dashboard2.png)



---

⭐ *If this project helped you, give it a star!*
