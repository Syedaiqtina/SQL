# 🍕 Case Study #2 - Pizza Runner

## 🍝 Solution - A. Pizza Metrics

## Dealing with NULL value
````sql
SET SQL_SAFE_UPDATES = 0;

UPDATE customer_orders
SET exclusions = NULL
WHERE exclusions IN ('null', '');


UPDATE customer_orders
SET extras = NULL
WHERE extras IN ('null', '');


UPDATE runner_orders
SET pickup_time = NULL
WHERE pickup_time = 'null';

UPDATE runner_orders
SET distance = NULL
WHERE distance = 'null';

UPDATE runner_orders
SET duration = NULL
WHERE duration = 'null';

UPDATE runner_orders
SET cancellation = NULL
WHERE cancellation IN ('null', '');

UPDATE runner_orders
SET distance = CAST(TRIM(REPLACE(distance, 'km', '')) AS DECIMAL(5,2))
WHERE distance IS NOT NULL;


UPDATE runner_orders
SET duration = CAST(
    TRIM(
        REPLACE(
            REPLACE(
                REPLACE(
                    REPLACE(duration, 'minutes', ''),
                'minute', ''),
            'mins', ''),
        'min', '')
    ) AS UNSIGNED
)
WHERE duration IS NOT NULL;
````

### 1. How many pizzas were ordered?

````sql
select
count(order_id) as total_pizza
from customer_orders;

````

**Answer:**
|FIELD1|total_pizza|
|------|-----------|
|      |14         |


- Total of 14 pizzas were ordered.

### 2. How many unique customer orders were made?

````sql
SELECT 
  COUNT(DISTINCT order_id) AS unique_order_count
FROM #customer_orders;
````

**Answer:**

![image](https://user-images.githubusercontent.com/81607668/129737993-710198bd-433d-469f-b5de-14e4022a3a45.png)

- There are 10 unique customer orders.

### 3. How many successful orders were delivered by each runner?

````sql
select
runner_id,
sum(case when cancellation is null then 1 else 0 end) as no_of_delivery
from runner_orders
group by runner_id;
````

**Answer:**

|runner_id|no_of_delivery|
|---------|--------------|
|1        |4             |
|2        |3             |
|3        |1             |


- Runner 1 has 4 successful delivered orders.
- Runner 2 has 3 successful delivered orders.
- Runner 3 has 1 successful delivered order.

### 4. How many of each type of pizza was delivered?

````sql
select 
pizza_id,
count(pizza_id) as number
from customer_orders
group by pizza_id;

````

**Answer:**

|pizza_id|number|
|--------|------|
|1       |10    |
|2       |4     |


### 5. How many Vegetarian and Meatlovers were ordered by each customer?**

````sql
select 
f.customer_id,
sum( case when cat="1" then 1 else 0 end) as meatlover,
sum(case when cat="0" then 1 else 0 end) as veglover
from
(select
t.customer_id,
case when pn.pizza_name = "Meatlovers" then 1 else 0 end as cat
from
(select
customer_id,
pizza_id
from customer_orders
order by customer_id) t
left join pizza_names pn on pn.pizza_id=t.pizza_id) f
group by customer_id
order by customer_id;

````

**Answer:**

|customer_id|meatlover|veglover|
|-----------|---------|--------|
|101        |2        |1       |
|102        |2        |1       |
|103        |3        |1       |
|104        |3        |0       |
|105        |0        |1       |

- Customer 101 ordered 2 Meatlovers pizzas and 1 Vegetarian pizza.
- Customer 102 ordered 2 Meatlovers pizzas and 1 Vegetarian pizzas.
- Customer 103 ordered 3 Meatlovers pizzas and 1 Vegetarian pizza.
- Customer 104 ordered 3 Meatlovers pizza.
- Customer 105 ordered 1 Vegetarian pizza.

### 6. What was the maximum number of pizzas delivered in a single order?

````sql
select
max(t.ordered) as max
from
(select
co.order_id as id,
count(co.pizza_id ) as ordered
from customer_orders co
left join runner_orders ro on ro.order_id=co.order_id
where ro.cancellation is null
group by co.order_id) t;
````

**Answer:**

|max|
|---|
|3  |

- Maximum number of pizza delivered in a single order is 3 pizzas.

### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

````sql
select
t.customer_id,
sum(case when cat= 1 then 1 else 0 end) as yes_changed,
sum(case when cat=0 then 1 else 0 end) as no_change
from
(select
customer_id,
order_id,
case when exclusions is null and extras is null then 0 else 1 end as cat
from customer_orders) t
group by customer_id;
````

**Answer:**

|customer_id|yes_changed|no_change|
|-----------|-----------|---------|
|101        |0          |3        |
|102        |0          |3        |
|103        |4          |0        |
|104        |2          |1        |
|105        |1          |0        |



### 8. How many pizzas were delivered that had both exclusions and extras?

````sql
select
count(order_id) as count
from customer_orders
where exclusions is not null and extras is not null;

````

**Answer:**

|count|
|-----|
|2    |

- Only 2 pizza delivered that had both extra and exclusion topping.

### 9. What was the total volume of pizzas ordered for each hour of the day?

````sql
select 
hour(order_time) as order_hour,
count(pizza_id) as orders
from customer_orders
group by  1;

````

**Answer:**

|order_hour|orders|
|----------|------|
|18        |3     |
|19        |1     |
|23        |3     |
|13        |3     |
|21        |3     |
|11        |1     |


### 10. What was the volume of orders for each day of the week?





