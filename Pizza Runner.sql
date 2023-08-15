CREATE SCHEMA pizza_runner;
USE pizza_runner;

CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);


INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);


INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');



CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);

INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');



CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);

INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
  /* --------------------
   Case Study Questions
   --------------------*/
   
 -- A. Pizza Metrics --
 
-- 1. How many pizzas were ordered?

select count(*) as total_pizza_ordered 
from customer_orders;

-- 2. How many unique customer orders were made?

select count(distinct(customer_id)) as total_unique_customers
from customer_orders;

-- 3. How many successful orders were delivered by each runner?

select runner_id , count(order_id) from runner_orders
where pickup_time <> 0
group by runner_id;

-- 4. How many of each type of pizza was delivered?

select c.pizza_id, p.pizza_name, count(c.pizza_id) as total_pizza_delivered
from runner_orders as r
inner join 
customer_orders as c
on r.order_id = c.order_id
inner join 
pizza_names as p
on c.pizza_id = p.pizza_id
where r.pickup_time <> 0
group by 1,2 ;


-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

select c.customer_id, p.pizza_name, count(c.pizza_id) as pizza_ordered
from runner_orders as r
inner join 
customer_orders as c
on r.order_id = c.order_id
inner join 
pizza_names as p
on c.pizza_id = p.pizza_id
group by 1,2
order by customer_id asc ;

-- 6. What was the maximum number of pizzas delivered in a single order?

select max(t.total_pizza) as max_pizza_delieved
from (
select order_id, count(pizza_id) as total_pizza
from customer_orders
group by 1) as t;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

select
  co.customer_id,
  count(distinct case when ro.cancellation is Not null or ro.pickup_time is null then co.order_id end) as pizzas_with_changes,
  count(distinct case when ro.cancellation is null and ro.pickup_time is not null then co.order_id end) as pizzas_without_changes
from customer_orders co
left join runner_orders ro on co.order_id = ro.order_id
group by co.customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?

select count(distinct(r.order_id)) as total_orders
from customer_orders as c
inner join 
runner_orders as r
on c.order_id = r.order_id
where c.exclusions and c.extras is not null  and r.distance <> 0;

-- 9. What was the total volume of pizzas ordered for each hour of the day?

select hours, count(hours) as total_pizza
from (select *, hour(order_time) as hours from customer_orders) as t
group by hours
order by total_pizza desc;

-- 10. What was the volume of orders for each day of the week?

select day , count(day) as total_order_per_day
from( select *, dayname(order_time) as day from customer_orders ) as t 
group by day
order by 2 desc ;

-- B. Runner and Customer Experience -- 

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

select week(registration_date) as week , count(runner_id) as Total_runners from runners
where registration_date >= 2021-01-01
group by 1;

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

select runner_id , avg(minute(timediff(pickup_time, order_time))) as avg_time
from runner_orders as r
inner join 
customer_orders as c
on r.order_id = c.order_id
group by runner_id;


-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

with cte as (
select c.order_id , 
count(c.pizza_id) as num_of_pizzas , 
max(minute(TIMEDIFF(c.order_time, r.pickup_time))) as prep_time
from customer_orders as c
inner join 
runner_orders as r
ON c.order_id = r.order_id
where pickup_time <> 'null'
group by c.order_id 
)
select num_of_pizzas, round(avg(prep_time) ,2) as avg_prep_time
from cte
group by num_of_pizzas;


-- 4. What was the average distance travelled for each customer?

select c.customer_id, round(avg(r.distance),1) as avg_distance
from customer_orders as c 
inner join 
runner_orders as r
on c.order_id = r.order_id
where r.distance <> 'null'
group by c.customer_id;


-- 5. What was the difference between the longest and shortest delivery times for all orders?

select  max(duration) - min(duration) as time_diff
from runner_orders as r
join 
customer_orders as c
on r.order_id = c.order_id
where pickup_time <> 'null' ;


-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

select order_id, runner_id, round(avg(distance / (duration / 60)), 2)as avg_speed
from runner_orders
where duration <> 'null'
group by 1,2;

-- 7. What is the successful delivery percentage for each runner?

select runner_id, count(order_id) as all_orders , 
concat(round(sum(case when pickup_time = 'null' then 0 
			else 1 end ) / count(*) * 100, 1), "%") as successful_delivery_percentage
from runner_orders 
group by 1;

-- C. Ingredient Optimisation -- 
-- 1. What are the standard ingredients for each pizza?

select  p.pizza_name,   group_concat(t.topping_name) as ingredients 
from pizza_names as p
join pizza_recipes as r
on p.pizza_id = r.pizza_id
join pizza_toppings as t
on r.toppings= t.topping_id 
group by p.pizza_name;


-- 2. What was the most commonly added extra?

SELECT pt.topping_name, COUNT(*) AS extra_count
FROM customer_orders co
JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, co.extras)
WHERE co.extras IS NOT NULL
GROUP BY pt.topping_name
ORDER BY extra_count DESC
LIMIT 1;


-- 3. What was the most common exclusion?

SELECT pt.topping_name AS excluded_ingredient, COUNT(*) AS exclusion_count
FROM customer_orders co
JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, co.exclusions)
WHERE co.exclusions IS NOT NULL AND co.exclusions != 'null'
GROUP BY pt.topping_name
ORDER BY exclusion_count DESC
LIMIT 1;

/*- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers-- */

