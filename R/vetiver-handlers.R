#' Model handler functions for API endpoint
#' @inheritParams vetiver::vetiver_pr_predict
#' @rdname handlers_predict.workflow
#' @export
handler_startup.workflow <- function(vetiver_model, ...) {
    vetiver::attach_pkgs(vetiver_model$metadata$required_pkgs)
}

#' @rdname handlers_predict.workflow
#' @export
handler_predict.workflow <- function(vetiver_model, ...) {

    function(req) {
        new_data <- req$body
        new_data <-  vetiver_type_convert(new_data, vetiver_model$ptype)
        predict(vetiver_model$model, new_data = new_data, ...)

    }

}


