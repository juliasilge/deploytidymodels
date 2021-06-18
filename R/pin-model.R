#' Pin a trained modeling workflow to a board of models
#'
#' Use `pin_model()` to pin a trained model workflow to a board of models,
#' along with an input prototype for new data and model metadata.
#'
#' @param board A pin board, created by [pins::board_folder()],
#' [pins::board_rsconnect()], or other `board_` function from the pins package.
#' @param model A trained modeling [workflows::workflow()].
#' @param model_id Model ID or name.
#' @param type Defaults to `"rds"`, which is appropriate for most models. (See
#' [pins::pin_write()] for other options.)
#' @param desc A text description of the model; most important for shared
#' boards so that others can understand what the model is. If omitted,
#' tidymodelsdeploy will generate a brief description of the contents.
#' @param versioned Should the model object be versioned? Defaults to `TRUE`.
#' @inheritParams pins::pin_write
#'
#' @details This function creates *two* pins on the specified `board`, one for
#' the model object itself and one for the model's input data prototype. The
#' naming convention for the model data prototype uses the `model_id` plus the
#' suffix "_ptype".
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
#' # notice two pins created
#' model_board
#'
pin_model <- function(board,
                      model,
                      model_id,
                      type = "rds",
                      desc = NULL,
                      metadata = NULL,
                      versioned = TRUE) {

    if (!workflows::is_trained_workflow(model)) {
        rlang::abort("Your `model` object is not a trained workflow.")
    }

    model <- butcher::butcher(model)
    mold <- workflows::pull_workflow_mold(model)
    spec <- workflows::pull_workflow_spec(model)

    if (is_null(desc)) {
        desc <- glue("A {spec$engine} {spec$mode} model")
    }

    pins::pin_write(
        board = board,
        x = mold$blueprint$ptypes$predictors,
        name = glue("{model_id}_ptype"),
        type = "rds",
        desc = glue("An input data prototype for the {model_id} model"),
        metadata = list(mode = spec$mode, engine = spec$engine),
        versioned = versioned
    )

    pins::pin_write(
        board = board,
        x = model,
        name = model_id,
        type = type,
        desc = desc,
        metadata = metadata,
        versioned = versioned
    )

}
