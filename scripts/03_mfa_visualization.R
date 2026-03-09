################################################
# MFA Visualization
################################################

library(factoextra)
library(ggplot2)

load("results/mfa_results.RData")

# Scree plot
p1 <- fviz_screeplot(res.mfa)
ggsave("results/figures/scree_plot.png", p1)

# Variable correlation circle
p2 <- fviz_mfa_var(
  res.mfa,
  "quanti.var",
  col.var = "contrib",
  gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
  repel = TRUE
)

ggsave("results/figures/correlation_circle.png", p2)

# Contributions
p3 <- fviz_contrib(
  res.mfa,
  choice = "quanti.var",
  axes = 1,
  top = 20
)

ggsave("results/figures/contribution_dim1.png", p3)