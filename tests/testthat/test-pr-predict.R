library(pins)
library(workflows)
library(parsnip)
library(plumber)


test_that("default endpoint", {
  b <- board_temp()

  rf_spec <- rand_forest(mode = "regression") %>%
    set_engine("ranger")

  mtcars_wf <- workflow() %>%
    add_model(rf_spec) %>%
    add_formula(mpg ~ .) %>%
    fit(data = mtcars)

  v <- vetiver_model(mtcars_wf, "mtcars_ranger", b)
  vetiver_pin_write(v)

  p <- pr() %>% vetiver_pr_predict(v)
  ep <- p$endpoints[[1]][[1]]
  expect_equal(ep$verbs, c("POST"))
  expect_equal(ep$path, "/predict")
})
