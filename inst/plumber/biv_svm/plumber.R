library(deploytidymodels)
library(pins)
library(plumber)

library(workflows)  ## eventually we will be able to extract all these from the model
library(recipes)
library(parsnip)
library(LiblineaR)

model_board <- board_rsconnect(server = "https://colorado.rstudio.com/rsc")
m <- model_board <- pin_read("julia.silge/biv_svm")

#* @plumber
function(pr) {
    pr %>%
        modelops_pr_predict(m, type = "class")
}
