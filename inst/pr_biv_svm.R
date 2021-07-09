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
library(pins)
library(plumber)

model_board <- board_rsconnect()
model_board %>% pin_model(svm_fit, model_id = "biv_svm")

pr() %>%
    pr_model(model_board, "julia.silge/biv_svm", type = "class") %>%
    pr_run(port = 8088)

