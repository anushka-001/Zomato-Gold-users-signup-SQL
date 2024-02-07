Create database goldusers_signup;
USE goldusers_signup;

INSERT INTO goldusers_signup (user_id, gold_signup_date) VALUES 
(1, '2017-09-22'),
(3, '2017-04-21');

CREATE TABLE users(user_id integer,signup_date date); 
INSERT INTO users (user_id, signup_date) VALUES 
(1, '2014-09-02'),
(2, '2015-01-15'),
(3, '2014-04-11');

CREATE TABLE sales(user_id integer,created_date date,product_id integer); 
INSERT INTO sales (user_id, created_date, product_id) VALUES 
(1, '2017-04-19', 2),
(3, '2019-12-18', 1),
(2, '2020-07-20', 3),
(1, '2019-10-23', 2),
(1, '2018-03-19', 3),
(3, '2016-12-20', 2),
(1, '2016-11-09', 1),
(1, '2016-05-20', 3),
(2, '2017-09-24', 1),
(1, '2017-03-11', 2),
(1, '2016-03-11', 1),
(3, '2016-11-10', 1),
(3, '2017-12-07', 2),
(3, '2016-12-15', 2),
(2, '2017-11-08', 2),
(2, '2018-09-10', 3);

CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

1)what is the total amount each customer spent on zomato?
SELECT a.user_id, SUM(b.price) AS total_spent
FROM sales a
INNER JOIN product b ON a.product_id = b.product_id
GROUP BY a.user_id;

2)how many days each customer has visited zomato?
select user_id ,count(distinct created_date)distinct_days from sales group by user_id;

3)what was first product purchased by each customer?

SELECT * FROM (
  SELECT *, RANK() OVER (PARTITION BY user_id ORDER BY created_date) AS rnk 
  FROM sales
) AS a 
WHERE a.rnk = 1;

4)what is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT product_id, COUNT(product_id) AS product_count
FROM sales
GROUP BY product_id
ORDER BY product_count DESC
LIMIT 1;

5)which item was most popular for each customer?

SELECT *, RANK() OVER (PARTITION BY user_id ORDER BY product_count DESC) AS `rank`
FROM (
    SELECT user_id, product_id, COUNT(product_id) AS product_count
    
6)which item was purchased first by the customer after they became a member?

SELECT c.*, RANK() OVER (PARTITION BY c.user_id ORDER BY c.created_date) AS rnk 
FROM (
    SELECT a.user_id, a.created_date, a.product_id, b.gold_signup_date 
    FROM sales a
    INNER JOIN goldusers_signup b ON a.user_id = b.user_id AND a.created_date > b.gold_signup_date
) AS c;

7)Which item was purchased just before the customer became a member?

SELECT *
FROM (
    SELECT a.user_id, a.created_date, a.product_id, b.gold_signup_date
    FROM sales a
    INNER JOIN goldusers_signup b ON a.user_id = b.user_id AND a.created_date <= b.gold_signup_date
) AS c;

8)what is the total orders and amount spent for each member before they became a member?

SELECT 
    c.user_id, 
    COUNT(c.created_date) AS order_purchased, 
    SUM(d.price) AS total_amt_spent 
FROM 
    (SELECT 
         a.user_id, 
         a.created_date, 
         a.product_id, 
         b.gold_signup_date 
     FROM sales a 
     INNER JOIN goldusers_signup b ON a.user_id = b.user_id 
     AND a.created_date <= b.gold_signup_date) AS c 
INNER JOIN product d ON c.product_id = d.product_id 
GROUP BY c.user_id;

9)if buying each product generates points for eg 5rs=2 zomato point and each product has different purchasing points
for eg for p1 5rs=1 zomato point,for p2 10rs=5zomato points and p3 5rs=1 zomato point 2rs=1 zomato point

calculate the points calculated by each customer and for which product most points have been given till now?

 
	SELECT 
    user_id, 
    SUM(total_points) AS sum_total_points
FROM (
    SELECT 
        user_id, 
        product_id, 
        SUM(price) AS total_spent, 
        SUM(
            CASE 
                WHEN product_id = 1 THEN 5 
                WHEN product_id = 2 THEN 2 
                WHEN product_id = 3 THEN 5 
                ELSE 0 
            END
        ) AS total_points
    FROM (
        SELECT 
            a.user_id, 
            a.product_id, 
            b.price 
        FROM sales a 
        INNER JOIN product b ON a.product_id = b.product_id
    ) AS sales_product
    GROUP BY user_id, product_id
) AS grouped_sales
GROUP BY user_id;
 
 10)In the first one year after a customer joins the gold program (including the joining date)irrespective of what the customer has purchased they earn 5 zomato points for evry 10 rs spent .who earned more ,1 or 3 
 and what were their point earnings in the first year?
 
SELECT 
    c.user_id, 
    c.created_date, 
    c.product_id, 
    c.gold_signup_date,
    d.price AS amount 
FROM 
    (
        SELECT 
            a.user_id, 
            a.created_date, 
            a.product_id, 
            b.gold_signup_date 
        FROM sales a
        INNER JOIN goldusers_signup b ON a.user_id = b.user_id 
        AND a.created_date > b.gold_signup_date
        AND a.created_date <= DATE_ADD(b.gold_signup_date, INTERVAL 1 YEAR)
    ) AS c
INNER JOIN product d ON c.product_id = d.product_id
LIMIT 0, 1000;

11 rnk all the transactions of the customers

select * from sales
select*,rank()over(partition by user_id order by created_date)rnk from sales;

12.rank all the transactions for each member whenever they are a zomato gold member for every non gold memeber transaction mark as na
 
 SELECT 
    c.*,
    CASE 
        WHEN c.gold_signup_date IS NULL THEN 0 
        ELSE c.rnk 
    END AS adjusted_rank
FROM (
    SELECT 
        a.user_id,
        a.created_date,
        a.product_id,
        b.gold_signup_date,
        RANK() OVER (PARTITION BY a.user_id ORDER BY a.created_date DESC) AS rnk
    FROM sales a 
    LEFT JOIN goldusers_signup b ON a.user_id = b.user_id AND a.created_date >= b.gold_signup_date
) AS c;










   






