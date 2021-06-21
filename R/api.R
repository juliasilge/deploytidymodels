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
    }

    pinned <- pins::pin_read(board, model_id)

    ## TODO: this pkg loading should stay outside of handler but how to extend
    ## to other models?
    tune::load_pkgs(pinned$model)

    model_handler <- function(req) {
        handle_model(pinned$model, req, type)
    }
    plumber::pr_post(pr, path = path, handler = model_handler, ...)
}


#' Wrapper function for creating model handler function
#'
#' @export
handle_model <- function(x, req, ...)
    UseMethod("handle_model")

#' @rdname handle_model
#' @export
handle_model.default <- function(x, req, ...)
    rlang::abort("There is no method available to build a model handler for `x`.")

#' @rdname handle_model
#' @param x A trained model created with [`workflows::workflow()`].
#' @param req A POST request, with a `body`.
#' @param ... Other arguments passed from [`pr_model()`].
#' @export
handle_model.workflow <- function(x, req, ...) {
    ellipsis::check_dots_used()
    args <- list(...)
    predict(x, new_data = req$body, type = args$type)
}




