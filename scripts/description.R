library(psych)
library(knitr)
library(kableExtra)
library(report)
library(dplyr)
library(tidyverse)
library(ggplot2)
library(ggmap)
library(geosphere)
library(maps)
library(modelsummary)

#summary tbl for me - all vars
summarystat <- describe(impevents)
summarystat <- summarystat %>% select(n, mean, min, max)
impsum <- summarystat %>% mutate(
  across(n, ~ format(.x, big.mark = ","))) %>% 
  kable(
    col.names = c("", "Count", "Mean", "Min. Value", "Max. Value"), 
    caption = "Summary Statistics",
    digits = 2) %>% 
  kable_classic() 
impsum

#summary tbl for me - dummy vars
summarystat <- describe(dummytbl)
summarystat <- summarystat %>% select(n, mean, min, max)
dumsum <- summarystat %>% mutate(
  across(n, ~ format(.x, big.mark = ","))) %>% 
  kable(
    col.names = c("", "Count", "Mean", "Min. Value", "Max. Value"), 
    caption = "Summary Statistics",
    digits = 2) %>% 
dumsum

#t-test table for pres.
t_test <- report_table(ttest)
t_test <- t_test %>% select(c(Parameter, Mean_Group1, Mean_Group2, Difference, t, p))
testtbl <- t_test %>% kable(
  col.names = c("", "Non-Occupied Mean", "Occupied Mean", "Diff. of Means", "t-score", "p-value"), 
  caption = "Welch's Two-Sample t-Test: Stability by U.S. Occupation", 
  digits = 3) %>% 
  footnote(alphabet = c("Confidence Level: 95% ", "Confidence Interval: [.085, .113]"), fixed_small_size = TRUE) %>%
  kable_classic()
testtbl


plotgr <- impevents %>% group_by(imperialized, year) %>% filter(country != "Peru") %>% mutate(
  mean_stab = mean(stability_indx))
plot <- ggplot(plotgr, aes(x = year, y = mean_stab)) +
  geom_line(linewidth = 1.5) + 
  labs(title = "State Stability by Country Group", subtitle = "Latin America (1898 - 2010)", x = "Year", y = "State Stability", color = "U.S. Military Occupation") +
  theme_minimal()
plot

#pooled ols outcomes
pltbl <- modelsummary(h2, fmt = fmt_term(default = 3), title = "Pooled OLS Model", notes = list("R2: .8728", "Adj. R2: .8647"), 
                      shape = term ~ statistic, 
                      statistic = c(c("Std. Error" = "{std.error}"), c("t-score" = "{statistic}"), c("p-value" = "{p.value}")),
                      gof_omit = 'Num.Obs.|R2|R2 Adj.|AIC|BIC|RMSE', 
                      output = "kableExtra") %>% kable_classic()
pltbl

#map of occupation
map <- map_data("world")
latin_america <- subset(map, region %in% c("Brazil", "Mexico", "Guatemala", "Chile", 
                                         "Panama", "Uruguay", "Paraguay", "Cuba", "Dominican Republic",
                                         "Haiti", "Argentina", "Peru", "Venezuela", "Colombia", "Ecuador", 
                                         "Bolivia", "Costa Rica", "El Salvador", "Honduras", "Nicaragua", 
                                         "Belize", "French Guiana"))
ggplot(impcountry) +
  geom_map(
    data = latin_america, map = latin_america, aes(map_id = region),
    fill = "white", color = "#7f7f7f", linewidth = 0.25
  ) + 
  geom_map(
    map = latin_america, aes(map_id = country, fill = imperialized),
    linewidth = 0.25
  ) + scale_fill_gradient(low = "white", high = "#604878", name = "U.S. Occupied Countries (1898 - 1945)") +
  expand_limits(x = latin_america$long, y = latin_america$lat) +
  ylab(" ") + xlab(" ") +
  ggtitle("U.S. Occupied Countries (1898 - 1945)") +
  theme(
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank()
  ) +
  theme() 

write.csv(impevents, "C:\\Users\\abiwe\\OneDrive\\Desktop\\impevents.csv", row.names = FALSE) 


