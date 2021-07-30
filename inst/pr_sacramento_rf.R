library(tidymodels)
data("Sacramento")

rf_spec <-
    rand_forest() %>%
    set_mode("regression") %>%
    set_engine("ranger")

rf_fit <-
    workflow() %>%
    add_formula(price ~ type + sqft + beds + baths) %>%
    add_model(rf_spec) %>%
    fit(Sacramento)

rf_fit

library(deploytidymodels)
library(pins)
library(plumber)

model_board <- board_temp()
model_board %>% pin_model(rf_fit, model_id = "sacramento_rf")

pr() %>%
    pr_model(model_board, "sacramento_rf", debug = TRUE) %>%
    pr_run(port = 8088)
