library(readr)
library(dplyr)
library(ggplot2)
library(scales)
library(forcats)

income <- read_csv("data/tariff_burden_by_income.csv",
  col_types = cols(
    decile            = col_integer(),
    decile_label      = col_character(),
    burden_pct_income = col_double(),
    annual_cost_usd   = col_integer()
  ))

commodity <- read_csv("data/tariff_commodity_prices.csv",
  col_types = cols(
    commodity             = col_character(),
    price_increase_pct    = col_double(),
    low_income_share_note = col_character()
  ))

cat("── Data loaded ──────────────────────────────\n")
cat("Income deciles:", nrow(income), "\n")
cat("Commodity rows:", nrow(commodity), "\n")

#validate
stopifnot(nrow(income) == 10)
stopifnot(all(income$burden_pct_income < 0))
stopifnot(!any(is.na(income$burden_pct_income)))
cat("── Validation passed ────────────────────────\n")

#summary stats
bottom <- income %>% filter(decile == 1)
top    <- income %>% filter(decile == 10)
ratio  <- abs(bottom$burden_pct_income) / abs(top$burden_pct_income)

cat("\n── Key findings ─────────────────────────────\n")
cat(sprintf("Bottom decile burden: %.1f%% of income ($%s/yr)\n",
  bottom$burden_pct_income,
  format(bottom$annual_cost_usd, big.mark = ",")))
cat(sprintf("Top decile burden:    %.1f%% of income ($%s/yr)\n",
  top$burden_pct_income,
  format(top$annual_cost_usd, big.mark = ",")))
cat(sprintf("Regressivity ratio:   %.1fx\n", ratio))
cat(sprintf("Most affected commodity: %s (+%.1f%%)\n",
  commodity %>% filter(commodity != "Average all goods") %>%
    slice_max(price_increase_pct, n=1) %>% pull(commodity),
  commodity %>% filter(commodity != "Average all goods") %>%
    slice_max(price_increase_pct, n=1) %>% pull(price_increase_pct)))

#figure 1: Burden by income decile
dir.create("figures", showWarnings = FALSE)

income_plot <- income %>%
  mutate(
    fill_group      = case_when(
      decile == 1  ~ "bottom",
      decile == 10 ~ "top",
      TRUE         ~ "middle"
    ),
    burden_display  = abs(burden_pct_income),
    decile_label    = fct_reorder(decile_label, decile)
  )

p1 <- ggplot(income_plot,
    aes(x = burden_display, y = decile_label)) +
  geom_col(aes(fill = fill_group), width = 0.7) +
  scale_fill_manual(
    values = c(bottom = "#C0392B", middle = "#7A9BB5", top = "#4A7EA5"),
    guide  = "none"
  ) +
  geom_text(aes(label = paste0(burden_display, "%")),
    hjust = -0.15, size = 3.3, color = "#333") +
  annotate("text",
    x = 3.2, y = 9.6,
    label = "Poorest pay 2.5×\nmore as share of income",
    hjust = 0, size = 3, color = "#C0392B", fontface = "italic") +
  scale_x_continuous(
    expand = expansion(mult = c(0, 0.2)),
    labels = function(x) paste0(x, "%")
  ) +
  labs(
    title    = "Tariffs hit the poorest Americans hardest",
    subtitle = "Disposable income lost from all 2025 U.S. tariffs, by income group (short-run estimates)",
    x        = "Disposable income lost (%)",
    y        = NULL,
    caption  = paste0(
      "Source: Yale Budget Lab, 'Where We Stand: Distributional Effects of All U.S. Tariffs ",
      "Enacted in 2025 Through April 2'\n",
      "(budgetlab.yale.edu, April 2, 2025). Short-run estimates before household substitution. ",
      "Figures in 2024 dollars."
    )
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title         = element_text(face = "bold", size = 13),
    plot.subtitle      = element_text(size = 10, color = "#555",
                                      margin = margin(b = 10)),
    plot.caption       = element_text(size = 8, color = "#777",
                                      hjust = 0, margin = margin(t = 10)),
    panel.grid.major.y = element_blank(),
    panel.grid.major.x = element_line(color = "#eee"),
    panel.grid.minor   = element_blank(),
    axis.text.y        = element_text(size = 10),
    plot.margin        = margin(15, 20, 15, 15)
  )

ggsave("figures/fig1_burden_by_income.png", p1,
  width = 8, height = 5.5, dpi = 150, bg = "white")
message("✓ Figure 1 saved: figures/fig1_burden_by_income.png")

#figure 2: Commodity price increases
commodity_plot <- commodity %>%
  filter(commodity != "Average all goods") %>%
  mutate(
    is_necessity = grepl("High", low_income_share_note),
    commodity    = fct_reorder(commodity, price_increase_pct)
  )

p2 <- ggplot(commodity_plot,
    aes(x = price_increase_pct, y = commodity)) +
  geom_col(aes(fill = is_necessity), width = 0.7) +
  scale_fill_manual(
    values = c("TRUE" = "#C0392B", "FALSE" = "#7A9BB5"),
    labels = c("TRUE" = "Necessity (disproportionate low-income share)",
               "FALSE" = "Other goods"),
    name   = NULL
  ) +
  geom_text(aes(label = paste0(price_increase_pct, "%")),
    hjust = -0.15, size = 3.3, color = "#333") +
  scale_x_continuous(
    expand = expansion(mult = c(0, 0.2)),
    labels = function(x) paste0(x, "%")
  ) +
  labs(
    title    = "Clothing, food, and shoes face the steepest price hikes",
    subtitle = "Estimated price increase by category under all 2025 U.S. tariffs (short-run, pre-substitution)",
    x        = "Estimated price increase (%)",
    y        = NULL,
    caption  = paste0(
      "Source: Yale Budget Lab April 2025 and October 2025 updates (budgetlab.yale.edu).\n",
      "Red = categories where low-income households spend a disproportionately large budget share.\n",
      "Pharmaceuticals partially exempt from tariffs as of publication date."
    )
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title         = element_text(face = "bold", size = 13),
    plot.subtitle      = element_text(size = 10, color = "#555",
                                      margin = margin(b = 10)),
    plot.caption       = element_text(size = 8, color = "#777",
                                      hjust = 0, margin = margin(t = 10)),
    panel.grid.major.y = element_blank(),
    panel.grid.major.x = element_line(color = "#eee"),
    panel.grid.minor   = element_blank(),
    legend.position    = "top",
    legend.text        = element_text(size = 9),
    axis.text.y        = element_text(size = 10),
    plot.margin        = margin(15, 20, 15, 15)
  )

ggsave("figures/fig2_commodity_prices.png", p2,
  width = 8, height = 5.5, dpi = 150, bg = "white")
message("✓ Figure 2 saved: figures/fig2_commodity_prices.png")
