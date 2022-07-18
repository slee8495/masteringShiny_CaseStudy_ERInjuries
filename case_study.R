library(shiny)
library(vroom)
library(tidyverse)

# acquiring the data
dir.create("neiss")
download <- function(name){
  url <- "http://github.com/hadley/mastering-shiny/raw/master/neiss/"
  download.file(paste0(url, name), paste0("neiss/", name), quiet = TRUE)
}
download("injuries.tsv.gz")
download("population.tsv")
download("products.tsv")

# How to read tsv.gz file? 
injuries <- vroom::vroom("neiss/injuries.tsv.gz")
injuries


products <- vroom::vroom("neiss/products.tsv")
population <- vroom::vroom("neiss/population.tsv")


# Data exploration
selected <- injuries %>% dplyr::filter(prod_code == 649)
nrow(selected)

selected %>% dplyr::count(location, wt = weight, sort = TRUE)
selected %>% dplyr::count(body_part, wt = weight ,sort = TRUE)
selected %>% dplyr::count(diag, wt = weight, sort = TRUE)

summary <- selected %>% 
  dplyr::count(age, sex, wt = weight)

summary %>% 
  ggplot2::ggplot(mapping = aes(x = age, y = n, color = sex)) +
  ggplot2::geom_line() +
  ggplot2::labs(y = "Estimated number of injuries")

selected %>% 
  dplyr::count(age, sex, wt = weight) %>% 
  dplyr::left_join(population, by = c("age", "sex")) %>% 
  dplyr::mutate(rate = n / population * 10000) -> summary


summary %>% 
  ggplot2::ggplot(mapping = aes(x = age, y = rate, color = sex)) +
  ggplot2::geom_line(na.rm = TRUE) +
  ggplot2::labs(y = "Injuries per 10,000 people")





