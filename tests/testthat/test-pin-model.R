library(pins)
library(workflows)
library(parsnip)

b <- board_temp()

rf_spec <- rand_forest(mode = "regression") %>%
    set_engine("ranger")

mtcars_wf <- workflow() %>%
    add_model(rf_spec) %>%
    add_formula(mpg ~ .) %>%
    fit(data = mtcars)

test_that("can pin a model", {
    pin_model(b, mtcars_wf, "mtcars_ranger")
    expect_equal(
        pin_read(b, "mtcars_ranger"),
        list(
            model = butcher::butcher(mtcars_wf),
            ptype = vctrs::vec_slice(tibble::as_tibble(mtcars[,2:11]), 0)
        )
    )
})

test_that("default metadata for model", {
    pin_model(b, mtcars_wf, "mtcars_ranger")
    meta <- pin_meta(b, "mtcars_ranger")
    expect_equal(meta$user, NULL)
    expect_equal(meta$description, "A ranger regression modeling workflow")
})

test_that("user can supply metadata for model", {
    pin_model(b, mtcars_wf, "mtcars_ranger",
              desc = "Random forest for mtcars",
              metadata = list(metrics = 1:10))
    meta <- pin_meta(b, "mtcars_ranger")
    expect_equal(meta$user, list(metrics = 1:10))
    expect_equal(meta$description, "Random forest for mtcars")
})
