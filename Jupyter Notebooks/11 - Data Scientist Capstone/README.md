# Capstone Project - Sparkify #
The **Udacity-Data-Scientist-Nanodegree** repository contains all material related to this Nanodegree program. This particular directory is dedicated to the project "Sparkify Capstone Project".

## Contents of the Directory ##
 - **Sparkify_Bunn_v1.ipynb** is the Jupyter Notebook containing all of the Python code for this project. The code is meant as an initial **experiment** involving **exploring**, **cleaning**, **feature engineering**, and **testing ML algorithms** *via* various **Spark** libraries. In a second phase - after submitting my work in the context of the final Term 2 Capstone Project - I'll refactor the code with classes and methods and migrate it to an **S3** or **IBM Watson** **cluster**.

The Python and Spark libraries used throughout the Jupyter Notebook are:
   - **pandas**
   - matplotlib.**pyplot**
   - pyspark.**SparkConf**
   - pyspark.sql.**SparkSession**
   - pyspark.sql.functions.**count**, **countDistinct**, **col**, **date_format**, **desc**, **isnan**, **max**, **mean**, **min**, **round**, **split**, **sum**, **udf**
   - pyspark.sql.**Window**
   - pyspark.ml.**Pipeline**
   - pyspark.ml.feature.**StandardScaler**, **OneHotEncoderEstimator**, **StringIndexer**, **VectorAssembler**
   - pyspark.sql.types.**IntegerType**
   - pyspark.ml.stat.**Summarizer**
   - pyspark.ml.classification.**LogisticRegression**, **DecisionTreeClassifier**, **RandomForestClassifier**, **GBTClassifier**
   - pyspark.ml.evaluation.**MulticlassClassificationEvaluator**
   - pyspark.ml.tuning.**CrossValidator**, **ParamGridBuilder**
 - **Sparkify_Bunn_v1.html** for visualizing the Jupyter Notebook *via* a simple browser.

## Definition ##
This **Capstone Project** is inspired from the extracurricular [Capstone Content - Spark](https://classroom.udacity.com/nanodegrees/nd025/parts/3e1c3447-39e1-476e-a5f3-8822fa52f9a3) course.

The goal is to familiarize onself with the **[Apache Sparks](https://spark.apache.org/) Analytics Engine for Large-Scale Data Processing** through the development of a **Churn Prediction** engine. In the context of a fictitious **Sparkify** music streaming online service, the task is to prevent churning (*e.g.*, users downgrading or cancelling the service) by analyzing users' behavior. It's a case of **Supervised Learning**.

## Analysis ##
The Jupyter Notebook **Sparkify_Bunn_v1.ipynb** is organized in the following sections:
- **Loading and Cleaning the Dataset**: for the purpose of initially running the Jupyter Notebook on a local machine, the dataset is a 128 MB subset of a 12 GB dataset available in AWS. The JSON file contained records devoid of any user ID - useless for the purpose of analyzing user behavior - which I removed, as well as other features I did not intend to make use of initially.
- **Exploratory Data Analysis** was performed on the remaining features, to validate their potential use as **predictors** of **churn**, including using **histograms** for comparing **churning** and **loyal** (*i.e.*, non-churning) users' behaviors; plotted features include but are not limited to **tasks performed**, **gender**, **time/day**, etc.
- **Feature Engineering**: created aggregate features by session and then by user, one-hot encoding categorical features, scaling numeric features, and vectorizing all, which resulted in a 2-column Spark DataFrame with the **churn/no-churn** **'*label*'** and the **vector** **'*features*'**.
- **Modeling**: tested 4 **Machine Learning** algorithms using Grid-Search Cross-Validation (sort of... wrote the code but kept default values for local PC performance reasons):
    - **Linear Regression**
    - **Decision Tree**
    - **Random Forest**
    - **Gradient Boosted Tree**

## Conclusion ##
**Linear Regression** yielded an **F1 score** of **90 %** on the **test** data and **85 %** on the **validation** data, which is pretty good. But the results of the other 3 models seems too good to be true and identical: **98 %** on the **test** data and **97 %** on the **validation** data! Working with the large dataset in a **cluster** should help me figure out if these results are legitimate and reproducible with much more data or if there's something *fishy* with my code...

## Related Blog Post ##
The findings of the analysis contained in the Jupyter Notebook are the subject of a blog post on Medium: [???](https://medium.com/@gers32/???).
