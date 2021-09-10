#' Create a modelops object for deployment of a trained tidymodels workflow
#'
#' A [modelops::modelops()] object collects the information needed to store, version,
#' and deploy a trained model.
#'
#' @param model A trained model created with [workflows::workflow()].
#' @inheritParams modelops::modelops
#' @export
modelops.workflow <- function(model,
                              model_name,
                              board,
                              ...,
                              desc = NULL,
                              metadata = list(),
                              ptype = TRUE,
                              versioned = NULL) {

    if (!workflows::is_trained_workflow(model)) {
        rlang::abort("Your `model` object is not a trained workflow.")
    }

    model <- butcher::butcher(model)
    ptype <- modelops::modelops_create_ptype(model, ptype)

    if (rlang::is_null(desc)) {
        spec <- workflows::pull_workflow_spec(model)
        desc <- glue("A {spec$engine} {spec$mode} modeling workflow")
    }

    modelops::new_modelops(
        model = model,
        model_name = model_name,
        board = board,
        desc = as.character(desc),
        metadata = metadata,
        ptype = ptype,
        versioned = versioned
    )
}


#' @export
modelops_slice_zero.workflow <- function(model, ...) {
    mold <- workflows::extract_mold(model)
    mold$blueprint$ptypes$predictors
}

