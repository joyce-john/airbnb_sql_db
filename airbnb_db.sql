-- ####################################################
-- ###########		LOADING DATA	 ##################
-- ####################################################

-- create and use the schema
DROP SCHEMA IF EXISTS airbnb;
CREATE SCHEMA airbnb;
USE airbnb;

-- create table for listings, which has 92 columns
-- later add primary key: id
DROP TABLE IF EXISTS listings;

-- columns marked with a * comment require a SET COLUMN = NULLIF(@VAR = '') statement + a @v_column variable import...
-- ...during the LOAD DATA IN FILE call to deal with missing values
CREATE TABLE listings
(id INT,
listing_url VARCHAR(255),
scrape_id BIGINT,
last_scraped DATE,
name VARCHAR(255),
summary MEDIUMTEXT,
space MEDIUMTEXT,
description MEDIUMTEXT,
experiences_offered TEXT,
neighborhood_overview TEXT,
notes TEXT,
transit TEXT,
thumbnail_url TEXT,
medium_url TEXT,
picture_url TEXT,
xl_picture_url TEXT,
host_id BIGINT,
host_url TEXT,
host_name VARCHAR(255),
host_since DATE, -- *
host_location VARCHAR(255),
host_about TEXT,
host_response_time VARCHAR(255),
host_response_rate VARCHAR(5), -- due to entries such as "N/A"
host_acceptance_rate VARCHAR(5), -- due to entries such as "N/A"
host_is_superhost VARCHAR(1),
host_thumbnail_url TEXT,
host_picture_url TEXT,
host_neighbourhood VARCHAR(255),
host_listings_count INT, -- *
host_total_listings_count INT, -- *
host_verifications TEXT,
host_has_profile_pic VARCHAR(1),
host_identity_verified VARCHAR(1),
street VARCHAR(255),
neighbourhood VARCHAR(255),
neighbourhood_cleansed VARCHAR(255),
neighbourhood_group_cleansed VARCHAR(255),
city VARCHAR(255),
state VARCHAR(255),
zipcode VARCHAR(255),
market VARCHAR(255),
smart_location VARCHAR(255),
country_code VARCHAR(255),
country VARCHAR(255),
latitude DOUBLE, 
longitude DOUBLE, 
is_location_exact VARCHAR(1),
property_type VARCHAR(255),
room_type VARCHAR(255),
accommodates INT,
bathrooms DOUBLE, -- DOUBLE to allow for values like 3.5 *
bedrooms INT, -- *
beds INT, -- *
bed_type VARCHAR(255),
amenities TEXT,
square_feet INT, -- *
price DECIMAL(10,2), -- *
weekly_price DECIMAL(10,2), -- *
monthly_price DECIMAL(10,2), -- *
security_deposit DECIMAL(10,2), -- *
cleaning_fee DECIMAL(10,2), -- *
guests_included INT,
extra_people DECIMAL(10,2), -- *
minimum_nights INT,
maximum_nights INT,
calendar_updated VARCHAR(255),
has_availability VARCHAR(1),
availability_30 INT,
availability_60 INT,
availability_90 INT,
availability_365 INT,
calendar_last_scraped DATE,
number_of_reviews INT,
first_review DATE, -- *
last_review DATE,  -- *
review_scores_rating INT, -- *
review_scores_accuracy INT, -- *
review_scores_cleanliness INT, -- *
review_scores_checkin INT, -- *
review_scores_communication INT, -- *
review_scores_location INT, -- *
review_scores_value INT, -- *
requires_license VARCHAR(1),
license VARCHAR(255),
jurisdiction_names VARCHAR(255),
instant_bookable VARCHAR(1),
cancellation_policy VARCHAR(255),
require_guest_profile_picture VARCHAR(1),
require_guest_phone_verification VARCHAR(1),
calculated_host_listings_count INT,
reviews_per_month DECIMAL(10,2)); -- *


