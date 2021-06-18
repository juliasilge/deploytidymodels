#' Add a POST endpoint to a Plumber router using a pinned model workflow object
#'
#' Models that have been pinned to a board with [`pin_model`] can be added to a
#' Plumber router as a POST handler. The argument `type` specifies what kind of
#' predictions the handler will return.
#'
#' @param pr A Plumber router, such as from [`plumber::pr()`].
#' @param board A board containing models pinned via [`pin_model`].
#' @param ... Other arguments passed to [`plumber::pr_post()`].
#' @inheritParams parsnip::predict.model_fit
#' @inheritParams pin_model
#' @inheritParams plumber::pr_post
#'
#' @details The model's input data prototype is added to the handler to ensure
#' predictions can be made correctly, and packages needed for prediction are
#' loaded.
#'
#' @examples
#'
#' library(pins)
#' model_board <- board_temp()
#'
#' library(parsnip)
#' library(workflows)
#' rf_spec <- rand_forest(mode = "regression") %>%
#'     set_engine("ranger")
#'
#' mtcars_wf <- workflow() %>%
#'     add_model(rf_spec) %>%
#'     add_formula(mpg ~ .) %>%
#'     fit(data = mtcars)
#'
#'
#' model_board %>%
#'     pin_model(mtcars_wf, "mtcars_ranger")
#'
#' library(plumber)
#' pr() %>%
#'     pr_model(model_board, "mtcars_ranger")
#' ## next, pipe to `pr_run()`
#'
#' @export
pr_model <- function(pr,
                     board,
                     model_id,
                     type = NULL,
                     path = "/predict",
                     ...) {

    board_pins <- pins::pin_list(board)
    if (!model_id %in% board_pins) {
        rlang::abort(glue("Model {model_id} not found"))
    } else if (!glue("{model_id}_ptype") %in% board_pins) {
        rlang::abort(glue("Model {model_id}'s data prototype not found"))
    }

    wf <- pins::pin_read(board, model_id)
    ptype <- pins::pin_read(board, glue("{model_id}_ptype"))
    tune::load_pkgs(wf)

    model_handler <- function(req) {
        new_data <- hardhat::scream(req$body, ptype)
        predict(wf, new_data = new_data, type = type)
    }

    plumber::pr_post(pr, path = path, handler = model_handler, ...)
}


