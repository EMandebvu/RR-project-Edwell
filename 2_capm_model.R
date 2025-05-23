
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


# Loop over each stock column except 'Date' and 'sp500'
stock_columns <- setdiff(names(df), c("Date", "Rm", "Rf", "Ri_excess", "Rm_excess","TSLA_pct", "Ri_pct", "Rm_pct", "T_pct"))

for (stock in stock_columns) {
  
  # Fit linear model
  model <- lm(df[[stock]] ~ df$Rm)
  beta <- coef(model)[2]
  alpha <- coef(model)[1]
  
  # Create data frame for regression line
  sp500_vals <- df$Rm
  fitted_vals <- beta * sp500_vals + alpha
  
  # Combine into one dataframe
  plot_data <- data.frame(
    sp500 = sp500_vals,
    stock = df[[stock]],
    fitted = fitted_vals
  )
  
  # Plot interactive scatter + regression line
  fig <- plot_ly(plot_data, x = ~sp500, y = ~stock, type = 'scatter', mode = 'markers', name = stock) %>%
    add_lines(y = ~fitted, name = 'Regression Line') %>%
    layout(title = stock,
           xaxis = list(title = "S&P500 Return"),
           yaxis = list(title = paste(stock, "Return")))
  
  print(fig) 
}