-- load data into listings table
-- for PRICE columns, the logic works like this: IF it is a missing value, THEN NULL or 0, ELSE use SUBSTRING to truncate the "$", and REPLACE to remove any commas, and CAST to decimal
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\listings.csv'
INTO TABLE listings
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' -- some user-submitted text contains commas
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id,listing_url,scrape_id,last_scraped,name,summary,space,description,experiences_offered,neighborhood_overview,notes,transit,thumbnail_url,medium_url,picture_url,xl_picture_url,host_id,host_url,host_name,@v_host_since,host_location,host_about,host_response_time,host_response_rate,host_acceptance_rate,host_is_superhost,host_thumbnail_url,host_picture_url,host_neighbourhood,@v_host_listings_count,@v_host_total_listings_count,host_verifications,host_has_profile_pic,host_identity_verified,street,neighbourhood,neighbourhood_cleansed,neighbourhood_group_cleansed,city,state,zipcode,market,smart_location,country_code,country,latitude,longitude,is_location_exact,property_type,room_type,accommodates,@v_bathrooms,@v_bedrooms,@v_beds,bed_type,amenities,@v_square_feet,@v_price,@v_weekly_price,@v_monthly_price,@v_security_deposit,@v_cleaning_fee,guests_included,@v_extra_people,minimum_nights,maximum_nights,calendar_updated,has_availability,availability_30,availability_60,availability_90,availability_365,calendar_last_scraped,number_of_reviews,@v_first_review,@v_last_review,@v_review_scores_rating,@v_review_scores_accuracy,@v_review_scores_cleanliness,@v_review_scores_checkin,@v_review_scores_communication,@v_review_scores_location,@v_review_scores_value,requires_license,license,jurisdiction_names,instant_bookable,cancellation_policy,require_guest_profile_picture,require_guest_phone_verification,calculated_host_listings_count,@v_reviews_per_month
)
SET 
host_since = NULLIF(@v_host_since, ''),
host_listings_count = NULLIF(@v_host_listings_count, ''),
host_total_listings_count = NULLIF(@v_host_total_listings_count, ''),
bathrooms = NULLIF(@v_bathrooms, ''),
bedrooms = NULLIF(@v_bedrooms, ''),
beds = NULLIF(@v_beds, ''),
square_feet = NULLIF(@v_square_feet, ''),
price = IF(@v_price = '', NULL,  CAST(REPLACE(SUBSTRING(@v_price, 2), ",", "") AS DECIMAL(10,2))), 
weekly_price = IF(@v_weekly_price = '', NULL,  CAST(REPLACE(SUBSTRING(@v_weekly_price, 2), ",", "") AS DECIMAL(10,2))),
monthly_price = IF(@v_monthly_price = '', NULL,  CAST(REPLACE(SUBSTRING(@v_monthly_price, 2), ",", "") AS DECIMAL(10,2))),
security_deposit = IF(@v_security_deposit = '', 0,  CAST(REPLACE(SUBSTRING(@v_security_deposit, 2), ",", "") AS DECIMAL(10,2))),
cleaning_fee = IF(@v_cleaning_fee = '', 0,  CAST(REPLACE(SUBSTRING(@v_cleaning_fee, 2), ",", "") AS DECIMAL(10,2))),
extra_people = IF(@v_extra_people = '', NULL,  CAST(REPLACE(SUBSTRING(@v_extra_people, 2), ",", "") AS DECIMAL(10,2))),
first_review = NULLIF(@v_first_review, ''),
last_review = NULLIF(@v_last_review, ''),
review_scores_rating = NULLIF(@v_review_scores_rating, ''),
review_scores_accuracy = NULLIF(@v_review_scores_accuracy, ''),
review_scores_cleanliness = NULLIF(@v_review_scores_cleanliness, ''),
review_scores_checkin = NULLIF(@v_review_scores_checkin, ''),
review_scores_communication = NULLIF(@v_review_scores_communication, ''),
review_scores_location = NULLIF(@v_review_scores_location, ''),
review_scores_value = NULLIF(@v_review_scores_value, ''),
reviews_per_month = NULLIF(@v_reviews_per_month, '')
;


-- create reviews table
-- later add foreign key "listing_id" which refers to listings table "id" column
DROP TABLE IF EXISTS reviews;

CREATE TABLE reviews
(listing_id INT,
id INT,
date DATE,
reviewer_id INT,
reviewer_name VARCHAR(255),
comments TEXT);

-- load reviews data into table
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\reviews.csv'
INTO TABLE reviews
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' -- some user-submitted text contains commas
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(listing_id,id,date,reviewer_id,reviewer_name,comments);


-- create calendar table
-- later add foreign key "listing_id" which refers to listings table "id" column
DROP TABLE IF EXISTS calendar;

CREATE TABLE calendar
(listing_id INT,
date DATE,
available VARCHAR(1),
price DECIMAL(10,2));

-- load data into calendar table, this could take a little while (10-20 seconds on my laptop)
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\calendar.csv'
INTO TABLE calendar
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(listing_id,date,available,@v_cal_price)
SET price = IF(@v_cal_price = '', NULL,  CAST(REPLACE(SUBSTRING(@v_cal_price, 2), ",", "") AS DECIMAL(10,2)));


-- setting keys for the tables
-- WARNING: this is slow, could take 2+ minutes
ALTER TABLE listings ADD CONSTRAINT pk_listings PRIMARY KEY (id); 
ALTER TABLE reviews ADD CONSTRAINT fk_reviews FOREIGN KEY (listing_id) REFERENCES listings (id);
ALTER TABLE calendar ADD CONSTRAINT fk_calendar FOREIGN KEY (listing_id) REFERENCES listings (id); -- this is the slow part


-- ####################################################
-- ###########			E T L 		 ##################
-- ####################################################

-- the ETL is a stored procedure
-- I create 3 temporary tables and join them in steps, because I don't know how to create the warehouse in one step...
-- ...with the aggregation I want to perform on calendar and reviews

