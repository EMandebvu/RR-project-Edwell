
library(plotly)
library(tidyverse)
library(dygraphs)
library(ggplot2)
library(readr)
df <- read_csv("C:/Users/MI/Desktop/RR Project/data/cleaned_data.csv")


head(df)
# Function to normalize prices based on the initial (first) value
normalize_prices <- function(df) {
  df_norm <- df
  for (col in names(df)[-1]) {
    first_value <- df[[col]][which(!is.na(df[[col]]))[1]]  
    df_norm[[col]] <- df[[col]] / first_value
  }
  return(df_norm)
}

# Step 1: Convert Date column to Date format
df$Date <- as.Date(df$Date)

# Step 2: Select only the stock returns (exclude Ri and Rm for now)
returns_df <- df %>%
  select(Date, BA, T, MGM, AMZN, IBM, TSLA, GOOG, Ri, Rm)

# Step 3: Convert daily returns into cumulative index (starting from 100)
cumulative_df <- returns_df
cumulative_df[,-1] <- apply(returns_df[,-1], 2, function(x) cumprod(1 + x) * 100)

# Step 4: Plot interactive line chart
interactive_plot <- function(df, title) {
  fig <- plot_ly()
  
  for (col_name in colnames(df)[-1]) {
    fig <- fig %>%
      add_trace(x = df$Date,
                y = df[[col_name]],
                type = 'scatter',
                mode = 'lines',
                name = col_name)
  }
  
  fig <- fig %>%
    layout(title = title,
           xaxis = list(title = "Date"),
           yaxis = list(title = "Index Value (Base = 100)"))
  
  return(fig)
}
# Step 5: Run the function to generate the chart
interactive_plot(cumulative_df, "Stock Performance Indexed to 100")

# Calculate average daily return using dplyr
avg_daily_returns <- df %>%
  select(-Date) %>%
  summarise(across(everything(), ~ mean(.x, na.rm = TRUE)))

print(avg_daily_returns)

# Select any stock, let's say Apple(Ri)
df$Ri
# Select the market returns (Rm), e.g., S&P 500
head(df$Rm)

# Plot a scatter plot between the selected stock (Ri) and the market (Rm)

ggplot(df, aes(x = Rm, y = Ri)) +
  geom_point(color = "darkgreen") +
  labs(
    title = "Scatter Plot: Stock vs Market Returns",
    x = "Market Return (S&P 500)",
    y = "Stock Return (AAPL)"
  ) +
  theme_minimal()

# Fit linear model: AAPL ~ sp500
## Create new columns: convert daily returns to percentages (to match Python's result)）
df$Ri_pct <- df$Ri * 100
df$Rm_pct <- df$Rm * 100

# Run linear regression using percentage returns
model <- lm(Ri_pct ~ Rm_pct, data = df)
beta <- coef(model)[["Rm_pct"]]
alpha <- coef(model)[["(Intercept)"]]
cat("Beta for AAPL stock is =", round(beta, 3), "and alpha is =", round(alpha, 3), "\n")

# Scatter plot with fitted regression line: y = beta * x + alpha
ggplot(df, aes(x = Rm_pct, y = Ri_pct)) +
  geom_point(color = "blue") +  # Scatter points
  geom_abline(intercept = alpha, slope = beta, linetype = "dashed", color = "red") +  # Regression line
  labs(
    title = "Scatter Plot: AAPL vs S&P500 Returns",
    x = "Market Return (S&P 500, %)",
    y = "AAPL Return (%)"
  ) +
  theme_minimal()


# Fit a linear model: TSLA return ~ S&P500 return
df$TSLA_pct <- df$TSLA * 100
df$Rm_pct <- df$Rm * 100

# Run linear regression using percentage returns
model <- lm(TSLA_pct ~ Rm_pct, data = df)
beta <- coef(model)[["Rm_pct"]]
alpha <- coef(model)[["(Intercept)"]]
# Print result
cat("Beta for TSLA stock is =", round(beta, 3), "and alpha is =", round(alpha, 3), "\n")



