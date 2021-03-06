#' Create a vetiver object for deployment of a trained tidymodels workflow
#'
#' A [vetiver::vetiver_model()] object collects the information needed to
#' store, version, and deploy a trained model.
#'
#' @param model A trained model created with [workflows::workflow()].
#' @inheritParams vetiver::vetiver_model
#' @export
vetiver_model.workflow <- function(model,
                                   model_name,
                                   board,
                                   ...,
                                   desc = NULL,
                                   metadata = list(),
                                   save_ptype = TRUE,
                                   versioned = NULL) {

    if (!workflows::is_trained_workflow(model)) {
        rlang::abort("Your `model` object is not a trained workflow.")
    }

    model <- butcher::butcher(model)
    ptype <- vetiver::vetiver_create_ptype(model, save_ptype)
    required_pkgs <- required_pkgs(model)
    required_pkgs <- unique(c(required_pkgs, "workflows"))

    if (rlang::is_null(desc)) {
        spec <- workflows::extract_spec_parsnip(model)
        desc <- glue("A {spec$engine} {spec$mode} modeling workflow")
    }

    vetiver::new_vetiver_model(
        model = model,
        model_name = model_name,
        board = board,
        desc = as.character(desc),
        metadata = vetiver::vetiver_meta(metadata,
                                         required_pkgs = required_pkgs),
        ptype = ptype,
        versioned = versioned
    )
}


#' @export
vetiver_slice_zero.workflow <- function(model, ...) {
    mold <- workflows::extract_mold(model)
    mold$blueprint$ptypes$predictors
}

