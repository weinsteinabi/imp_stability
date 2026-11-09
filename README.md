⚠️ UNDER CONSTRUCTION
# Imperialism and State Stability in Latin America

This repository contains an overview of the term paper for the Social Data Analytics program's research design course, in addition to data sources, scripts, and visuals used. There is overlap between this project and the project linked [here](https://github.com/weinsteinabi/war_decol/tree/main) in regard to data use. I can be contacted [here](https://github.com/weinsteinabi#contact-information) to discuss the project further. 

This project was completed in December of 2025. It was added to this profile on November 4th, 2026. 

## 📄 Project Overview
SODA 308 and this paper's completion was overseen by Dr. Isaac Pollert, a professor at Penn State University. Students were given the freedom to conduct research on any topic provided instructor approval at the beginning of the semester. *Imperialism and State Stability in Latin America* began as an interest in assessing the political and economic impacts of U.S. imperial behaviors on occupied countries in response to the overwhelming approach of the field to centering the occupier and discussion surrounding European colonial behaviors. This is supplemented by case-by-case review of U.S. imperial activities in the region, but primarily focuses on quantified impacts of occupation in the long-term. This is done through an analysis of economic, democratic, and quality-of-life measures when paired with binary flags indicating U.S. occupation and duration of independence.

This analysis was done through first identifying differences in stability based on our occupation flag using the Welch's two-sample *t*. From here, we use a pooled OLS regression with factors to examine the effects imperial behaviors has on state stability directly. In the future, this could be use to model future stability of these states. Because state stability is determined by a number of factors, various variables were transformed into a standardized stability index for use in this project. This should be expanded upon theoretically in the future. The project itself culminated in an end-of-semester paper and a presentation reviewing methods and findings. 
## 🧮 Data Sources
All data used in this paper is publicly accessible. They can be found in the [data sources folder]( ) of this repository. For those in italics, a link to the source will be provided instead. 
- **Military Involvement/Occupation Data**: obtained from two data sources, Andreas Wimmer's ["From Empire to Nation-State" dataset](https://www.awimmer.com/data) and Tuft's University's [Military Intervention Project](https://sites.tufts.edu/css/?page_id=1582) (MIP) through the Fletcher Center for Strategic Studies. These data sources were used to identify countries that were exposed to U.S. military control for periods longer than a year within the Latin American region.
- ***State Stability Data***: obtained from the [Varieties of Democacy v15 complete dataset](https://v-dem.net/data/the-v-dem-dataset/country-year-v-dem-fullothers-v15/).

The final data set, titled *impevents.csv*, is stored in separately from the data sources. 
## 💻 R Script Navigation
All scripts for data cleaning, analysis, and visualization can be found in the [scripts folder] ( ) of this repository. There are three total scripts for this project: 
- *dataprep.R*: handles all data processing aimed at identifying occupation events within the correct region and time frame of analysis.
- *modelpractice.R*: creates the stability index for use in modeling, merges index to event data, and runs the models themselves.
- *description.R*: produces all visuals and tables for the project. 
## 🥼 Methodology 
### *Data Processing*
Because our raw data is not obtained from datasets focused on either the United States or acts of imperialism, the first step is pare data down to be acceptable for our research goals. Data points used for our research purposes must meet the following criteria if documenting imperial activities in particular: 
- the imperial power is identified as the **United States**
- the occupied territory is in the **Latin American region**
- event takes place between **1898 and 1945** (Age of "New Imperialism")
- justifications for military action, if taken, must align with motivations for imperialism of that era (this only applies to data from the MIP data source)
- military engagement/intervention must last at least 1 year
This results in ten unique episodes identified across seven countries when using data from the Military Intervention/Occupation datasets described above. We then expand each of these episodes across the years they were active. From here, we create a binary flag indicating whether or not a state has been occupied by the United State during the specified time period. All observations in this first set receive a value of **1**, indicating that there was an occupation episode.

Once this is complete, we incorporate data from the rest of the countries in the region and expand the dataset to range from the beginning of our specified time period to 2010. This allows us to track data we will be using for our stability metrics from the beginning of the "New Imperialism" period until recently across all states in the Latin American region. These stability metrics, obtained from V-DEMv15, are as follows: 
- *v2stfisccap*: fiscal capacity of the state to support services
- *e_pelifeex*: life expectancy
- *e_gdppc*: average gross domestic product per capita
- _v2x_civlib_: civil liberties
- *v2x_rule*: rule of law
- _v2x_corr_: corruption
We combine these to create a standardized state stability metric that combines various indicators of national stability into one continuous measure, ranging from 0 (unstable) to 1 (stable), using the formula $Stability = \frac{\frac{𝑓𝑖𝑠𝑐𝑐𝑎𝑝}{4} + \frac{𝑙𝑖𝑓𝑒_𝑒𝑥𝑝}{100} + \frac{𝑔𝑑𝑑𝑝𝑐}{100} + (1 − 𝑐𝑜𝑟𝑟) + 𝑟𝑢𝑙𝑒 + 𝑐𝑖𝑣𝑙𝑖𝑏}{6}$
## ▶️ Project Outcomes and Future Steps

## 📝 Citations