# Plot with regression line
ggplot(df, aes(x = Rm_pct, y = TSLA_pct)) +
  geom_point(color = "blue") +
  geom_abline(intercept = alpha, slope = beta, color = "green") +
  labs(
    title = "Scatter Plot: TSLA vs S&P500 Returns",
    x = "S&P500 Return (%)",
    y = "TSLA Return (%)"
  ) +
  theme_minimal()

beta <- coef(model)
print(beta)
# Calculate the average daily return of the S&P 500
mean_sp500 <- mean(df$Rm, na.rm = TRUE)
mean_sp500_percent <- mean_sp500 * 100  
options(digits = 3)
print(mean_sp500_percent)

# Calculate the average daily return of the S&P500
mean_sp500 <- mean(df$Rm, na.rm = TRUE)

# Annualize the return by multiplying by 252 trading days in a year
# (252 is commonly used in finance to represent trading days)
rm <- round(mean_sp500 * 252, 3)

# Print the annualized return
cat("Annualized return of S&P500:", rm, "\n")

rf <- 0.66              # risk-free rate in %
rm <- 12.4            # market return in %

beta <- 1.269          # previously calculated beta

# CAPM expected return for AAPL
ER_AAPL <- round(rf + beta * (rm - rf), 3)

# Output the result
cat("Expected return of AAPL using CAPM is:", ER_AAPL, "%\n")


# Convert returns to percentage for T and market return (Rm)
df$T_pct <- df$T * 100
df$Rm_pct <- df$Rm * 100  # Make sure Rm is your market return column

# Fit linear regression model: T_pct ~ Rm_pct
model <- lm(T_pct ~ Rm_pct, data = df)

# Extract beta (slope) and alpha (intercept)
beta <- coef(model)[["Rm_pct"]]
alpha <- coef(model)[["(Intercept)"]]

# Print results
cat(sprintf("Beta for %s stock is = %.3f and alpha is = %.3f\n", "T", beta, alpha))

# Calculate expected return for AT&T using CAPM
# rf: risk-free rate
# beta: beta of AT&T
# rm: expected market return

ER_T <- round(rf + (beta * (rm - rf)), 3)
print(ER_T)


# Create empty data frame to store results
results <- data.frame(
  Stock = character(),
  Beta = numeric(),
  Alpha = numeric(),
  stringsAsFactors = FALSE
)

# Loop over each stock column
stock_columns <- setdiff(names(df), c("Date", "Rm", "Rf", "Ri_excess", "Rm_excess","TSLA_pct", "Ri_pct", "Rm_pct", "T_pct"))

for (stock in stock_columns) {
  
  # Fit linear model: stock return ~ market return
  model <- lm(I(df[[stock]] * 100) ~ I(df$Rm * 100))
  beta <- coef(model)[2]
  alpha <- coef(model)[1]
  
  # Save Beta and Alpha
  results <- rbind(results, data.frame(Stock = stock, Beta = beta, Alpha = alpha))
  
  # Create data frame for plotting
  sp500_vals <- df$Rm
  fitted_vals <- beta * sp500_vals + alpha
  plot_data <- data.frame(
    sp500 = sp500_vals,
    stock = df[[stock]],
    fitted = fitted_vals
  )
  
  # Interactive scatter plot
  fig <- plot_ly(plot_data, x = ~sp500, y = ~stock, type = 'scatter', mode = 'markers', name = stock) %>%
    add_lines(y = ~fitted, name = 'Regression Line') %>%
    layout(title = stock,
           xaxis = list(title = "S&P500 Return"),
           yaxis = list(title = paste(stock, "Return")))
  
  print(fig) 
}

# Round and print results
results$Beta <- round(results$Beta, 3)
results$Alpha <- round(results$Alpha, 3)
print(results)


# Assume your dataframe is called df, with columns "Date", "sp500", and stocks

# Create empty lists to store beta and alpha values
beta <- list()
alpha <- list()

