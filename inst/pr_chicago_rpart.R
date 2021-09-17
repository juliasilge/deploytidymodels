## to check for problems with data types at prediction time

library(tidymodels)
data(Chicago)

chicago_small <- Chicago %>% slice(1:365)

splits <-
    sliding_period(
        chicago_small,
        date,
        "day",
        lookback = 300,   # Each resample has 300 days for modeling
        assess_stop = 7,  # One week for performance assessment
        step = 7          # Ensure non-overlapping weeks for assessment
    )

chicago_rec <-
    recipe(ridership ~ ., data = Chicago) %>%
    step_date(date) %>%
    step_holiday(date, keep_original_cols = FALSE) %>%
    step_dummy(all_nominal_predictors()) %>%
    step_zv(all_predictors()) %>%
    step_normalize(all_predictors()) %>%
    step_pca(all_of(stations), num_comp = 4)

tree_spec <-
    decision_tree() %>%
    set_engine("rpart") %>%
    set_mode("regression")

chicago_fit <-
    workflow(chicago_rec, tree_spec) %>%
    fit(chicago_small)

library(deploytidymodels)
library(pins)
library(plumber)

model_board <- board_temp()
## optional custom input data prototype for API
chicago_ptype <- chicago_small %>% slice_sample(n = 3) %>% select(-ridership)
m <- modelops(chicago_fit, "chicago_ridership", model_board, ptype = chicago_ptype)
modelops_pin_write(m)

pr() %>%
    modelops_pr_predict(m, debug = TRUE) %>%
    pr_run(port = 8088)

# endpoint <- modelops_endpoint("http://127.0.0.1:8088/predict")
# new_chicago <- Chicago %>% slice_sample(n = 10) %>% select(-ridership)
# predict(endpoint, new_chicago)
