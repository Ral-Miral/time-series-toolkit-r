# time-series-toolkit-r

R toolkit for seasonal time series: moving average, seasonal coefficients (additive or multiplicative), seasonal adjustment, and four exponential smoothing forecasts (simple, double, damped Holt, Holt-Winters) returning the forecasts and the MSE of each model. Tested on French electricity consumption data (RTE éCO2mix, 2012-2018).

## Requirements

- R >= 4.1 (the example uses the `|>` pipe)
- Package `forecast`

```r
install.packages("forecast")
```

## Loading the functions

```r
source("R/load.R")
```

From the example folder:

```r
source("../R/load.R")
```

## Dependencies between files

R resolves function names when they are called, not when they are defined, so the loading order does not matter as long as all files are loaded before a function is used. `load.R` loads everything at once.

```
decomposition.R   (no dependency)
      ▲
      │
plots.R ── full_plot needs moving_average, seasonal_coefficients, compute_sa
      ▲
      │
study.R ── time_series_study needs moving_average, seasonal_coefficients,
           compute_sa and full_plot

forecast.R        (no dependency on other files, needs package `forecast`)
```

Function level:

| Function | Calls |
|---|---|
| `moving_average` | none |
| `seasonal_coefficients` | `moving_average` |
| `compute_sa` | none |
| `time_plot` | none |
| `seasonal_plot` | none |
| `full_plot` | `time_plot`, `moving_average`, `compute_sa`, `seasonal_coefficients` |
| `time_series_study` | `moving_average`, `seasonal_coefficients`, `compute_sa`, `full_plot` |
| `prediction` | `forecast::ets`, `forecast::forecast` |

To use only the forecasting part, `forecast.R` can be sourced alone.

## Common arguments

| Argument | Meaning |
|---|---|
| `y` | numeric vector of observations (length must be a multiple of `p` for seasonal functions) |
| `p` | periodicity (12 for monthly data, 4 for quarterly, 7 for daily data with a weekly cycle) |
| `m` | model, `"A"` for additive or `"M"` for multiplicative |
| `ylab`, `xlab` | axis labels |
| `h` | forecast horizon (number of periods) |

## Functions

### decomposition.R

`moving_average(y, p)`
Centered moving average of order `p`, used as an estimate of the trend. For an even `p`, the two end points get a weight of 1/2 (2 x p moving average). Returns a vector of the same length as `y`, with `NA` at the first and last `floor(p/2)` positions.

`seasonal_coefficients(y, p, m)`
Estimates the seasonal coefficients. It computes the deviation between `y` and its moving average (difference if `m = "A"`, ratio if `m = "M"`), arranges the deviations in a matrix with one column per position in the cycle, takes the median of each column, then subtracts the mean of these medians so the coefficients are centered. Returns a vector of length `p`.

`compute_sa(y, S, m)`
Seasonally adjusted (SA) series. Returns `y - S` if `m = "A"` or `y / (1 + S)` if `m = "M"`. `S` is the vector of coefficients returned by `seasonal_coefficients`, recycled over the whole series.

### plots.R

`time_plot(y, ylab, xlab)`
Time plot of the series, with one tick per observation.

`seasonal_plot(y, p, ylab, xlab, legend)`
Seasonal plot: one line per cycle (year), all superimposed on positions `1:p`. `legend` is a vector of two elements: the label of the cycles (for example `"Year"`) and the number of the first cycle (for example `2012`).

`full_plot(y, p, m, ylab, xlab)`
Time plot of the raw series with the smoothed series (moving average, in red) and the SA series (in blue) added.

### study.R

`time_series_study(y, p, m, ylab, xlab)`
Full classical decomposition study. It computes the moving average, the seasonal coefficients and the SA series, fits a linear regression of the SA series on time, computes the residuals, draws `full_plot` and the correlogram of the residuals. Returns a list:

| Element | Content |
|---|---|
| `MM` | moving average (smoothed series) |
| `Shat` | seasonal coefficients |
| `yCVS` | seasonally adjusted series |
| `modele` | `lm` object of the trend (SA series ~ time) |
| `e` | residuals of the trend fit |

### forecast.R

`prediction(y, p, m, h)`
Fits four exponential smoothing models with `forecast::ets` on `ts(y, frequency = p)`, optimizing the MSE, and forecasts `h` periods ahead. `m` is used as the error type of the ETS models.

| Name | ETS model | Handles trend | Handles seasonality |
|---|---|---|---|
| simple | (m, N, N) | no | no |
| double | (m, A, N), not damped | yes | no |
| holt | (m, A, N), damped | yes (damped) | no |
| winters | (m, A, A) | yes | yes |

Returns a list with the forecasts (`yalpha_simple`, `yalpha_double`, `yalpha_holt`, `yalpha_winters`, as `ts` objects of length `h`) and the in-sample MSE of each model (`mse_simple`, `mse_double`, `mse_holt`, `mse_winters`).

## Example

```r
source("R/load.R")

# y: numeric vector, 72 monthly observations (2012-2017)
res  <- time_series_study(y, p = 12, m = "A",
                          ylab = "Electricity consumption (MW)",
                          xlab = "Month")
res$Shat      # seasonal coefficients
summary(res$modele)   # trend significance

pred <- prediction(y, p = 12, m = "A", h = 12)
pred$yalpha_winters   # Holt-Winters forecast for the next 12 months
pred$mse_winters      # in-sample MSE
```

The full worked example (monthly French electricity consumption, trend analysis, residual validation, comparison of the four forecasts against the observed 2018 values) is in `example/electricity_analysis.Rmd`, with its rendered version `example/electricity_analysis.pdf`.

## Notes

- Length of `y` must be a multiple of `p`, otherwise `seasonal_coefficients` cannot build its matrix.
- The in-sample MSE returned by `prediction` measures the fit, not the forecast quality. Compare forecasts to held-out observations to judge them.
- In multiplicative mode, the coefficients are centered around 0 (not 1), hence the `1 + S` in `compute_sa`.

## Data

Electricity consumption from RTE's éCO2mix application, published as open data on ODRÉ (Open Data Réseaux Énergies), dataset "Données éCO2mix nationales consolidées et définitives". `example/data_monthly.csv` contains the monthly means of the 30-minute measurements.