DROP PROCEDURE IF EXISTS make_property_stats;

Delimiter //

CREATE PROCEDURE make_property_stats()
BEGIN

-- temporary table for listings, SELECTS only the useful columns
DROP TABLE IF EXISTS temp_listings;
CREATE TABLE temp_listings AS 
SELECT 
	id,
    name,
    neighbourhood_cleansed,
    property_type,
    room_type,
    accommodates,
    price AS nightly_price,
    weekly_price,
    monthly_price,
    cleaning_fee,
    guests_included,
    extra_people,
    review_scores_rating 
FROM listings;

-- temporary table for calendar, transform availability and price stats into aggregate measures for the whole year
-- GROUP BY aggregates by listing_id (specific identifier for each property)
-- aggregation reduces number of rows from 1.4m to manageable 3.8k
DROP TABLE IF EXISTS temp_calendar;
CREATE TABLE temp_calendar AS
SELECT
	 listing_id,
     ROUND(SUM(available = 't')/COUNT(available), 2) AS avg_availability, 
     ROUND(SUM(price)/COUNT(price), 2) AS avg_observed_price 
FROM calendar 
GROUP BY listing_id;

-- temporary table for reviews, transform reviews into a measure of the length of the review text, count the number of reviews
-- GROUP BY aggregates by the listing_id (specific identifier for each property)
-- aggregation reduces number of rows from 150k to about 3.1k
DROP TABLE IF EXISTS temp_reviews;
CREATE TABLE temp_reviews AS
SELECT
	  listing_id, 
      ROUND(AVG(length(comments)), 2) AS avg_review_length, 
      COUNT(comments) AS number_reviews 
FROM reviews 
GROUP BY listing_id;


-- #################	 DATA WAREHOUSE 	 ###################

-- this creates the data warehouse by joining the three temporary tables
DROP TABLE IF EXISTS property_stats;
CREATE TABLE property_stats AS
SELECT * FROM temp_listings
LEFT JOIN temp_calendar ON temp_listings.id = temp_calendar.listing_id
LEFT JOIN temp_reviews USING(listing_id);

-- drop a the listing_id column which was used for joining, but is now useless
ALTER TABLE property_stats
DROP COLUMN listing_id;

-- drop temporary tables
DROP TABLE IF EXISTS temp_listings;
DROP TABLE IF EXISTS temp_calendar;
DROP TABLE IF EXISTS temp_reviews;

END //
DELIMITER ;

-- call the stored procedure to generate the data warehouse
CALL make_property_stats();



-- #################################################################
-- #################			DATA MARTS 		 ###################
-- #################################################################


-- neighborhood analysis describes how profitable each neighborhood is
-- "average expected annual rent" is a basic prediction of revenue: (number of nights booked) * (average price throughout the year)
DROP VIEW IF EXISTS neighborhood_analysis;
CREATE VIEW neighborhood_analysis AS
SELECT 
	neighbourhood_cleansed AS neighborhood, 
	ROUND(AVG(avg_observed_price), 2) AS avg_observed_price,
	ROUND(AVG(review_scores_rating), 2) AS avg_rating,
    ROUND(AVG(365 - (avg_availability * 365))) AS avg_nights_booked,
    ROUND(AVG(365 - (avg_availability * 365)) * AVG(avg_observed_price)) AS avg_expected_annual_rent
FROM property_stats
GROUP BY neighbourhood_cleansed
ORDER BY avg_expected_annual_rent DESC;

-- use the view to examine all neighborhoods
SELECT * FROM neighborhood_analysis;


-- popular_properties shows the most popular properties based on the number of reviews
-- it only considers properties which are available less than 70% of the year and have more than 50 reviews
DROP VIEW IF EXISTS popular_properties;
CREATE VIEW popular_properties AS
SELECT 
	id,
	name, 
    neighbourhood_cleansed AS neighborhood, 
    property_type, 
    avg_availability, 
    number_reviews
FROM property_stats
WHERE avg_availability < 0.7 AND number_reviews > 50
ORDER BY number_reviews DESC;

-- use the view to see which properties are popular
SELECT * FROM popular_properties;


-- value_for_groups find properties that may interest a large group traveling together
-- it calculates the price for each person after all fees
-- this view uses the most recent listed price "nightly_price" so the view can be used for making current recommendations
DROP VIEW IF EXISTS value_for_groups;
CREATE VIEW value_for_groups AS
SELECT
	id,
	name,
	accommodates,
	nightly_price, 
	cleaning_fee,
	guests_included,
	extra_people,
	ROUND((nightly_price + ((accommodates - guests_included) * extra_people) + (cleaning_fee))/accommodates, 2) AS price_per_person_per_night
FROM property_stats
ORDER BY price_per_person_per_night ASC;

-- use the view with WHERE accommodates = ... to find properties that offer strong value to groups of that size
SELECT * FROM value_for_groups WHERE accommodates = 10;




