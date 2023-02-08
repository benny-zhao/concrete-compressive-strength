<h1 align="center">Assessing Concrete Compressive Strength in Relation to Age and Composition</h1>

<h2>About</h2>

This was the final project assigned in STAT 448: Advanced Data Analysis during the Fall 2022 semester.

The data set was assigned and distributed by the instructor, Professor Darren Glosemeyer, and it was a modified version of Professor I-Cheng Yeh’s concrete compressive strength data set obtained from the University of California Irvine Machine Learning Repository. The data set can be found at:

- [https://archive.ics.uci.edu/ml/datasets/Concrete+Compressive+Strength](https://archive.ics.uci.edu/ml/datasets/Concrete+Compressive+Strength)

It consists of 1,080 samples of concrete with the following variables:

- Six quantitative variables that describe the ratio of a component of concrete to water, measured in kilograms per cubic meter; these include cement, blast furnace slag, fly ash, superplasticizer, course aggregegate, and fine aggregate
- Age, measured in days; all samples are at most 365 days old
- Concrete compressive strength, measured in megapascals (MPa)
- A categorical variable for age group, in which there are 6:
	1. Less than 1 week
	2. At least 1 week to within 4 weeks
	3. At least 4 weeks to within 8 weeks
	4. At least 8 weeks to within 90 days
	5. At least 90 days to within 180 days
	6. At least 180 days

The data analysis was completed using SAS within SAS Studio.

<h2>Objective</h2>

The objective was to evaluate the possible relationship between concrete compressive strength, age, and concrete composition, which was then partitioned into 5 seperate analyses:

1. Descriptive statistics of the concrete, emphasizing concrete strength in relation to age and concrete composition in relation to age
2. Grouping samples based on composion and age
3. Modeling compressive strength using composition, for concrete samples that are at least 90 days old
4. Modeling whether the compressive strength of concrete samples between 90 and 100 days was at least 50 MPa
5. Determining the age group using composition and compressive strength

<h2>Methods</h2>

The analysis involved the use of the following:

- Exploratory analysis 
- Cluster analysis
- Residual diagnostics
- Multiple linear regression
- Logistic regression
- Stepwise variable selection
- Discriminant analysis

<h2>Results</h2>

- The exploratory analysis revealed that the compressive strength of a sample tended to increase as the ratio of a concrete component increased, except for fly ash.
- While statistically significant clusters of concrete samples could be formed, using clustering to forecast compressive strength is not reliable in that it explains less than 16% of the variation in compressive strength.
- For concrete samples that were at 90 days old, the ratio of cement, ratio of blast furnace slag, and ratio of fly ash were considered significant in increased compressive strength; the ratio of fine aggregate were considered significant in decreasing compressive strength
	- The model produced was $y_{\text{compr. str.}} = 15.98 + 18.28964x_{\text{cement ratio}} + 18.45323x_{\text{blast. f. slag ratio}} + 19.40942x_{\text{fly ash ratio}} - 1.94854x_{\text{fine agg. ratio}}$, where
		- $y_{\text{compr. str.}}$ is the compressive strength measured in MPa
		- $x_{\text{cement ratio}}$ is the ratio of cement to water used in the sample's mixture, measured in kilograms per cubic meter
		- $x_{\text{blast. f. slag ratio}}$ is the ratio of blast furnace slag to water used in the sample's mixture, measured in kilograms per cubic meter
		- $x_{\text{fly ash ratio}}$ is the ratio of fly ash slag to water used in the sample's mixture, measured in kilograms per cubic meter
		- $x_{\text{fine agg. ratio}}$ is the ratio of fine aggregate to water used in the sample's mixture, measured in kilograms per cubic meter
	- Approximately 72.04% of the variation in compressive strength could be explained by the model
- For concrete samples that were between 90 days to 100 days old, the odds of the compressive strength being at least 90 MPa is expected to increase multiplicatively as the ratio of at least one of superplasticizer, cement, or blast furnace slag increased.
- Classification of a concrete sample's age group based on composition and compressive strength was considered unreliable for most age groups except for age group 6, which contained samples between 180 to 365 days old.

<h2>Installation</h2>

1. Download this project as zip and extract it
2. Import it in SAS
