library(deploytidymodels)
library(pins)
library(plumber)

if (FALSE) {
    library(workflows)  ## eventually we will be able to extract all these from the model
    library(recipes)
    library(parsnip)
    library(LiblineaR)
}

model_board <- board_rsconnect()
m <- model_board %>% modelops_pin_read("julia.silge/biv_svm")
## stopifnot for specific plain text version/hash???

#* @plumber
function(pr) {
    pr %>%
        modelops_pr_predict(m, type = "class", debug = TRUE)
}
