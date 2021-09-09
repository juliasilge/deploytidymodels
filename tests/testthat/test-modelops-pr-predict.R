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

  m <- modelops(mtcars_wf, "mtcars_ranger", b)
  modelops_pin_write(m)

  p <- pr() %>% modelops_pr_predict(m)
  ep <- p$endpoints[[1]][[1]]
  expect_equal(ep$verbs, c("POST"))
  expect_equal(ep$path, "/predict")
})
