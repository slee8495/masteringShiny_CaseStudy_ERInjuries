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



######################################################################################################
############################################### Shiny ################################################
######################################################################################################

########################################## Proto Type ################################################

prod_codes <- setNames(products$prod_code, products$title)



ui <- fluidPage(
  fluidRow(
    column(6,
           selectInput("code", "Product", choices = prod_codes))
  ),
  fluidRow(
    column(4, tableOutput("diag")),
    column(4, tableOutput("body_part")),
    column(4, tableOutput("location"))
  ),
  fluidRow(
    column(12, plotOutput("age_sex"))
  )
)


server <- function(input, output, session){
  selected <- reactive(injuries %>% dplyr::filter(prod_code == input$code))
  
  output$diag <- renderTable(
    selected() %>% dplyr::count(diag, wt = weight, sort = TRUE))
  
  output$body_part <- renderTable(
    selected() %>% dplyr::count(body_part, wt = weight, sort =  TRUE))
  
  output$location <- renderTable(
    selected() %>% dplyr::count(location, wt = weight, sort = TRUE))
  
  summary <- reactive({
    selected() %>% 
      dplyr::count(age, sex, wt = weight) %>% 
      dplyr::left_join(population, by = c("age", "sex")) %>% 
      dplyr::mutate(rate = n / population * 10000)
    })
  
  output$age_sex <- renderPlot({
    summary() %>% 
      ggplot2::ggplot(mapping = aes(x = age, y = n, color = sex)) +
      ggplot2::geom_line() +
      ggplot2::labs(y = "Estimated number of injuries")
  }, res = 96)
}


shinyApp(ui = ui, server = server)


########################################## Polish Tables ################################################

save(injuries, file = "C:/Users/sanle/OneDrive/R/Work/My Libraries/mylibraries/example_data/injuries.rds")

# How to load 
load("name.rds")

injuries %>% 
  dplyr::mutate(diag = forcats::fct_lump(forcats::fct_infreq(diag), n = 5)) %>% 
  dplyr::group_by(diag) %>% 
  dplyr::summarise(n = as.integer(sum(weight)))
