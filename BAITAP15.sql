--1.Write a query to calculate the year-on-year growth rate for the total spend of each product, grouping the results by product ID.
--The output should include the year in ascending order, product ID, current year's spend, previous year's spend and year-on-year growth percentage, rounded to 2 decimal places.

With table1 AS
(SELECT EXTRACT (YEAR FROM transaction_date) AS yr,
product_id, SUM(spend) as curr_year_spend
FROM user_transactions
GROUP BY product_id,EXTRACT (YEAR FROM transaction_date))

SELECT yr, product_id,curr_year_spend,
lag(curr_year_spend) OVER(PARTITION BY product_id ORDER BY yr) as prev_year_spend,
ROUND(((curr_year_spend-lag(curr_year_spend) OVER(PARTITION BY product_id ORDER BY yr))/lag(curr_year_spend) OVER(PARTITION BY product_id ORDER BY yr))*100,2) as yoy_rate
FROM table1

--2.Write a query that outputs the name of the credit card, and how many cards were issued in its launch month. The launch month is the earliest record in the monthly_cards_issued table for a given card. Order the results starting from the biggest issued amount.
--You are asked to estimate how many cards you'll issue in the first month.

SELECT DISTINCT card_name,
FIRST_VALUE (issued_amount) OVER(PARTITION BY card_name ORDER BY issue_year,issue_month) AS first_issued_amount
FROM monthly_cards_issued
ORDER BY card_name DESC

--3. Write a query to obtain the third transaction of every user. Output the user id, spend and transaction date.

SELECT user_id,spend,transaction_date FROM
(SELECT *,
COUNT(spend) OVER(PARTITION BY user_id ORDER BY transaction_date) as so_lan
FROM transactions) as table1
where table1.so_lan=3

--4. Output the user's most recent transaction date, user ID, and the number of products, sorted in chronological order by the transaction date. -> tìm số sp mua trong mốc tg gần nhất = lần cuối mua bao nhiêu sp (không phải số lượng sp mua từ trước đến nay)

With table1 AS
(SELECT user_id,transaction_date,product_id,
RANK() OVER(PARTITION BY user_id ORDER BY transaction_date DESC) AS ranking
FROM user_transactions)
SELECT user_id, transaction_date,COUNT(product_id) AS purchase_count
FROM table1
WHERE ranking=1
GROUP BY transaction_date,user_id
ORDER BY transaction_date

--5. Given a table of tweet data over a specified time period, calculate the 3-day rolling average of tweets for each user. Output the user ID, tweet date, and rolling averages rounded to 2 decimal places.

---Bài sửa
SELECT    
  user_id,    
  tweet_date,   
  ROUND(AVG(tweet_count) OVER (
    PARTITION BY user_id     
    ORDER BY tweet_date     
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
  ,2) AS rolling_avg_3d
FROM tweets;

-- Giải thích 'BETWEEN 2 PRECEDING AND CURRENT ROW': https://stackoverflow.com/questions/56063397/how-to-understand-the-results-of-rows-between-2-preceding-and-current-row

--6.Using the transactions table, identify any payments made at the same merchant with the same credit card for the same amount within 10 minutes of each other. Count such repeated payments.

WITH table1 AS
(SELECT merchant_id,credit_card_id,amount,transaction_timestamp,
lag(transaction_timestamp) OVER(PARTITION BY merchant_id,credit_card_id,amount) AS pre_transaction_timestamp,
EXTRACT(EPOCH FROM ((transaction_timestamp-(lag(transaction_timestamp) OVER(PARTITION BY merchant_id,credit_card_id,amount)))/60)) as dif_time
FROM transactions)

SELECT COUNT(dif_time) as payment_count
FROM table1 
WHERE dif_time<=10

--Giải thích: EXTRACT(EPOCH FROM...) = đổi kiểu dữ liệu interval sang dạng số dễ nhìn hơn --> float, sử dụng extract kết hợp epoch (https://www.linkedin.com/pulse/lam-quen-v%C6%A1i-x%C6%B0-ly-d%C6%B0-li%C3%AAu-th%C6%A1i-gian-b%C4%83ng-sql-tram-ng)


--7. write a query to identify the top two highest-grossing products within each category in the year 2022. The output should include the category, product, and total spend.

WITH product_retail AS 
(SELECT category, product,sum(spend) as total_spend,
(RANK() OVER (
PARTITION BY category
ORDER BY sum(spend) DESC))AS ranking
FROM product_spend
WHERE EXTRACT( 'year' FROM transaction_date) =2022
GROUP BY category, product)

SELECT category, product,total_spend FROM product_retail
WHERE ranking<=2

--8.Write a query to find the top 5 artists whose songs appear most frequently in the Top 10 of the global_song_rank table. Display the top 5 artist names in ascending order, along with their song appearance ranking.

With top10 AS
(SELECT a1.artist_name,
DENSE_RANK() OVER (
ORDER BY COUNT(a2.song_id) DESC) AS artist_rank
FROM artists as a1
join songs as a2 on a1.artist_id=a2.artist_id
join global_song_rank as a3 on a2.song_id=a3.song_id
WHERE a3.rank<=10
GROUP BY a1.artist_name)

SELECT artist_name,artist_rank FROM top10
WHERE artist_rank<=5
ORDER BY artist_rank
