
<!-- README.md is generated from README.Rmd. Please edit that file -->

# deploytidymodels

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/tidymodelsdeploy)](https://CRAN.R-project.org/package=tidymodelsdeploy)
[![R-CMD-check](https://github.com/juliasilge/deploytidymodels/workflows/R-CMD-check/badge.svg)](https://github.com/juliasilge/deploytidymodels/actions)
<!-- badges: end -->

**This repo is archived in favor of the 
[vetiver](https://github.com/tidymodels/vetiver/) package.**

The goal of deploytidymodels is to provide fluent tooling to version,
share, and deploy a trained model
[workflow](https://workflows.tidymodels.org/) using the
[vetiver](https://github.com/tidymodels/vetiver) framework. Functions
handle both recording and checking the model’s input data prototype, and
loading the packages needed for prediction.

## Installation

~~You can install the released version of deploytidymodels from
[CRAN](https://CRAN.R-project.org) with:~~

``` r
install.packages("deploytidymodels") ## not yet
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("juliasilge/deploytidymodels")
```

## Example

You can use the [tidymodels](https://www.tidymodels.org/) ecosystem to
train a model, with a wide variety of preprocessing and model estimation
options.

``` r
library(parsnip)
library(workflows)
data(Sacramento, package = "modeldata")

rf_spec <- rand_forest(mode = "regression")
rf_form <- price ~ type + sqft + beds + baths

rf_fit <- 
    workflow(rf_form, rf_spec) %>%
    fit(Sacramento)
```

You can **version** and **share** your model by
[pinning](https://pins.rstudio.com/dev/) it, to a local folder, RStudio
Connect, Amazon S3, and more.

``` r
library(deploytidymodels)
library(pins)

model_board <- board_temp()
m <- vetiver_model(rf_fit, "sacramento_rf", model_board)
vetiver_pin_write(m)
#> Creating new version '20211008T150541Z-21d32'
#> Writing to pin 'sacramento_rf'
```

You can **deploy** your pinned model via a [Plumber
API](https://www.rplumber.io/), which can be [hosted in a variety of
ways](https://www.rplumber.io/articles/hosting.html).

``` r
library(plumber)

pr() %>%
    vetiver_pr_predict(m) %>%
    pr_run(port = 8088)
```

Make predictions with your deployed model by creating an endpoint
object:

``` r
endpoint <- vetiver_endpoint("http://127.0.0.1:8088/predict")
endpoint
#> 
#> ── A model API endpoint for prediction: 
#> http://127.0.0.1:8088/predict
```

A model API endpoint deployed with `vetiver_pr_predict()` will return
predictions with appropriate new data.

``` r
library(tidyverse)
new_sac <- Sacramento %>% 
    slice_sample(n = 20) %>% 
    select(type, sqft, beds, baths)

predict(endpoint, new_sac)
#> # A tibble: 20 x 1
#>      .pred
#>      <dbl>
#>  1 165042.
#>  2 212461.
#>  3 119008.
#>  4 201752.
#>  5 223096.
#>  6 115696.
#>  7 191262.
#>  8 211706.
#>  9 259336.
#> 10 206826.
#> 11 234952.
#> 12 221993.
#> 13 204983.
#> 14 548052.
#> 15 151186.
#> 16 299365.
#> 17 213439.
#> 18 287993.
#> 19 272017.
#> 20 226629.
```

## Contributing

This project is released with a [Contributor Code of
Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

-   For questions and discussions about tidymodels packages, modeling,
    and machine learning, please [post on RStudio
    Community](https://community.rstudio.com/new-topic?category_id=15&tags=tidymodels,question).

-   If you think you have encountered a bug, please [submit an
    issue](https://github.com/juliasilge/deploytidymodels/issues).

-   Either way, learn how to create and share a
    [reprex](https://reprex.tidyverse.org/articles/articles/learn-reprex.html)
    (a minimal, reproducible example), to clearly communicate about your
    code.

-   Check out further details on [contributing guidelines for tidymodels
    packages](https://www.tidymodels.org/contribute/) and [how to get
    help](https://www.tidymodels.org/help/).
