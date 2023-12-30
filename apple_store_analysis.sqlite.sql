
--I am are tasked with doing data analysis on the apple store apps to help find stakeholders info into what
--best avenue to take when designing an app based on feedback from reviews of apps currently in the apple store


CREATE TABLE applestore_description_combined AS

SELECT * FROM appleStore_description1

UNION ALL

SELECT * FROM appleStore_description2

UNION ALL

SELECT * FROM appleStore_description3

UNION ALL

SELECT * FROM appleStore_description4


** EXPLORATORY DATA ANALYSIS **

--check the number of unique apps in both tablesAppleStore

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM AppleStore

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM applestore_description_combined

--CHECK for any missing values in key fieldsAppleStore
SELECT COUNT(*) AS MissingValues
FROM AppleStore
WHERE track_name IS null OR user_rating IS null OR prime_genre IS NULL

SELECT COUNT(*) AS MissingValues
FROM applestore_description_combined
WHERE app_desc IS null

--Find out the number of apps per genreAppleStore
SELECT prime_genre, COUNT(*) AS NumApps
FROM AppleStore
GROUP BY prime_genre
ORDER BY NumApps DESC

--Get an overview of the apps' ratings
SELECT min(user_rating) AS MinRating,
	   max(user_rating) as MaxRating,
       avg(user_rating) as AvgRating
FROM AppleStore

**DATA ANALYSIS**

-- 1. Determine whether paid apps have higher ratings than free apps
SELECT CASE
			WHEN price > 0 THEN 'paid'
            ELSE 'free'
        End AS App_Type,
        avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY App_Type

-- We Can see that paid apps are rated slightly higher (3.72) than free apps (3.38)

--2. Check if apps with mopre supported languages have higher ratings
SELECT CASE
			WHEN lang_num < 10 THEN '<10 languages'
            WHEN lang_num BETWEEN 10 and 30 THEN '10-30 languages'
            ELSE '>10 languages'
       END AS language_bucket,
       avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY language_bucket
ORDER BY Avg_Rating DESC

--Apps supported in more languages tend to have higher ratings. 10-30 languages (4.13) More than 10 languages (3.78) less than 10 languages (3.37)

--Check genre with low ratings
SELECT prime_genre,
	   avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY prime_genre
ORDER BY Avg_Rating ASC
LIMIT 10
--The 3 categorys with the lowest reviews were Catalogs, Finance and Book. There Miight be possibility to design an app that functions better than other already in app store

--Check if there is correlation between the length of the app description and the user ratingAppleStore
SELECT CASE
			WHEN length(b.app_desc) < 500 THEN 'short'
            WHEN length(b.app_desc) BETWEEN 500 and 1000 then 'Medium'
            ELSE 'Long'
         END AS description_length_bucket,
         avg(a.user_rating) AS average_rating
	
FROM
	AppleStore as a 
JOIN 
	applestore_description_combined as b 
ON
	a.id = b.id
GROUP BY description_length_bucket
ORDER by average_rating DESC 
--Based on this query. The longer the description the better the average rating on the apple store 

--3. Check the top-rated apps for each genre 

SELECT 
	prime_genre,
    track_name,
    user_rating
FROM (
  	  SELECT
  	  prime_genre,
      track_name,
      user_rating,
      RANK() OVER(PARTITION by prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS rank
  	  FROM
  	  AppleStore
    ) as a 
WHERE
a.rank = 1
--This shows the top ranked app in each genre. These are what they should try to emulate. 


**ANALYSIS FINDINGS**
--1. Paid apps have better ratings 
--2. Apps supporting between 10 and 30 languages have better ratings 
--3. Catalogs, Finance and Book apps have low ratings 
--4. Apps with a longer description have better ratings 
--5. A new app should aim for an average rating above 3.5 
--6. Games and entertainment have high comepetiton.