library(deploytidymodels)
library(pins)
library(plumber)

library(workflows)  ## eventually we will be able to extract all these from the model
library(recipes)
library(parsnip)
library(LiblineaR)

model_board <- board_rsconnect()

#* @plumber
function(pr) {
    pr %>%
        pr_model(model_board, "julia.silge/biv_svm", type = "class")
}
