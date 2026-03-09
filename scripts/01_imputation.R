################################################
# Multiple Imputation using mice
# Author: Noelia Calvo, PhD
# Description: Handles missing data in Dataset4
################################################

set.seed(42)

# Libraries
library(mice)

# Load data
data <- read.csv("data/raw/Dataset4.csv")

# Inspect missing pattern
md.pattern(data)

# Multiple imputation
imp <- mice(data, method = "pmm", m = 5)

# Complete dataset
data_complete <- complete(imp)

# Save processed dataset
write.csv(data_complete, "data/processed/data_imputed.csv", row.names = FALSE)