SELECT 
  co.order_id,
  CONCAT(
    pn.pizza_name,
    CASE WHEN co.exclusions IS NOT NULL AND co.exclusions != 'null' THEN
      CONCAT(' - Exclude ', 
        GROUP_CONCAT(DISTINCT pt_exclude.topping_name ORDER BY pt_exclude.topping_name SEPARATOR ', ')
      )
    ELSE '' END,
    CASE WHEN co.extras IS NOT NULL AND co.extras != 'null' THEN
      CONCAT(' - Extra ',
        GROUP_CONCAT(DISTINCT pt_extra.topping_name ORDER BY pt_extra.topping_name SEPARATOR ', ')
      )
    ELSE '' END
  ) AS order_item
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
LEFT JOIN pizza_toppings pt_exclude ON FIND_IN_SET(pt_exclude.topping_id, co.exclusions)
LEFT JOIN pizza_toppings pt_extra ON FIND_IN_SET(pt_extra.topping_id, co.extras)
GROUP BY co.order_id, pn.pizza_name, co.exclusions, co.extras;

-- 5.Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
SELECT
  co.order_id,
  GROUP_CONCAT(
    IF(FIND_IN_SET(pt.topping_id, co.exclusions), 
       CONCAT('2x ', pt.topping_name),
       pt.topping_name)
    ORDER BY pt.topping_name SEPARATOR ', '
  ) AS ingredient_list
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
JOIN pizza_recipes pr ON pn.pizza_id = pr.pizza_id
JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, pr.toppings)
GROUP BY co.order_id, co.exclusions
ORDER BY co.order_id;


-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

SELECT pt.topping_name AS ingredient_name, 
       SUM(CASE WHEN co.exclusions IS NULL OR co.exclusions != 'null' THEN 1 ELSE 0 END) AS total_quantity
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
JOIN pizza_recipes pr ON pn.pizza_id = pr.pizza_id
JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, pr.toppings)
GROUP BY pt.topping_name
ORDER BY total_quantity DESC;


-- D. Pricing and Ratings --

-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

SELECT
  SUM(CASE WHEN pn.pizza_name = 'Meatlovers' THEN 12
           WHEN pn.pizza_name = 'Vegetarian' THEN 10
           ELSE 0 END) AS total_revenue
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id;

/* 2. What if there was an additional $1 charge for any pizza extras?
Add cheese is $1 extra */

SELECT
  SUM(CASE
        WHEN pn.pizza_name = 'Meatlovers' THEN 12
        WHEN pn.pizza_name = 'Vegetarian' THEN 10
        ELSE 0
      END
      +
      CASE
        WHEN co.extras IS NOT NULL AND co.extras != 'null' THEN 1
        ELSE 0
      END
      +
      CASE
        WHEN co.extras LIKE '%Cheese%' THEN 1
        ELSE 0
      END) AS total_revenue
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id;

/* 3 The Pizza Runner team now wants to add an additional ratings system that allows customers to rate 
their runner, how would you design an additional table for this new dataset - generate a schema for this 
new table and insert your own data for ratings for each successful customer order between 1 to 5.*/ 

DROP TABLE IF EXISTS runner_ratings;
CREATE TABLE runner_ratings 
 (order_id INTEGER,
    rating INTEGER);
INSERT INTO runner_ratings
 (order_id ,rating)
VALUES 
(1,3),
(2,4),
(3,5),
(4,2),
(5,1),
(6,3),
(7,4),
(8,1),
(9,3),
(10,5); 

SELECT * 
from runner_ratings;

/* 4 Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
customer_id
order_id
runner_id
rating
order_time
pickup_time
Time between order and pickup
Delivery duration
Average speed
Total number of pizzas */

SELECT customer_id , 
        c.order_id, 
        runner_id, 
        rating, 
        order_time, 
        pickup_time, 
         EXTRACT(MINUTE FROM TIMEDIFF(pickup_time, order_time)) as Time_order_pickup, 
        r.duration, 
        round(avg(distance/duration*60),2) as avg_Speed, 
        COUNT(pizza_id) AS Pizza_Count
FROM customer_orders c
LEFT JOIN runner_orders r ON c.order_id = r.order_id 
LEFT JOIN runner_ratings r2 ON c.order_id = r2.order_id
WHERE r.cancellation is NULL
GROUP BY customer_id , c.order_id, runner_id, rating, order_time, pickup_time, EXTRACT(MINUTE FROM TIMEDIFF(pickup_time, order_time)) , r.duration
ORDER BY c.customer_id;


-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

WITH CTE AS (SELECT c.order_id,
                    SUM(CASE WHEN pizza_name = 'Meatlovers' THEN 12
                          ELSE 10 END) AS pizza_cost
             FROM pizza_names p
             JOIN customer_orders c ON p.pizza_id =c.pizza_id
             GROUP BY c.order_id) 

SELECT SUM(pizza_cost) AS revenue, 
       SUM(distance) *0.3 as total_cost,
       SUM(pizza_cost) - SUM(distance)*0.3 as profit
FROM runner_orders r 
JOIN CTE c ON R.order_id =C.order_id
WHERE r.cancellation is NULL;

-- E. Bonus Questions -- 

/*-- If Danny wants to expand his range of pizzas - how would this impact the existing data design?
Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings
was added to the Pizza Runner menu? */ 

INSERT INTO pizza_names (pizza_id, pizza_name)
VALUES (3, 'Supreme');

INSERT INTO pizza_recipes (pizza_id, toppings)
VALUES (3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');

INSERT INTO pizza_toppings (topping_id, topping_name)
VALUES (13, 'New Topping 1'),
       (14, 'New Topping 2');

ALTER TABLE customer_orders
MODIFY COLUMN extras VARCHAR(100);

INSERT INTO customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES ('11', '105', '3', '', '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12', '2020-01-12 12:00:00');