# Get all stock columns except "Date" and "sp500"
stock_columns <- setdiff(names(df), c("Date", "Rm", "Rf", "Ri_excess", "Rm_excess","TSLA_pct", "Ri_pct", "Rm_pct", "T_pct"))

for (stock in stock_columns) {
  
  # Fit linear regression: stock returns ~ sp500 returns
  model <- lm(df[[stock]] ~ df$Rm)
  b <- coef(model)[2]  # beta (slope)
  a <- coef(model)[1]  # alpha (intercept)
  
  # Save beta and alpha to the lists
  beta[[stock]] <- b
  alpha[[stock]] <- a
  
  # Prepare data for plotting
  plot_data <- data.frame(
    sp500 = df$Rm,
    stock = df[[stock]]
  )
  
  # Plot scatter + regression line using ggplot2
  p <- ggplot(plot_data, aes(x = sp500, y = stock)) +
    geom_point(color = "blue") +
    geom_abline(intercept = a, slope = b, color = "darkred") +
    ggtitle(stock) +
    xlab("S&P 500 Return") +
    ylab(paste0(stock, " Return")) +
    theme_minimal()
  
  print(p)
}

# Check beta and alpha values
beta
alpha

keys <- names(beta)
print(keys)


# Define an empty list to store expected returns
ER <- list()

# Risk-free rate
rf <- 0.66

# Calculate the expected annualized market return
# Assuming daily returns and 252 trading days in a year
rm <- round(mean(df$Rm) * 252 * 100, 1)
print(rm)

# Assume rf, rm, beta are defined; keys is names(beta)
ER <- list()  # empty list to store expected returns

for (i in keys) {
  ER[[i]] <- rf + beta[[i]] * (rm - rf)
  cat(sprintf("Expected Return Based on CAPM for %s is %.3f%%\n", i, ER[[i]]))
}

# Assume equal weights in the portfolio (8 assets)
portfolio_weights <- rep(1/8, 8)
portfolio_weights

# Calculate portfolio expected return
ER_numeric <- sapply(ER, as.numeric)
ER_portfolio_all <- round(sum(ER_numeric * portfolio_weights), 3)
cat(sprintf("Expected Return Based on CAPM for the portfolio is %.3f%%\n", ER_portfolio_all))

# Calculate the portfolio return in R
ER_portfolio <- round(0.50 * ER[["Ri"]] + 0.50 * ER[["AMZN"]], 3)

# Print the result
cat(sprintf("Expected Return Based on CAPM for the portfolio (50%% allocation in Apple and 50%% in Amazon) is %.3f%%\n", ER_portfolio))


# Calculate the portfolio return in R (Consumer Services: 50% T, 50% MGM)
ER_portfolio_ConsumerServices <- round(0.50 * ER[["T"]] + 0.50 * ER[["MGM"]], 3)

# Print the result
cat(sprintf("Expected Return Based on CAPM for the portfolio (Consumer Services) is %.3f%%\n", ER_portfolio_ConsumerServices))

# Calculate the portfolio return in R (Manufacturing Sector: 50% TSLA, 50% BA)
ER_portfolio_Manufacturing <- round(0.50 * ER[["TSLA"]] + 0.50 * ER[["BA"]], 3)

# Print the result
cat(sprintf("Expected Return Based on CAPM for the portfolio (Manufacturing Sector) is %.3f%%\n", ER_portfolio_Manufacturing))

# Calculate the portfolio return in R (Personal Devices Sector: AAPL, IBM, GOOG, AMZN each 25%)
ER_portfolio_PersonalDevices <- round(
  0.25 * ER[["Ri"]] + 
    0.25 * ER[["IBM"]] + 
    0.25 * ER[["GOOG"]] + 
    0.25 * ER[["AMZN"]], 
  3
)

# Print the result
cat(sprintf("Expected Return Based on CAPM for the portfolio (Personal Devices Sector) is %.3f%%\n", 
            ER_portfolio_PersonalDevices))

