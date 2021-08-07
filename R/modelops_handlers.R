#' Model handler functions for API endpoint
#' @inheritParams modelops::modelops_pr_predict
#' @rdname handlers_predict.workflow
#' @export
handler_startup.workflow <- function(modelops, ...) tune::load_pkgs(modelops$model)

#' @rdname handlers_predict.workflow
#' @export
handler_predict.workflow <- function(modelops, ...) {

    function(req) {
        predict(modelops$model, new_data = req$body, ...)
    }

}


