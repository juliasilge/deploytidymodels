library(tidymodels)
data(bivariate)

biv_rec <-
    recipe(Class ~ ., data = bivariate_train) %>%
    step_BoxCox(all_predictors())%>%
    step_normalize(all_predictors())

svm_spec <-
    svm_linear(mode = "classification") %>%
    set_engine("LiblineaR")

svm_fit <- workflow() %>%
    add_recipe(biv_rec) %>%
    add_model(svm_spec) %>%
    fit(bivariate_train)

library(deploytidymodels)
library(modelops)
library(pins)
library(plumber)

model_board <- board_rsconnect()
v <- vetiver_model(svm_fit, "biv_svm", model_board)
vetiver_pin_write(v)

pr() %>%
    vetiver_pr_predict(v, type = "class", debug = TRUE) %>%
    pr_run(port = 8088)

## vetiver_write_plumber(model_board, "julia.silge/biv_svm")