# Calculate portfolio return in R (Less than Market Return portfolio: T, IBM, GOOG, AMZN each 25%)
ER_portfolio_bm <- round(
  0.25 * ER[["T"]] + 
    0.25 * ER[["IBM"]] + 
    0.25 * ER[["GOOG"]] + 
    0.25 * ER[["AMZN"]],
  3
)

# Print the result
cat(sprintf("Expected Return Based on CAPM for the portfolio (Less than Market Return) is %.3f%%\n", ER_portfolio_bm))

ER_portfolio_am <- round(
  0.25 * ER[["Ri"]] + 
    0.25 * ER[["BA"]] + 
    0.25 * ER[["MGM"]] + 
    0.25 * ER[["TSLA"]],
  1
)

cat(sprintf("Expected Return Based on CAPM for the portfolio (Above than Market Return) is %.3f%%\n", ER_portfolio_am))




sum_ER <- 0
for (i in keys) {
  sum_ER <- sum_ER + ER[[i]]
}

for (i in keys) {
  contribution <- round(ER[[i]] / sum_ER, 2)
  cat(sprintf("Contribution on CAPM for %s is %.2f\n", i, contribution))
}

ER_portfolio_b <- round(
  0.12 * ER[['Ri']] + 0.15 * ER[['BA']] + 0.08 * ER[['T']] + 0.18 * ER[['MGM']] +
    0.11 * ER[['AMZN']] + 0.11 * ER[['IBM']] + 0.14 * ER[['TSLA']] + 0.11 * ER[['GOOG']], 3
)

cat(sprintf("Expected Return Based on CAPM for the portfolio (Balanced Weightage) is %.3f%%\n", ER_portfolio_b))


ER_portfolio_hp <- round(0.33 * ER[['TSLA']] + 0.33 * ER[['BA']] + 0.34 * ER[['MGM']], 3)

cat(sprintf("Expected Return Based on CAPM for the portfolio (High performing) is %.3f%%\n", ER_portfolio_hp))


ER_portfolio_lp <- round(0.33 * ER[['T']] + 0.33 * ER[['GOOG']] + 0.34 * ER[['IBM']], 3)

cat(sprintf("Expected Return Based on CAPM for the portfolio (Weak performing) is %.3f%%\n", ER_portfolio_lp))

ER_portfolio_ap <- round(as.numeric(ER[["Ri"]]), 3)
cat(sprintf("Expected Return Based on CAPM for the portfolio (Average performing) is %.3f%%\n", ER_portfolio_ap))


ER_portfolio_ed <- round(0.50 * as.numeric(ER[["T"]]) + 0.50 * as.numeric(ER[["MGM"]]), 3)
cat(sprintf("Expected Return Based on CAPM for the portfolio (Extremes) is %.3f%%\n", ER_portfolio_ed))

ER_portfolio_median <- round(0.50 * as.numeric(ER[["GOOG"]]) + 0.50 * as.numeric(ER[["Ri"]]), 3)
cat(sprintf("Expected Return Based on CAPM for the portfolio (Median) is %.3f%%\n", ER_portfolio_median))

# Create a data frame
data <- data.frame(
  Combinations = c('AAPL', 'BA', 'T', 'MGM', 'AMZN', 'IBM', 'TSLA', 'GOOG', 'Equal Portfolio Weights',
                   'AAPL+AMZN', 'Consumer Services', 'Manufacturing Sector', 'Personal Devices Sector',
                   'Less than Market Return', 'Above than Market Return', 'Balanced Weightage',
                   'High performing', 'Weak performing', 'Average performing', 'Extremes', 'Median'),
  Expected_Return_Based_on_CAPM = c(13.757,16.934,9.423,20.119,12.331,11.962,15.589,12.838,14.119,
                                    13.044,14.771,16.261,12.722,11.639,16.6,14.833,17.573,11.413,
                                    13.757,14.771,13.298)
)

# Sort the data frame by expected return in descending order
Returns <- data %>%
  arrange(desc(Expected_Return_Based_on_CAPM))

print(Returns)

print("Top 5 Suggested Portfolio")
head(Returns, 5)

print("Bottom 5 Suggested Portfolio") 
tail(Returns, 5)
