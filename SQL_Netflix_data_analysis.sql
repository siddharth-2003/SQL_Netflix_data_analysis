--Netflix Project
create table netflix_db (
	show_id varchar(10) primary key,	
	type varchar(20),	
	title varchar(250),	
	director varchar(550),	
	cast_ varchar(1050),	
	country varchar(550),	
	date_added varchar(55),	
	release_year int,	
	rating varchar(15),	
	duration varchar(15),	
	listed_in varchar(250),	
	description varchar(550)

);

--1. Count the number of Movies vs TV Shows
select type,count(title) as number_of_title
from netflix_db
group by 1;

--2. Find the most common rating for movies and TV shows
with ratingcount as (
select
		type,
		rating,
		count(rating) as rating_count,
		rank() over (partition by type order by count(rating) desc) as ranking
		from netflix_db
		group by type, rating
)
select 
	type,
	rating,
	rating_count
from ratingcount
where ranking = 1;

--3. List all movies released in a specific year (e.g., 2020)
select title
from netflix_db
where type = 'Movie' and release_year = '2020';

--4. Find the top 5 countries with the most content on Netflix
select country,count(*)
from netflix_db
where country is not null
group by country
order by 2 desc
limit 5;

--5. Identify the longest movie
select title, cast(replace(duration,'min','') as integer) as duration_minutes
from netflix_db
where type = 'Movie'
and duration is not null
order by duration_minutes desc
limit 1;

--6. Find content added in the last 5 years
select title, date_added
from netflix_db
where to_date(date_added,'Month DD, YYYY') >= current_date - interval '5 years';

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'
select *
from netflix_db
where director ilike '%Rajiv Chilaka%';

--8. List all TV shows with more than 5 seasons
select title
from netflix_db
where 
	type = 'TV Show' and
	split_part(duration,' ',1):: numeric > 5;

--9. Count the number of content items in each genre
select 
	unnest(string_to_array(listed_in,',')) as genre,
	count(show_id)
from netflix_db
group by 1;

--10.Find each year and the average numbers of content release in India on netflix. 
select  
	Extract( year from TO_DATE(date_added, 'Month DD,YYYY'))as year, 
	round(count(*):: numeric/(select count(*) from netflix_db where country='India')*100) as average
from netflix_db 
where country = 'India'
group by 1;

--11. List all movies that are documentaries
select title,listed_in
from netflix_db
where type = 'Movie' and listed_in like '%Documentaries%';

--12. Find all content without a director
select title, cast_,country,rating
from netflix_db
where director is null;
--13. Find how many times movies actor 'Salman Khan' appeared in last 10 years
select count(*)
from netflix_db
where cast_ like '%Salman Khan%'
	and TO_DATE(date_added, 'Month DD,YYYY') <= current_date - 10;

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India
select unnest(string_to_array(cast_,',')) as actors, count(title) as no_of_title
from netflix_db
where country = 'India' and cast_ is not null
group by 1
order by 2 desc
limit 10;

--15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.

with new_table as
(
	select *, case when description ilike '%kill%' or description ilike '%violence%' then 'Bad' 
			else 'Good'
			end as category
			from netflix_db
			
)
select category, type, count(*) as total_count
from new_table
group by 1,2 
order by 2 desc;






