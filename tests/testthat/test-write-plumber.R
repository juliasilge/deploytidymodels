library(pins)
library(workflows)
library(parsnip)

rf_spec <- rand_forest(mode = "regression") %>%
    set_engine("ranger")

mtcars_wf <- workflow() %>%
    add_model(rf_spec) %>%
    add_formula(mpg ~ .) %>%
    fit(data = mtcars)

test_that("create plumber.R with packages", {
    skip_on_cran()
    b <- board_folder(path = "/tmp/test")
    tmp <- tempfile()
    m <- vetiver_model(mtcars_wf, "mtcars_ranger", b)
    vetiver_pin_write(m)
    vetiver_write_plumber(b, "mtcars_ranger", file = tmp)
    expect_snapshot(cat(readr::read_lines(tmp), sep = "\n"))
})
