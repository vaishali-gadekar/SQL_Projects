CREATE TABLE amazon_titles(show_id varchar,
						   amazon_type varchar,
						   title varchar,
						   director varchar,
						   amazon_cast varchar,
						   country varchar,
						   date_added date,
						   year_of_release varchar,
						   imdb_rating varchar,
						   duration varchar,
						   genre varchar,
						   description varchar)
						   
drop table amazon_titles
						   
copy amazon_titles from 'C:\Users\sagar\Desktop\SQL\Amazon Data\amazon_prime_titles.csv' with csv header

select * from amazon_titles

CREATE TABLE amazon_movies(movie_name varchar,
						   language varchar,
						   imdb_rating varchar,
						   running_time varchar,
						   year_of_release varchar,
						   maturity_rating varchar,
						   plot varchar)
						  
drop table amazon_movies
						   
copy amazon_movies from 'C:\Users\sagar\Desktop\SQL\Amazon Data\amazon prime movies.csv' with csv header

select * from amazon_movies

CREATE TABLE amazon_shows(serial_no int,
						  show_name varchar,
						  year_of_release varchar,
						  no_of_seasons int,
						  language varchar,
						  genre varchar,
						  imdb_rating float,
						  viewers_age varchar)
						  
copy amazon_shows from 'C:\Users\sagar\Desktop\SQL\Amazon Data\Prime TV Shows.csv' with csv header

select * from amazon_shows

/* Row count */
SELECT COUNT(*) FROM amazon_titles AS row_count
SELECT COUNT(*) FROM amazon_movies AS row_count
SELECT COUNT(*) FROM amazon_shows AS row_count

/* Check Table Information */
SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = 'amazon_titles'

SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = 'amazon_movies'

SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = 'amazon_shows'

/* checking null values */
SELECT * FROM amazon_titles
WHERE (SELECT column_name FROM information_schema.columns
WHERE table_name = 'amazon_titles') = NULL

SELECT * FROM amazon_movies
WHERE (SELECT column_name FROM information_schema.columns
WHERE table_name = 'amazon_movies') = NULL

SELECT * FROM amazon_shows
WHERE (SELECT column_name FROM information_schema.columns
WHERE table_name = 'amazon_shows') = NULL

/* Data Cleaning */
UPDATE amazon_movies
SET imdb_rating = CASE WHEN TRIM(imdb_rating) = 'none' THEN NULL 
                       ELSE CAST(TRIM(imdb_rating) AS FLOAT) END
WHERE TRIM(imdb_rating) NOT IN ('None', '')

ALTER TABLE amazon_movies
ALTER COLUMN imdb_rating :: numeric

UPDATE amazon_movies
SET imdb_rating = '0'
WHERE imdb_rating = 'none'

UPDATE amazon_movies
REPLACE (imdb_rating,'none','0') from amazon_movies

select * from amazon_movies


/*Content Analysis*/

/* total count of movies and shows on amazon prime */
SELECT COUNT(*) AS no_of_movies FROM amazon_titles t1
LEFT JOIN amazon_movies t2 ON
t1.title = t2.movie_name
WHERE amazon_type = 'Movie'

SELECT COUNT(*) AS no_of_shows FROM amazon_titles t1
LEFT JOIN amazon_shows t3 ON
t1.title = t3.show_name
WHERE amazon_type = 'TV Show'

/* popular movies and shows (in terms of ratings) */
SELECT show_name, COALESCE(imdb_rating,0) AS imdb_rating, no_of_seasons FROM amazon_shows
ORDER BY imdb_rating DESC
LIMIT 10

SELECT movie_name, CAST(REPLACE(imdb_rating, 'None','0') AS NUMERIC) AS imdb_rating FROM amazon_movies
ORDER BY imdb_rating DESC
LIMIT 10

/* Distribution of TV Shows and Movies varies across different country */
SELECT amazon_type, country, COUNT(*) AS show_count FROM amazon_titles
GROUP BY country, amazon_type
ORDER BY show_count DESC

/* How frequently is the new content added to the amazon prime */
SELECT COUNT(*) AS content_count, ROUND(AVG(year_diff),2) AS average_frequency FROM 
(SELECT CAST(year_of_release AS NUMERIC) - LAG(CAST(year_of_release AS NUMERIC)) OVER (ORDER BY year_of_release) 
AS year_diff
FROM amazon_titles) AS subquery
WHERE year_diff IS NOT NULL

/* No. of yearly released movies and shows */
SELECT t1.amazon_type, t1.year_of_release, COUNT(*) FROM amazon_titles t1
JOIN amazon_movies t2 ON t1.year_of_release = t2.year_of_release
WHERE amazon_type = 'Movie'
GROUP BY t1.amazon_type, t1.year_of_release
ORDER BY year_of_release 

