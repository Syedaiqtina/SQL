# 🍜 Case Study #1: Danny's Diner 
<img src="https://user-images.githubusercontent.com/81607668/127727503-9d9e7a25-93cb-4f95-8bd0-20b87cb4b459.png" alt="Image" width="500" height="520">

## 📚 Table of Contents
- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Question and Solution](#question-and-solution)

Please note that all the information regarding the case study has been sourced from the following link: [here](https://8weeksqlchallenge.com/case-study-1/). 

***



***

## Question and Solution





**1. What is the total amount each customer spent at the restaurant?**

````sql

select
s.customer_id, 
sum(m.price) as total_spent
from sales s
left join menu m on m.product_id=s.product_id
group by customer_id;


```
####Answer:
||customer_id||total_spent||
|A|76||
|B|74||
|C|36||



***
####2. How many days has each customer visited the restaurant?**

````sql
select 
customer_id,
count(distinct order_date) as time_visited
from sales
group by customer_id;
````


#### Answer:
||customer_id||time_visited||
|A|4||
|B|6||
|C|2||

***

**3. What was the first item from the menu purchased by each customer?**

````sql
select
s.customer_id, 
s.product_id, 
s.order_date,
m.product_name
from sales s
join (select 
customer_id,
min(s.order_date) as first_visit
 from sales s
 group by customer_id
 ) f on 
 s.customer_id=f.customer_id and
 s.order_DATE=f.first_visit
 join menu m on
 m.product_id=s.product_id;
 
 


````


#### Answer:
||customer_id||product_id||order_date||product_name||
|A|1|2021-01-01|sushi||
|A|2|2021-01-01|curry||
|B|2|2021-01-01|curry||
|C|3|2021-01-01|ramen||
|C|3|2021-01-01|ramen||

***

**4. What is the most purchased item on the menu and how many times was it purchased by all customers?**

````sql
 select
 s.product_id,
 m.product_name,
 count(s.product_id) as time_ordered
 from sales s
 left join menu m on m.product_id=s.product_id
 group by 1,2;
 
````


#### Answer:
||product_id||product_name||time_ordered||
|1|sushi|3||
|2|curry|4||
|3|ramen|8||

***

**5. Which item was the most popular for each customer?**

````sql
SELECT 
  r.customer_id,
  r.product_id,
  m.product_name,
  r.purchase_count
FROM (
  SELECT 
    customer_id,
    product_id,
    COUNT(*) AS purchase_count,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id
      ORDER BY COUNT(*) DESC, product_id ASC   -- tie-breaker: smaller product_id wins
    ) AS rn
  FROM sales
  GROUP BY customer_id, product_id
) AS r
JOIN menu AS m 
  ON r.product_id = m.product_id
WHERE r.rn = 1
ORDER BY r.customer_id;
````



#### Answer:
||customer_id||product_id||product_name||purchase_count||
|A|3|ramen|3||
|B|1|sushi|2||
|C|3|ramen|3||

***

**6. Which item was purchased first by the customer after they became a member?**

```sql
select
customer_id,
product_id,
order_date
from
(select
m.customer_id, 
s.product_id,
s.order_date,
row_number() over(
partition by customer_id
order by order_date) as rn
from sales s
left join members m on m.customer_id=s.customer_id
where order_date>join_date ) t
where rn=1;

```



#### Answer:
||customer_id||product_id||order_date||
|A|3|2021-01-10||
|B|1|2021-01-11||

***

**7. Which item was purchased just before the customer became a member?**

````sql
select
customer_id,
product_id,
order_date
from
(select
m.customer_id,
s.product_id,
s.order_date,
rank() over(
partition by customer_id
order by order_date) as rn
from sales s
left join members m on m.customer_id=s.customer_id
where order_date<=join_date) t
where rn=1;


````


#### Answer:
||customer_id||product_id||order_date||
|A|1|2021-01-01||
|A|2|2021-01-01||
|B|2|2021-01-01||

***

**8. What is the total items and amount spent for each member before they became a member?**

```sql
select
t.customer_id,
sum(n.price) as money_spent,
count(t.product_id) as item_ordered
from
(select
s.customer_id,
s.order_date,
s.product_id
from sales s
left join members m on m.customer_id=s.customer_id
where s.order_date<=m.join_date) t
left join menu n on n.product_id=t.product_id
group by customer_id;



```


#### Answer:
||customer_id||money_spent||item_ordered||
|A|40|3||
|B|40|3||

***

**9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?**

```sql
select
customer_id,
sum(points)
from
(select
s.customer_id, 
s.product_id,
m.product_name,
m.price,
case 
when product_name="sushi" then price * 20
when product_name in ("curry", "ramen") then price * 10
end as points
from sales s
left join menu m on m.product_id=s.product_id) f
group by customer_id;

```


#### Answer:
||customer_id||sum(points)||
|A|860||
|B|940||
|C|360||

***

**10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?**

```sql
select
customer_id,
sum(points) as accquired_points
from
(select 
t.customer_id,
t.product_name,
t.order_date,
case
when t.order_date >= m.join_date and t.order_date <= (m.join_date + 6) then t.price * 20
when t.order_date<m.join_date or t.order_date>(m.join_date +6) and product_name = "sushi" then price * 20
else t.price * 10
end as points
from
(select
s.customer_id, 
s.product_id,
s.order_date,
n.product_name,
n.price
from sales s
left join menu n on n.product_id=s.product_id
where order_date <= '2021-01-31') t
left join members m on m.customer_id=t.customer_id) f
group by customer_id;
```




#### Answer:
||customer_id||accquired_points||
|A|1520||
|B|1120||
|C|360||

***

