## Store and Analyze AirBnB Data in MySQL  

This project works with AirBnB data in a MySQL setting:  
+ load several tables about the Seattle AirBnB market into a local MySQL database  
+ create analytical layer with an ETL (data warehouse)  
+ create analytics views for specific topics (data marts)  

The aim of this project is to deliver useful information about the market to the user, who might be an analyst at AirBnB, a property owner in Seattle, or a prospective real estate investor. The database has several data marts (as Views) which serve this purpose.    

### Notes on Running this Code

File paths for loading data are on these lines:
+ **Line 113**: listings.csv
+ **Line 160**: reviews.csv
+ **Line 179**: calendar.csv

Additionally, you may want to comment out this line of code, which can take two minutes to run on a typical laptop.
+ **Line 192**: adding foreign key constraints

### The Data

This project uses the 2016 Seattle AirBnB market using data provided by AirBnB's official Kaggle account. You can view the data at its original source here:

https://www.kaggle.com/airbnb/seattle

The dataset provided by AirBnB contains three tables:

+ **listings** - approximately 3800 unique web listings on the AirBnB, with many details about the properties  
+ **reviews** - approximately 85000 user reviews for those properties, including the full text for each review  
+ **calendar** - approximately 1.4 million observations regarding the price and availability of each property, for each day of the year in 2016  

The database structure is straightforward:

![Database Diagram](/screenshots/ERD_airbnb_seattle.png)


### Analytics Plan

The project creates an analytical layer which can be used for general analysis, and several data marts which answer specific questions.

+ Which neighborhoods are the most profitable? And how much could a property owner expect to earn each year in a specific neighborhood?
+ Which individual properties are the most popular? What are they like?
+ Which properties are appropriate for hosting large groups? (Ex: school trips, family reunions, workplace retreats)  

The analytical layer is created with the following process:  
  
1. The data is loaded into normalized tables. A stored procedure can start the ETL using these tables.
2. The ETL extracts columns which are relevant for analytics into temporary tables.
3. The ETL transforms data from **reviews** and **calendar**. It groups by the **listing_id** (unique identifer for every property) and performs aggregate calculations. This is particularly helpful for **avg_observed_price**, an observation of the average price for a property as it fluctuates through the year. It is also useful for **avg_availability**, which takes 365 TRUE/FALSE observations from the **available** column and transforms them into one, easy-to-use number.

As an example, see this snapshot of the aggregation on **calendars**:

![creation of avg_availability column](/screenshots/ETL_calendar_transform.jpg)


4. The extracted and transformed data is loaded into a data warehouse called **property_stats**.

5. Temporary tables are dropped.

6. Data marts are created as Views from **property_stats**.


Below is a graphical summary of the process:

![analytics_plan](/screenshots/analytics_plan.png)


### Data Mart Examples



The **neighborhood_analysis** view provides key information about the profitability of different neighborhoods in Seattle. One column in the view is **avg_expected_annual_rent**, which is a basic summary calculated from the average number of nights booked and the average price throughout the year. It is sorted by **avg_expected_annual_rent** in descending order, as most users will be interested in finding the most profitable place to run an AirBnB, or seeing how their own property stacks up against other parts of the city.

![neighborhood_analysis](/screenshots/neighborhood_analysis_view.jpg)



The **popular_properties** view provides information about the most popular individual properties in Seattle. Properties included in the view are available less than 70% of the year have a minimum of 50 reviews. The view offers key facts such as the type of property, the neighborhood its located in, and how popular the property is in terms of availability and reviews.

![popular_properties](/screenshots/popular_properties_view.jpg)



The **value_for_groups** view returns properties which are capable of accomodating groups of a particular size. More importantly, it provides an estimate of the cost per person for a one-night stay, including fees (as **price_per_person_per_night**). Groups can offer property owners large nightly rents, but decision-makers for large groups tend to be sensitive to the overall cost of a booking. Landlords with large properties need to consider how much value their property offers a large group compared to the competition.   

Users should run this query with a **WHERE accommodates =** condition to specify their group size.


![value_for_groups_query](/screenshots/value_for_groups_query.jpg)

![value_for_groups_view](/screenshots/value_for_groups_view.jpg)

	



