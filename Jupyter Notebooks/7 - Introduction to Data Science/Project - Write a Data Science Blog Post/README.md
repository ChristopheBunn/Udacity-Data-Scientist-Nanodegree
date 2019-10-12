# Project - Write a Data Science Blog Post #
The **Udacity-Data-Scientist-Nanodegree** repository contains all material related to this Nanodegree program. This particular directory is dedicated to the project "Write a Data Science Blog Post".

## Contents of the Directory ##
 - **Airbnb_Bordeaux_Lyon_Paris.ipynb** is the Jupyter Notebook containing all of the Python code for this project. For the sake of simplicity and because I've already missed the *soft deadline* by 3 weeks (!), I didn't originally include classes or functions. I would of course use these extensively in a less "hurried" context. But in response to feedback from the Udacity reviewer, I ended up creating function **random_search_cross_validation()** and incorporating the standard **document strings**.
 The Python libraries used throughout the Jupyter Notebook are:
   - **numpy**
   - **pandas**
   - sklearn.preprocessing.**MinMaxScaler**
   - sklearn.linear_model.**LinearRegression**
   - sklearn.ensemble.**RandomForestRegressor**
   - sklearn.model_selection.**train_test_split**
   - sklearn.model_selection.**RandomizedSearchCV**
   - sklearn.metrics.**r2_score**
   - matplotlib.**pyplot**
   - matplotlib.**dates**
   - **datetime**
   - pprint.**pprint**
 - **Airbnb_Bordeaux_Lyon_Paris_20191012.html** for visualizing the Jupyter Notebook *via* a simple browser.

## Motivation ##
This project being *"sponsored"* by **Airbnb**, I find it respectful to use the data that they have provided.  
Because I live in France, I decided to analyze Airbnb data for 3 French cities: **Bordeaux** (South-West, near the Atlantic Ocean), **Lyon** (East, near the Alps and Switzerland), and **Paris** (North, the capital). The data inspired me to ask the following questions:
1. Although all 3 cities are among the largest in the country, they differ a lot; is there a difference in the **price distribution** of Airbnb offerings?
2. Are **seasonal price fluctuations** different from one city to the other?
3. What are the **features** that **influence** the most the **price** of an Airbnb offering?

## Summary of the Results ##
For the 3 questions above, I was able to draw the following initial conclusions (obviously, there's much more I can do to dig deeper into the subject area):
1. In the **<= $ 500** range, which corresponds to the huge majority of listings offered, there's no detectable difference in the **price distribution**: the somewhat **Gaussian distributions** are almost exaclty stacking for all 3 cities. In the **> $ 500** range, Paris has more offerings, which makes sense since it receives many more tourists and ofers more high-end accomodations.
2. **Seasonal prices** fluctuate in the same way for all 3 cities with a peak around the **winter holiday season**, but **Paris** has an additional busy period throughout the **end-of summer** and the **fall**. I attribute this to the flow of retired and childless tourists that tend to travel off-season.
3. A **Random Forest** model was able to pinpoint two major **features** which have the **greatest influence** over **prices**. They are logically **location** and **type of accomodation**. The data was able to confirm the intuition.

## Related Blog Post ##
The findings of the analysis contained in the Jupyter Notebook are the subject of a blog post on Medium: [Parlez-vous CRISP-DM ?](https://medium.com/@gers32/parlez-vous-crisp-dm-ab3484fc1b02).
