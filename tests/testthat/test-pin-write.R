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
    v <- vetiver_model(mtcars_wf, "mtcars_ranger", b)
    vetiver_pin_write(v)
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
    v <- vetiver_model(mtcars_wf, "mtcars_ranger", b)
    vetiver_pin_write(v)
    meta <- pin_meta(b, "mtcars_ranger")
    expect_equal(meta$user, list())
    expect_equal(meta$description, "A ranger regression modeling workflow")
})

test_that("user can supply metadata for model", {
    b <- board_temp()
    v <- vetiver_model(mtcars_wf, "mtcars_ranger", b,
                       desc = "Random forest for mtcars",
                       metadata = list(metrics = 1:10))
    vetiver_pin_write(v)
    meta <- pin_meta(b, "mtcars_ranger")
    expect_equal(meta$user, list(metrics = 1:10))
    expect_equal(meta$description, "Random forest for mtcars")
})

test_that("can read a pinned model", {
    b <- board_temp()
    v <- vetiver_model(mtcars_wf, "mtcars_ranger", b)
    vetiver_pin_write(v)
    v1 <- vetiver_pin_read(b, "mtcars_ranger")
    meta <- pin_meta(b, "mtcars_ranger")
    expect_equal(v1$model, v$model)
    expect_equal(v1$model_name, v$model_name)
    expect_equal(v1$board, v$board)
    expect_equal(v1$desc, v$desc)
    expect_equal(
        v1$metadata,
        list(user = v$metadata$user,
             version = meta$local$version,
             url = meta$local$url,
             required_pkgs = c("parsnip", "ranger", "workflows"))
    )
    expect_equal(v1$ptype, v$ptype)
    expect_equal(v1$versioned, FALSE)
})
