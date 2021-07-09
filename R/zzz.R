# nocov start

.onLoad <- function(...) {
    s3_register("modelops::predict", "model_endpoint")
}

# nocov end
