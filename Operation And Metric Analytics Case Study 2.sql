--CASE STUDY 2()

-- A.  User Engagement: To measure the activeness of a user. Measuring if the user finds quality in a product/service.
--Your task: Calculate the weekly user engagement?

SELECT EXTRACT(week from occurred_at) AS weeknum , COUNT(DISTINCT user_id) 
FROM tutorial.yammer_events a
GROUP BY weeknum


--B. User Growth: Amount of users growing over time for a product.
--Your task: Calculate the user growth for product?

--User growth = number of active users per week

SELECT year, weeknum, num_active_user, SUM(num_active_user)OVER(ORDER BY year,weeknum ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_active_users
FROM 
( 
SELECT EXTRACT(year from a.activated_at) AS year, EXTRACT(week from a.activated_at) AS weeknum, COUNT(DISTINCT user_id) AS num_active_user
FROM 
tutorial.yammer_users a
WHERE state='active'
GROUP BY year, weeknum
ORDER BY year, weeknum
) a


--C. Weekly Retention: Users getting retained weekly after signing-up for a product.
--Your task: Calculate the weekly retention of users-sign up cohort?

--l28 = out of last 28 days, how many time a user come

SELECT 
COUNT(user_id), SUM(CASE WHEN retention_week = 1 THEN 1 ELSE 0 END) as week_1
FROM 
( SELECT a.user_id, a.signup_week, b.engagement_week, b.engagement_week - a.signup_week AS retention_week
FROM
( 
(SELECT DISTINCT user_id, EXTRACT(week FROM occurred_at) AS signup_week 
FROM tutorial.yammer_events 
WHERE event_type = 'signup_flow' AND event_name = 'comp  lete_signup' AND EXTRACT(week from occurred_at) = 18 ) a
      LEFT JOIN (
                 SELECT DISTINCT user_id, EXTRACT(week FROM occurred_at) AS engagement_week 
FROM tutorial.yammer_events
WHERE event_type = 'engagement' ) b ON a.user_id = b.user_id 
)
ORDER BY a.user_id 
) a


--Name of the devices
SELECT DISTINCT e.device AS devices
FROM tutorial.yammer_events e

--D. Weekly Engagement: To measure the activeness of a user. Measuring if the user finds quality in a product/service weekly.
--Your task: Calculate the weekly engagement per device?

SELECT DATE_TRUNC('week', occurred_at) AS week,
       COUNT(DISTINCT e.user_id) AS weekly_users,
       COUNT(DISTINCT CASE WHEN e.device IN ('macbook pro', 'acer aspire notebook','acer aspire desktop','lenovo thinkpad', 'mac mini', 'dell inspiron desktop','dell inspiron notebook','windows surface','macbook air','asus chromebook','hp pavilion desktop') THEN e.user_id ELSE NULL END) AS computer,
       COUNT(DISTINCT CASE WHEN e.device IN ('iphone 5s','nokia lumia 635','amazon fire phone','iphone 4s','htc one','iphone 5','samsung galaxy s4') THEN e.user_id ELSE NULL END) AS phone,
       COUNT(DISTINCT CASE WHEN e.device IN ('kindle fire','samsung galaxy note','ipad mini','nexus 7','nexus 10','samsumg galaxy tablet','nexus 5','ipad air') THEN e.user_id ELSE NULL END) AS tablet
FROM tutorial.yammer_events e
WHERE e.event_type = 'engagement'
AND e.event_name = 'login'
GROUP BY 1
ORDER BY 1 

--E. Email Engagement: Users engaging with the email service.
--Your task: Calculate the email engagement metrics?

SELECT 100.0 *
SUM(CASE WHEN email_cat = 'email_open' THEN 1 ELSE 0 END)/SUM(CASE WHEN email_cat = 'email_sent' THEN 1 ELSE 0 END) AS email_open_rate, 100.0 *
SUM(CASE WHEN email_cat = 'email_clicked' THEN 1 ELSE 0 END)/SUM(CASE WHEN email_cat = 'email_sent' THEN 1 ELSE 0 END) AS email_clicked_rate
FROM 
(
SELECT *, 
CASE WHEN action IN ('sent_weekly_digest', 'sent_reengagement_email') THEN 'email_sent' 
     WHEN action IN ('email_open') 
     THEN 'email_open'
     WHEN action in ('email_clickthrough') 
     THEN 'email_clicked' END AS email_cat 
FROM tutorial.yammer_emails 
) a







 


