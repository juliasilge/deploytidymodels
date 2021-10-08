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

model_board <- board_temp(versioned = TRUE)
v <- vetiver_model(rf_fit, "sacramento_rf", model_board)
vetiver_pin_write(v)

pr() %>%
    vetiver_pr_predict(v, debug = TRUE) %>%
    pr_run(port = 8088)
