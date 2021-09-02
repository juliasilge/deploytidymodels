#' Model handler functions for API endpoint
#' @inheritParams modelops::modelops_pr_predict
#' @rdname handlers_predict.workflow
#' @export
handler_startup.workflow <- function(modelops, ...) tune::load_pkgs(modelops$model)

#' @rdname handlers_predict.workflow
#' @export
handler_predict.workflow <- function(modelops, ...) {

    ptype <- modelops$ptype
    spec <- readr::as.col_spec(ptype)

    function(req) {

        new_data <- req$body
        if (!rlang::is_null(ptype)) {
            new_data <- readr::type_convert(req$body, col_types = spec)
        }
        predict(modelops$model, new_data = new_data, ...)
    }

}


