select * from customer_orders;

select * from pizza_names;

select * from pizza_recipes;

select * from pizza_toppings;

select * from runner_orders;

select * from runners;



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





-- How many pizzas were ordered?
select
count(order_id) as total_pizza
from customer_orders;




-- How many successfull orders were delivered by each runner?
select
runner_id,
sum(case when cancellation is null then 1 else 0 end) as no_of_delivery
from runner_orders
group by runner_id;


-- how man of each type of pizza was delivered?
select 
pizza_id,
count(pizza_id) as number
from customer_orders
group by pizza_id;



-- how many meatlovers and vegetarian pizzas were delivered by each customer?


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



-- what is the maximum numbers of pizza ordered in a single order

select
max(t.ordered) 
from
(select
co.order_id as id,
count(co.pizza_id ) as ordered
from customer_orders co
left join runner_orders ro on ro.order_id=co.order_id
where ro.cancellation is null
group by co.order_id) t;


-- For each customer how many pizzas had at least 1 change and how many had no change?
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

-- How many pizzas had both exclusions and extras
select
count(order_id) as count
from customer_orders
where exclusions is not null and extras is not null;


-- what is  the volume of  the pizzas ordered each hour of the day?
select 
hour(order_time) as order_hour,
count(pizza_id) as orders
from customer_orders
group by  1;


-- roe each customer how many pizza's had at least 1 change and how many had no change?
select 
dayname(order_time) as day,
count(pizza_id) as pizza_ordered
from customer_orders
group by 1;
                -- Runner and Customer exirience
                
-- Hoe man runners signed up for 1 week period?
select
runner_id
from runners
where registration_date < '2021-01-07';
                

-- What is the average time in minutes it took for each runner to arrive at the pizza runner HQ to pick up the pizza?
select 
timediff((co.order_time ,'%H:%M:%S'),( ro.pickup_time, '%H:%M:%S')) as diff
from customer_orders co
left join runner_orders ro on ro.order_id=co.order_id                