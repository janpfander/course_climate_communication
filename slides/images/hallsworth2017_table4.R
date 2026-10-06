# Bar chart for the tax reminder slide in 04-slides.qmd.
# Data: Hallsworth, List, Metcalfe & Vlaev (2017), Journal of Public Economics,
# Table 4, column (I), Experiment 1: marginal effect of each message on paying
# within 23 days, compared with the standard reminder letter (35.8% paid).
# Run from the repo root: Rscript slides/images/hallsworth2017_table4.R
library(ggplot2)

d <- data.frame(
  message = c(
    "\"Nine out of ten people pay their tax on time.\"",
    "\"Nine out of ten people in the UK pay their tax on time.\"",
    "\"Nine out of ten people in the UK pay their tax on time.\nYou are currently in the very small minority of people\nwho have not paid us yet.\"",
    "\"Paying tax means we all gain from vital public services\nlike the NHS, roads, and schools.\"",
    "\"Not paying tax means we all lose out on vital public\nservices like the NHS, roads, and schools.\""
  ),
  group = c(rep("Social norms", 3), rep("Public services", 2)),
  effect = c(1.3, 2.1, 3.8, 1.6, 1.6)
)
d$message <- factor(d$message, levels = rev(d$message))
d$group <- factor(d$group, levels = c("Social norms", "Public services"))

p <- ggplot(d, aes(x = effect, y = message)) +
  geom_col(fill = "#094568", width = 0.55) +
  geom_text(aes(label = sprintf("+%.1f", effect)), hjust = -0.2, size = 6, colour = "#2b2b2b") +
  facet_grid(group ~ ., scales = "free_y", space = "free_y", switch = "y") +
  scale_x_continuous(limits = c(0, 4.6), expand = c(0, 0)) +
  labs(
    x = "More people paying within 23 days, in percentage points\n(standard reminder letter: 35.8% paid)",
    y = NULL
  ) +
  theme_minimal(base_size = 17) +
  theme(
    plot.background = element_rect(fill = "#fdf8ec", colour = NA),
    panel.background = element_rect(fill = "#fdf8ec", colour = NA),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_line(colour = "#e6dfcc", linewidth = 0.4),
    strip.placement = "outside",
    strip.text.y.left = element_text(angle = 90, face = "bold", colour = "#660d20", size = 13),
    axis.text.y = element_text(colour = "#2b2b2b", size = 14, lineheight = 0.95, hjust = 0),
    axis.text.x = element_text(colour = "#2b2b2b"),
    axis.title.x = element_text(colour = "#2b2b2b", size = 15, margin = margin(t = 10)),
    plot.margin = margin(10, 20, 10, 10)
  )

ggsave("slides/images/hallsworth2017_table4.png", p, width = 13, height = 6.2, dpi = 160)
