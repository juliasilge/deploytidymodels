#' Pin a trained model to a board of models
#'
#' Use `pin_model()` to pin a trained model to a board of models, along with an
#' input prototype for new data and other model metadata.
#'
#' @param board A pin board, created by [pins::board_folder()],
#' [pins::board_rsconnect()], or other `board_` function from the pins package.
#' @param model A trained model, such as a modeling [workflows::workflow()].
#' @param model_id Model ID or name.
#' @param type Defaults to `"rds"`, which is appropriate for most models. (See
#' [pins::pin_write()] for other options.)
#' @param desc A text description of the model; most important for shared
#' boards so that others can understand what the model is. If omitted,
#' the package will generate a brief description of the contents.
#' @param versioned Should the model object be versioned? Defaults to `TRUE`.
#' @inheritParams pins::pin_write
#'
#' @details This function creates a pin on the specified `board` containing
#' two elements, the model object itself and the model's input data prototype.
#'
#' @export
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
#' model_board %>% pin_model(mtcars_wf, "mtcars_ranger")
#' model_board
#'
pin_model <- function(board,
                      model,
                      model_id,
                      type = "rds",
                      desc = NULL,
                      metadata = NULL,
                      versioned = TRUE) {

    model_pinner(
        x = model,
        board = board,
        model_id = model_id,
        type = type,
        desc = desc,
        metadata = metadata,
        versioned = versioned
    )

}

#' Wrapper function for pinning a model to a board of models
#'
#' @export
model_pinner <- function(x, ...)
    UseMethod("model_pinner")

#' @rdname model_pinner
#' @export
model_pinner.default <- function(x, ...)
    rlang::abort("There is no method available to pin `x`.")

#' @rdname model_pinner
#' @param x A trained model created with [`workflows::workflow()`].
#' @param ... Other arguments passed from [`pin_model()`].
#' @export
model_pinner.workflow <- function(x, ...) {

    ellipsis::check_dots_used()

    if (!workflows::is_trained_workflow(x)) {
        rlang::abort("Your `x` object is not a trained workflow.")
    }

    x <- butcher::butcher(x)
    mold <- workflows::pull_workflow_mold(x)

    args <- list(...)

    if (is_null(args$desc)) {
        spec <- workflows::pull_workflow_spec(x)
        args$desc <- glue("A {spec$engine} {spec$mode} modeling workflow")
    }

    pins::pin_write(
        board = args$board,
        x = list(model = x, ptype = mold$blueprint$ptypes$predictors),
        name = args$model_id,
        type = args$type,
        desc = args$desc,
        metadata = args$metadata
    )
}

