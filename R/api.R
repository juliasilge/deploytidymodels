#' Wrapper function for creating model handler function
#' @param x A trained model created with [`workflows::workflow()`].
#' @param ... Other arguments passed from [`pr_model()`].
#' @export
handle_model.workflow <- function(x, ...) {
    ellipsis::check_dots_used()
    args <- list(...)
    tune::load_pkgs(x)

    predict_handler <- function(req) {
        predict(x, new_data = req$body, type = args$type)
    }

    plumber::pr_post(pr = args$pr, path = args$path, handler = predict_handler)
}




