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
