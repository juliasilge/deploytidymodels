library(pins)
library(workflows)
library(parsnip)

rf_spec <- rand_forest(mode = "regression") %>%
    set_engine("ranger")

mtcars_wf <- workflow() %>%
    add_model(rf_spec) %>%
    add_formula(mpg ~ .) %>%
    fit(data = mtcars)

test_that("can pin a model", {
    b <- board_temp()
    m <- modelops(mtcars_wf, "mtcars_ranger", b)
    modelops_pin_write(m)
    expect_equal(
        pin_read(b, "mtcars_ranger"),
        list(
            model = butcher::butcher(mtcars_wf),
            ptype = vctrs::vec_slice(tibble::as_tibble(mtcars[,2:11]), 0),
            required_pkgs = c("parsnip", "ranger", "workflows")
        )
    )
})

test_that("default metadata for model", {
    b <- board_temp()
    m <- modelops(mtcars_wf, "mtcars_ranger", b)
    modelops_pin_write(m)
    meta <- pin_meta(b, "mtcars_ranger")
    expect_equal(meta$user, list())
    expect_equal(meta$description, "A ranger regression modeling workflow")
})

test_that("user can supply metadata for model", {
    b <- board_temp()
    m <- modelops(mtcars_wf, "mtcars_ranger", b)
    m <- modelops(mtcars_wf, "mtcars_ranger", b,
                  desc = "Random forest for mtcars",
                  metadata = list(metrics = 1:10))
    modelops_pin_write(m)
    meta <- pin_meta(b, "mtcars_ranger")
    expect_equal(meta$user, list(metrics = 1:10))
    expect_equal(meta$description, "Random forest for mtcars")
})

test_that("can read a pinned model", {
    b <- board_temp()
    m <- modelops(mtcars_wf, "mtcars_ranger", b)
    modelops_pin_write(m)
    m1 <- modelops_pin_read(b, "mtcars_ranger")
    meta <- pin_meta(b, "mtcars_ranger")
    expect_equal(m1$model, m$model)
    expect_equal(m1$model_name, m$model_name)
    expect_equal(m1$board, m$board)
    expect_equal(m1$desc, m$desc)
    expect_equal(
        m1$metadata,
        list(user = m$metadata$user,
             version = meta$local$version,
             url = meta$local$url,
             required_pkgs = c("parsnip", "ranger", "workflows"))
    )
    expect_equal(m1$ptype, m$ptype)
    expect_equal(m1$versioned, FALSE)
})
