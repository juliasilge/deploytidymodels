library(pins)
library(workflows)
library(parsnip)
library(plumber)

b <- board_temp()

rf_spec <- rand_forest(mode = "regression") %>%
    set_engine("ranger")

mtcars_wf <- workflow() %>%
    add_model(rf_spec) %>%
    add_formula(mpg ~ .) %>%
    fit(data = mtcars)

pin_model(b, mtcars_wf, "mtcars_ranger")

test_that("default endpoint", {
  p <- pr() %>% pr_model(b, "mtcars_ranger")
  ep <- p$endpoints[[1]][[1]]
  expect_equal(ep$verbs, c("POST"))
  expect_equal(ep$path, "/predict")
})
