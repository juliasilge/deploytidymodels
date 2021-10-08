# nocov start

.onLoad <- function(...) {
    s3_register("vetiver::predict", "vetiver_endpoint")
}

# nocov end
