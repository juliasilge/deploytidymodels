#' Model handler functions for API endpoint
#' @inheritParams modelops::modelops_pr_predict
#' @rdname handlers_predict.workflow
#' @export
handler_startup.workflow <- function(modelops, ...) tune::load_pkgs(modelops$model)

#' @rdname handlers_predict.workflow
#' @export
handler_predict.workflow <- function(modelops, ...) {

    function(req) {
        new_data <- req$body
        new_data <-  modelops_type_convert(new_data, modelops$ptype)
        predict(modelops$model, new_data = new_data, ...)

    }

}


