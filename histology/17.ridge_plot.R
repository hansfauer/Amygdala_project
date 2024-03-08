
install.packages("ggplot2")
install.packages("ggridges")
install.packages("cowplot")
install.packages("dplyr")
install.packages("forcats")

library("ggplot2")
library("ggridges")
library("cowplot")
library("dplyr")
library("forcats")


# Load data
df_CohenY <- read.csv('/data_/mica1/03_projects/hans/7T/outputs/amyg_L_100seg_table_ero5.csv', header=TRUE)
df_CohenY$u1 = as.numeric(df_CohenY$u1)
df_CohenY$u2 = as.numeric(df_CohenY$u2)

colnames(df_CohenY) <- c("U1", "U2" ,"CM", "SF", "LB")

#creating dataframes where all rows with 0 values are discarded
df_embed11 <- data.frame(df_CohenY$U1, df_CohenY$CM)
df_embed11 <- df_embed11[apply(df_embed11, 1, function(row) all(row !=0 )), ]
df_embed11["df_CohenY.CM"][df_embed11["df_CohenY.CM"] == 1] <- "CM"
#creating dataframe where all rows with 0 values are discarded
df_embed12 <- data.frame(df_CohenY$U1, df_CohenY$SF)
df_embed12 <- df_embed12[apply(df_embed12, 1, function(row) all(row !=0 )), ]
df_embed12["df_CohenY.SF"][df_embed12["df_CohenY.SF"] == 1] <- "SF"
#creating dataframe where all rows with 0 values are discarded
df_embed13 <- data.frame(df_CohenY$U1, df_CohenY$LB)
df_embed13 <- df_embed13[apply(df_embed13, 1, function(row) all(row !=0 )), ]
df_embed13["df_CohenY.LB"][df_embed13["df_CohenY.LB"] == 1] <- "LB"
#creating dataframe where all rows with 0 values are discarded
df_embed21 <- data.frame(df_CohenY$U2, df_CohenY$CM)
df_embed21 <- df_embed21[apply(df_embed21, 1, function(row) all(row !=0 )), ]
df_embed21["df_CohenY.CM"][df_embed21["df_CohenY.CM"] == 1] <- "CM"
#creating dataframe where all rows with 0 values are discarded
df_embed22 <- data.frame(df_CohenY$U2, df_CohenY$SF)
df_embed22 <- df_embed22[apply(df_embed22, 1, function(row) all(row !=0 )), ]
df_embed22["df_CohenY.SF"][df_embed22["df_CohenY.SF"] == 1] <- "SF"
#creating dataframe where all rows with 0 values are discarded
df_embed23 <- data.frame(df_CohenY$U2, df_CohenY$LB)
df_embed23 <- df_embed23[apply(df_embed23, 1, function(row) all(row !=0 )), ]
df_embed23["df_CohenY.LB"][df_embed23["df_CohenY.LB"] == 1] <- "LB"

#bind all dataframes representing U1 values
colnames(df_embed11) <- c("U1", "SEG")
colnames(df_embed12) <- c("U1", "SEG")
colnames(df_embed13) <- c("U1", "SEG")
df1 <- rbind(df_embed11,df_embed12,df_embed13)

#bind all dataframes representing U2 values
colnames(df_embed21) <- c("U2", "SEG")
colnames(df_embed22) <- c("U2", "SEG")
colnames(df_embed23) <- c("U2", "SEG")
df2 <- rbind(df_embed21,df_embed22,df_embed23)

p1 <- ggplot(df1, aes(x=U1, y=SEG, fill=SEG)) +
  geom_density_ridges(quantile_lines = TRUE, quantiles = 2, alpha=1, scale=1.5, show.legend = FALSE, size = 1, bandwidth = 1) +
  scale_fill_manual(aesthetics = "fill", values = c("#960096", "#009696", "#9696C8")) +
  scale_x_continuous(expand = c(0.01, 0.01), limits = c(-15, 25), breaks = c(-15, -5, 5, 15, 25)) +
  scale_y_discrete(expand = c(-1, 0.1), limits = rev(levels(df1$SEG))) +
  coord_cartesian(clip = "off") +
  theme_ridges(font_size = 20,
               font_family = "Gill Sans",
               line_size = 1,
               grid = TRUE,
               center_axis_labels = FALSE)



p2 <- ggplot(df2, aes(x=U2, y=SEG, fill=SEG)) +
  geom_density_ridges(quantile_lines = TRUE, quantiles = 2, alpha=0.8, scale=1, show.legend = FALSE, size = 1, bandwidth = 1) +
  scale_fill_manual(aesthetics = "fill", values = c("#960096", "#009696", "#9696C8")) +
  scale_x_continuous(expand = c(0.01, 0.01), limits = c(-10, 15), breaks = c(-10, -5, 0, 5, 10, 15)) +
  scale_y_discrete(expand = c(-1, 0.1), limits = rev(levels(df1$SEG))) +
  coord_cartesian(clip = "off") +
  theme_ridges(font_size = 20,
               font_family = "Gill Sans",
               line_size = 1,
               grid = TRUE,
               center_axis_labels = FALSE)

#png('/data_/mica1/03_projects/hans/BIGBRAIN/figures/ridge_plots_L.png', width = 650, height = 650)
#png('~/Desktop/ridge_plots_L.png', width = 650, height = 650)
plot_grid(p1,p2,ncol=2,nrow=1)
dev.off()
