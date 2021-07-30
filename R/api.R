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

    modify_spec <- function(spec) {
        api_spec(spec, args)
    }

    pr <- args$pr
    pr <- plumber::pr_set_debug(pr, debug = args$debug)
    pr <- plumber::pr_post(pr, path = args$path, handler = predict_handler)
    pr <- plumber::pr_set_api_spec(pr, api = modify_spec)
    pr
}




