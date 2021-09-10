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

model_board <- board_rsconnect()
m <- model_board %>% modelops_pin_read("julia.silge/biv_svm")
stopifnot(m$metadata$version == "47922")

#* @plumber
function(pr) {
    pr %>%
        modelops_pr_predict(m, type = "class", debug = TRUE)
}
