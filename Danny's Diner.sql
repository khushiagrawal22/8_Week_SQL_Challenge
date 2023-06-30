use dannys_diner;

/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

select s.customer_id, sum(m.price) as total 
from sales as s inner join menu  as m
on s.product_id = m.product_id
group by s.customer_id;

-- 2. How many days has each customer visited the restaurant?

select customer_id, count(distinct(order_date)) as total_days
from sales
group by customer_id;


-- 3. What was the first item from the menu purchased by each customer?

with cte1 as(
select s.customer_id, m.product_name, order_date,
row_number() over(partition by customer_id order by order_date) as rnk
from sales as s 
inner join 
menu as m
on s.product_id = m.product_id
) 
select customer_id, product_name
from cte1
where rnk = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select m.product_name , count(s.product_id) as total_purchase
from sales as s 
inner join 
menu as m 
on s.product_id = m.product_id
group by product_name
order by 2 desc
limit 1;

-- 5. Which item was the most popular for each customer?

with cte1 as (
select s.customer_id, m.product_name , count(s.product_id) as total_purchase,
row_number() over(partition by s.customer_id order by count(s.product_id) desc) as rnk
from sales as s 
inner join 
menu as m 
on s.product_id = m.product_id
group by m.product_name , s.customer_id
)
select customer_id, product_name 
from cte1 
where rnk =1;


-- 6. Which item was purchased first by the customer after they became a member?

with cte1 as (
select s.customer_id, s.product_id, s.order_date ,
row_number() over(partition by s.customer_id order by s.order_date) as rnk
from sales s , members m
where s.customer_id = m.customer_id and 
m.join_date > s.order_date 
)
select c.customer_id, m.product_name
from cte1 as c, menu  as m
where c.product_id = m.product_id
and rnk =1
order by c.customer_id;



-- 7. Which item was purchased just before the customer became a member?

with cte1 as (
select s.customer_id, s.product_id, s.order_date ,
rank() over(partition by s.customer_id order by s.order_date desc) as rnk
from sales s , members m
where s.customer_id = m.customer_id and 
m.join_date > s.order_date 
)
select c.customer_id, m.product_name
from cte1 as c, menu  as m
where c.product_id = m.product_id
and rnk =1
order by c.customer_id;


-- 8. What is the total items and amount spent for each member before they became a member?

select mb.customer_id, count(s.product_id) as total_items , sum(m.price) as amount_spent
from menu as m 
inner join 
sales as s 
on m.product_id = s.product_id
inner join 
members as mb
on s.customer_id =  mb.customer_id
where mb.join_date > order_date
group by mb.customer_id
order by mb.customer_id;


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select  s.customer_id, 
sum(case
 when product_name = "sushi" then price * 10*2 
 else price *10 
 end) as total_points
from menu as m
inner join
sales as s
on m.product_id = s.product_id
group by customer_id
order by total_points desc;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

select t.customer_id, sum(t.points) as total_points 
from ( 
select s.customer_id, month(s.order_date) as mon , 
case when s.order_date >= mem.join_date then m.price* 2 else 0 end as points
from menu as m 
inner join 
sales as s 
on m.product_id = s.product_id
inner join
members as mem 
on s.customer_id = mem.customer_id 
where s.order_date >= mem.join_date ) as t
where t.mon = 1
group by 1;



-- Bonus Questions
-- Join All The Things

select 
s.customer_id, s.order_date, m.product_name, m.price,
case 
	when mb.join_date <= s.order_date then 'Y' 
    else 'N' 
    end as member 
from menu as m 
inner join 
sales as s
on s.product_id = m.product_id 
left join 
members as mb 
on s.customer_id = mb.customer_id
order by 1;


-- Rank All The Things

with cte1 as (
select 
s.customer_id, s.order_date, m.product_name, m.price,
case 
	when mb.join_date <= s.order_date then 'Y' 
    else 'N' 
    end as member 
from menu as m 
inner join 
sales as s
on s.product_id = m.product_id 
left join 
members as mb 
on s.customer_id = mb.customer_id
order by 1
)
select * , case when member = 'N' then 'Null'
else rank() over(partition by customer_id, member order by order_date) end as ranking
from cte1;






