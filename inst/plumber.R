library(deploytidymodels)
library(pins)
library(plumber)

model_board <- board_rsconnect()

#* @plumber
function(pr) {
    pr %>%
        pr_model(model_board, "julia.silge/biv_svm", type = "class")
}
