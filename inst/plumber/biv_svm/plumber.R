## auto generate this file

library(deploytidymodels)
library(pins)
library(plumber)

if (FALSE) {
    library(workflows)  ## eventually extract all these from the model
    library(recipes)
    library(parsnip)
    library(LiblineaR)
}

b <- board_rsconnect()
m <- modelops_pin_read(b, "julia.silge/biv_svm")
stopifnot(m$metadata$version == "47922")

## or is it better to deploy with:
## m <- modelops_pin_read(b, "julia.silge/biv_svm", version = "47922")

#* @plumber
function(pr) {
    pr %>%
        modelops_pr_predict(m, type = "class", debug = TRUE)
}
