# Who Really Pays for the Tariffs?

**Data Bit 3 — Data Journalism**
**Author:** Ashley Razo
**Date:** May 2026

---

## What I Did

This Data Bit examines the distributional impact of the 2025 U.S. tariff package — specifically, who bears the cost as a share of income. The central argument: tariffs function as a regressive tax, hitting the poorest Americans 2.5 times harder than the wealthiest as a share of disposable income. A second chart shows *why*: the goods hit hardest — clothing, footwear, food — are necessities that low-income households cannot opt out of.

### Technique
- **Programmatic work:** R (`readr`, `dplyr`, `ggplot2`, `forcats`) for full import → validate → visualize pipeline
- **Interactive visualization:** D3.js embedded in `index.html` — two horizontal bar charts with hover tooltips
- **Design principles:** Ordered by magnitude (not alphabetically), CVD-safe colors, zero-based axes, direct labels, explicit legend only where needed

---

## Repository Structure

```
├── index.html                        # Final article (interactive D3 charts)
├── analysis.R                        # R pipeline: import → validate → figures
├── data/
│   ├── tariff_burden_by_income.csv   # Income decile burden (Yale Budget Lab)
│   └── tariff_commodity_prices.csv   # Commodity price increases (Yale Budget Lab)
├── figures/
│   ├── fig1_burden_by_income.png     # Static Fig 1 (R output)
│   └── fig2_commodity_prices.png     # Static Fig 2 (R output)
└── README.md
```

`index.html` contains interactive D3 visualizations built from the same underlying data as `figures/`. The two are parallel representations — `figures/` exists to document the reproducible R pipeline.

---

## Data Source & Pipeline

**Primary source:** Yale Budget Lab  
*"Where We Stand: Distributional Effects of All U.S. Tariffs Enacted in 2025 Through April 2"* (April 2, 2025)  
[budgetlab.yale.edu](https://budgetlab.yale.edu/research/where-we-stand-fiscal-economic-and-distributional-effects-all-us-tariffs-enacted-2025-through-april)  
Original data file: `TBL Data April 2 Tariffs 202504.xlsx` (downloadable from Yale Budget Lab)

**Secondary source:** Yale Budget Lab October 30, 2025 update  
[budgetlab.yale.edu](https://budgetlab.yale.edu/research/state-us-tariffs-october-30-2025)

**Pipeline:**
1. Key figures from Yale Budget Lab reports transcribed into `data/` CSVs
2. `analysis.R` imports both CSVs with `readr::read_csv()`
3. Data validated with `stopifnot()` checks before plotting
4. Two `ggplot2` figures saved to `figures/`

**Note:** All burden estimates are short-run figures before household substitution, assuming full pass-through of tariff costs to consumer prices. Long-run estimates show a smaller but still regressive burden.

---

## How to Reproduce

1. Clone this repository
2. Install required R packages:
   ```r
   install.packages(c("readr", "dplyr", "ggplot2", "scales", "forcats"))
   ```
3. Open `analysis.R` in RStudio, set working directory to repo root (Session → Set Working Directory → To Source File Location), then click **Source**
4. Figures save to `figures/`
5. Open `index.html` in any browser to view the interactive article

---

## 🔗 View the Final Piece

👉 **[Click here to read the article](https://raw.githack.com/data-journalism-26/data-bit-3-ashley-razo/main/index.html)**
