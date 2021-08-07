# nocov start

.onLoad <- function(...) {
    s3_register("modelops::predict", "modelops_endpoint")
}

# nocov end