SELECT t1.amazon_type, t1.year_of_release, COUNT(*) FROM amazon_titles t1
JOIN amazon_shows t3 ON t1.year_of_release = t3.year_of_release
WHERE amazon_type = 'TV Show'
GROUP BY t1.amazon_type, t1.year_of_release
ORDER BY year_of_release

/* Movies having maximum and minimum running length */
SELECT * FROM amazon_titles
SELECT * FROM amazon_movies
SELECT * FROM amazon_shows

SELECT movie_name AS max_length_movie, duration AS running_time FROM
(SELECT title AS movie_name, CAST(LEFT(duration, LENGTH(duration) - 3) AS NUMERIC) AS duration 
FROM amazon_titles
WHERE amazon_type = 'Movie'
ORDER BY duration DESC) AS P
LIMIT 1

SELECT movie_name AS max_length_movie, duration AS running_time FROM
(SELECT title AS movie_name, CAST(LEFT(duration, LENGTH(duration) - 3) AS NUMERIC) AS duration 
FROM amazon_titles
WHERE amazon_type = 'Movie' 
ORDER BY duration ASC) AS P
WHERE duration != 0
LIMIT 1

	
/* User Analysis */

/* Which is the target age group on amazon prime */
SELECT maturity_rating, COUNT(*) AS show_count FROM amazon_movies
GROUP BY maturity_rating
ORDER BY show_count DESC

SELECT viewers_age, COUNT(*) AS show_count FROM amazon_shows
GROUP BY viewers_age
ORDER BY show_count DESC

/* Director and Cast Analysis */

/* Which director have highest no. of movies on amazon prime */
SELECT director, COUNT(*) AS no_of_movies FROM amazon_titles
WHERE amazon_type = 'Movie' AND director IS NOT NULL
GROUP BY director
ORDER BY no_of_movies DESC
LIMIT 1

/* Notable directors with highly rated movies */
SELECT t1.director, ROUND(AVG(CAST(REPLACE(t2.imdb_rating, 'None','0') AS NUMERIC)),1) AS imdb_rating 
FROM amazon_titles t1
JOIN amazon_movies t2 ON
t1.title = t2.movie_name
WHERE t1.amazon_type = 'Movie'
GROUP BY director
HAVING COUNT(director) >= 2 AND ROUND(AVG(CAST(REPLACE(t2.imdb_rating, 'None','0') AS NUMERIC)),1) >= 8.0
ORDER BY imdb_rating DESC

/* Notable pairs of cast having highly rated movies */
SELECT amazon_cast, ROUND(AVG(CAST(REPLACE(t2.imdb_rating, 'None','0') AS NUMERIC)),1) AS imdb_rating 
FROM amazon_titles t1
JOIN amazon_movies t2 ON
t1.title = t2.movie_name
WHERE t1.amazon_type = 'Movie'
GROUP BY amazon_cast
HAVING COUNT(amazon_cast) >= 2 AND ROUND(AVG(CAST(REPLACE(t2.imdb_rating, 'None','0') AS NUMERIC)),1) >= 8.0
ORDER BY imdb_rating DESC

/* Which countries having highest representation of shows and movies */
SELECT country, COUNT(*) AS no_of_movies FROM amazon_titles
WHERE amazon_type = 'Movie' AND country IS NOT NULL
GROUP BY country 
ORDER BY no_of_movies DESC
LIMIT 5

SELECT country, COUNT(*) AS no_of_shows FROM amazon_titles
WHERE amazon_type = 'TV Show' AND country IS NOT NULL
GROUP BY country 
ORDER BY no_of_shows DESC
LIMIT 5

/* Highly rated movies and shows in different countries */
WITH ranked_movies AS 
(SELECT t1.country, t2.movie_name, CAST(REPLACE(t2.imdb_rating,'None','0') AS NUMERIC) AS imdb_rating,
ROW_NUMBER() OVER (PARTITION BY t1.country ORDER BY CAST(REPLACE(t2.imdb_rating, 'None', '0') AS NUMERIC) DESC) AS rn
FROM amazon_titles t1
JOIN amazon_movies t2 ON 
t1.title = t2.movie_name)
SELECT country, movie_name, imdb_rating 
FROM ranked_movies
WHERE country IS NOT NULL AND rn = 1
ORDER BY imdb_rating DESC


/* Category Analysis */

/* What are the different category and genre available for movies and shows */
select * from amazon_titles
select * from amazon_movies
select * from amazon_shows

SELECT DISTINCT genre as movie_category FROM amazon_titles
WHERE amazon_type = 'Movie'

SELECT DISTINCT t1.genre AS show_category FROM amazon_titles t1
LEFT JOIN amazon_shows t2 ON
t1.genre = t2.genre
WHERE amazon_type = 'TV Show'

/* Which genre is most prevalent for movies on amazon prime */
SELECT P.genre AS most_prevalent_genre FROM
(SELECT genre, COUNT(*) FROM amazon_titles
WHERE amazon_type = 'Movie'
GROUP BY genre
ORDER BY COUNT(*) DESC
LIMIT 1) AS P
