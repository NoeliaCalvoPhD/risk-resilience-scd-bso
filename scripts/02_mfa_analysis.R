################################################
# Multiple Factor Analysis (MFA)
################################################

library(FactoMineR)
library(factoextra)
library(dplyr)

# Load processed dataset
data <- read.csv("data/processed/data_imputed.csv")

# Run MFA
res.mfa <- MFA(
  data,
  group = c(4, 3, 7),
  type = c("c", "s", "s"),
  name.group = c("Group", "Multilingualism", "Health"),
  graph = FALSE
)

# Save results
save(res.mfa, file = "results/mfa_results.RData")

# Eigenvalues
eig.val <- get_eigenvalue(res.mfa)

write.csv(eig.val, "results/tables/eigenvalues.csv")