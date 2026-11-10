library(panelvar)
library(plm)
library(ggplot2)
library(panelr)
library(fixest)
library(did)
library(dplyr)
library(tidyr)

#import data
impevents <- read.csv("impevents.csv")
impevents <- impevents %>% select(country:imperialized)

#transform data as needed
impevents_df <- as.data.frame(impevents)

impcountry <- impevents %>% filter(imperialized == 1)

#creating dummy vars for stability index
dummytbl <- impevents %>% select(c("country", "year", v2x_corr:e_pelifeex))

dummytbl <- dummytbl %>% mutate(
  dummy_fiscap = v2stfisccap_ord/4,
  dummy_lifeex = e_pelifeex/100, 
  dummy_gddpc = e_gdppc/100, 
  dummy_rule = v2x_rule, 
  dummy_corr = 1 - v2x_corr,
  dummy_civlib = v2x_civlib
)

dummytbl <- dummytbl %>% mutate(
  stability_indx = (dummy_fiscap + dummy_lifeex + dummy_gddpc + dummy_rule + 
    dummy_corr + dummy_civlib)/6)

#add to main dataset
stability_indx <- dummytbl %>% select(c("country", "year", "stability_indx"))
impevents <- left_join(impevents, stability_indx, by = c("country", "year"))

impevents <- impevents %>% filter(!is.na(stability_indx))

#hypothesis one - difference in means - ttest
ttest <- t.test(stability_indx ~ imperialized, data = impevents)
ttest

#hypothesis two - cause and effect - pooled ols 
h2 <- plm(stability_indx ~ imperialized + factor(country) + factor(year), data = impevents_df, model = "pooling", index = c("country", "year"))
summary(h2)



