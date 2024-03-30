CREATE TABLE appleStore_description_combined as 

SELECT * FROM appleStore_description1

UNION ALL

SELECT * FROM appleStore_description2 

UNION ALL 

SELECT * FROM appleStore_description3

UNION ALL 

** Exploratory Data Analysis**

-- Check the number of unique apps in both tablesAppleStore

SELECT COUNT(DISTINCT id) as UniqueAppIDs
FROM AppleStore

SELECT COUNT(DISTINCT id) as UniqueAppIDs
FROM appleStore_description_combined

-- Check for any missing values in key Fields

SELECT COUNT(*) as MissingValues
FROM AppleStore
WHERE track_name is NULL or user_rating is NULL or prime_genre is NULL

SELECT COUNT(*) as MissingValues
FROM appleStore_description_combined
WHERE app_desc is NULL

-- Find out the number of Apps per genre

SELECT prime_genre, COUNT(*) as NumApps
FROM AppleStore
GROUP by prime_genre
order by NumApps DESC

-- Get an overview of the app's rating AppleStore

SELECT min(user_rating) as MinRating,
	   max(user_rating) as MaxRating,
       avg(user_rating) as Avgrating
FROM AppleStore


-- Get the distribution of app prices 

SELECT 
	(price / 2)	* 2 as PriceBinStart,
    ((price / 2) * 2) +2 as PriceBinEnd,
    COUNT(*) as NumApps
FROM AppleStore
GROUP by PriceBinStart
ORDER by PriceBinStart 

** Data Analysis**

-- Determine weather paid apps have higher ratings than free apps

SELECT CASE 
			WHEN price > 0 THEN 'Paid'
            ELSE 'Free'
       END as App_Type,
       avg(user_rating) as Avg_Rating
FROM AppleStore 
GROUP by App_Type

-- Check if apps with more supported languages have higher rating

SELECT case 
			WHEN lang_num < 10 THEN '<10 languages'
            WHEN lang_num BETWEEN 10 AND 30 THEN '10-30 languages'
            ELSE '>30 languages'
       END as language_bucket,
       avg(user_rating) as Avg_Rating
FROM AppleStore
GROUP by language_bucket
ORDER by Avg_Rating DESC

-- Check genre with low ratings 

SELECT prime_genre,
	   avg(user_rating) as Avg_Rating
FROM AppleStore 
GROUP by prime_genre 
ORDER by Avg_Rating ASC
LIMIT 10

--- Check if there is Correlation between the length of the app description and the user Rating

SELECT CASE 
			when length(b.app_desc) <500 THEN 'Short'
            when length(b.app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
            ELSE 'Long'
       END as description_length_bucket,
       avg(user_rating) as Avg_Rating
FROM 
	 AppleStore as a 
JOIN 
	 appleStore_description_combined as b
    
on 
	 a.id = b.id 
     
GROUP by description_length_bucket
ORDER by Avg_Rating desc


---- Check the top-rated apps for each genre

SELECT 
	prime_genre,
    track_name,
    user_rating
FROM (
  		SELECT 
  			prime_genre,
  			track_name,
  			user_rating,
  			RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS rank
  			FROM 
  			AppleStore
  		) as a 
 WHERE a.rank = 1 
