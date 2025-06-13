# 01_data_cleaning.R
# ------------------
# Purpose: Clean and prepare data for CAPM model
# Author: Team PEC (Praise, Edwell, Chen)

# Load libraries
library(tidyverse)
library(lubridate)
library(quantmod)
library(dplyr)
library(lubridate)

# Load raw stock price data
stock_data <- read_csv("D:/stock.csv")

names(stock_data)
head(stock_data)
getSymbols("DTB3", src = "FRED")
rf_xts <- na.omit(DTB3) / 100
write.zoo(rf_data, file = "C:/Users/MI/Desktop/RR Project/data/risk_free_rate.csv", sep = ",")


# Convert to data.frame and clean
rf_data <- data.frame(Date = index(rf_xts), Rf = coredata(rf_xts)) %>%
  mutate(Date = ymd(Date)) %>%
  arrange(Date)
names(rf_data)
colnames(rf_data)[2] <- "Rf"

# Clean and prepare risk-free rate data
rf_data <- rf_data %>%
  mutate(Date = ymd(Date)) %>%
  arrange(Date)

# 3. Check if stock_data contains returns or prices
# -----------------------
# If your stock_data contains prices, calculate daily returns:
# Assuming the first column is Date and others are stock prices
stock_data <- stock_data %>%
  mutate(Date = ymd(Date)) %>%
  arrange(Date)

# Calculate returns (excluding Date)
returns_data <- stock_data %>%
  arrange(Date) %>%
  mutate(across(-Date, ~ (.-lag(.)) / lag(.))) %>%
  drop_na()

# Let's assume:
# - AAPL is the stock you're analyzing (Ri)
# - sp500 is the market (Rm)
# Rename for clarity
returns_data <- returns_data %>%
  rename(Ri = AAPL, Rm = sp500)

# -----------------------
# 4. Merge with risk-free rate
# -----------------------
merged_data <- returns_data %>%
  left_join(rf_data, by = "Date") %>%
  mutate(
    Ri_excess = Ri - Rf,
    Rm_excess = Rm - Rf
  )

# -----------------------
# 5. Save cleaned dataset
# -----------------------
write_csv(merged_data, "C:/Users/MI/Desktop/RR Project/data/cleaned_data.csv")
