#' Wrapper function for pinning a model to a board of models
#'
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

    if (args$ptype) {
        ptype <- mold$blueprint$ptypes$predictors
    } else {
        ptype <- NULL
    }

    pins::pin_write(
        board = args$board,
        x = list(model = x, ptype = ptype),
        name = args$model_id,
        type = args$type,
        desc = args$desc,
        metadata = args$metadata
    )
}

