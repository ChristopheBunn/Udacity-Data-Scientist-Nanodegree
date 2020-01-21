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

The goal is to familiarize oneself with the **[Apache Sparks](https://spark.apache.org/) Analytics Engine for Large-Scale Data Processing** through the development of a **Churn Prediction** engine. In the context of a fictitious **Sparkify** music streaming online service, the task is to predict and to prevent churning (*e.g.*, users downgrading or cancelling the service) by analyzing users' behavior. It's a case of **Supervised Learning**.

## Analysis ##
The Jupyter Notebook **Sparkify_Bunn_v1.ipynb** is organized in the following sections:
- **Loading and Cleaning the Dataset**: for the purpose of initially running the Jupyter Notebook on a local machine, the dataset is a 128 MB subset of a 12 GB dataset available in AWS. The JSON file contained some records devoid of any user ID - useless for the purpose of analyzing user behavior - which I removed, as well as other features I did not intend to make use of initially.
- **Exploratory Data Analysis** was performed on the remaining features, to validate their potential use as **predictors** of **churn**, including using **histograms** for comparing **churning** and **loyal** (*i.e.*, non-churning) users' behaviors; plotted features include but are not limited to **tasks performed**, **gender**, **time/day**, etc.
- **Feature Engineering**: created aggregate features by session and then by user, one-hot encoding categorical features, scaling numeric features, and vectorizing all, which resulted in a 2-column Spark DataFrame with the **churn/no-churn** **'*label*'** and the **vector** **'*features*'**.
- **Modeling**: tested 4 **Machine Learning** algorithms using Grid-Search Cross-Validation (sort of... wrote the code but kept default values for local PC performance reasons):
    - **Linear Regression**
    - **Decision Tree**
    - **Random Forest**
    - **Gradient Boosted Tree**

## Conclusion ##
### Final Results ###
**Linear Regression** yielded an **F1 score** of **90 %** on the **test** data and **85 %** on the **validation** data, which is very good. The results of the 3 **Tree-based** models are even better, but oddly identical: **98 %** on the **test** data and **97 %** on the **validation** data! I look forward to working with the full dataset in a Spark cluster to figure out if these results are reproducible with much more data. Indeed, I feature-engineered the dataset down to only 225 records (*i.e.*, individual users), which is clearly not very many, especially considering that only 141 of those are used for training, 50 for testing, and 34 for validation.

One possible explanation for the matching F1 scores could be the fact that all 3 algorithms are tree-based and Decision Tree and Random Forest share the same hyper-parameter values.
### Reflection ###
Using Spark for Machine Learning instead of scikit-learn that I'm more familiar with was a challenge. Data cleaning and exploration are rather straightforward, but I found feature engineering much more difficult to master. Vectorization in particular can be off-setting, in particular due to the inability at this point to interpret the data. This requires that the data has been thoroughly understood during the previous phases.

The Machine Learning phase of this entire project only took maybe 5 % of my time, in accordance with the general consensus among Data Science professionals. But this for me is the most interesting part and I intend to dig deeper into the immense possibilities offered by testing the various algorithms and spending more time fine-tuning them.
### Next Steps ###
After I've submitted my Capstone Project in time for the upcoming deadline, I'll do the following:
 - Migrate the Jupyter Notebook to a clustered Spark environment (*e.g.*, Amazon S3, IBM Watson);
 - Work on the entire data set;
 - Enrich the feature set (*e.g.*, time-series: rolling time windows for differentiating recent and older in-session behaviors, to spot their evolution which could foreshadow potential churning);
 - Dimensionality Reduction, such as Principal Component Analysis (PCA);
 - Refactor the code into Classes and Methods (it wasn't done here in particular for visualizing the data at each step);
 - Save the resulting DataFrames into a distributed file system (*e.g.*, HDFS, S3) at various points, so that I don't have to re-execute the entire Jupyter Notebook every time I make a modification downstream;
 - Do some real Cross-Validation with various sets of parameters and isolate the best algorithm(s) for further fine-tuning;
 - Experiment with additional Classification and Cross-Validation methods.

## Related Blog Post ##
The findings of the analysis contained in the Jupyter Notebook are the subject of a blog post on Medium: [Sparkify versus the evil Dr. Churn](https://medium.com/@gers32/sparkify-versus-the-evil-dr-churn-8e1442e3a722).
