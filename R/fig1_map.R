# fig1_map.R
# Last updated: Sept 29, 2026
# Fig 1: NRS05 location on the US West Coast (a) and in the Channel Islands (b).

library(ggOceanMaps)
library(cowplot)

site <- data.frame(lon = -119.58, lat = 33.897)
zoom <- c(-121, -118.5, 33.2, 34.6)

box <- data.frame(lon = zoom[c(1, 2, 2, 1, 1)], lat = zoom[c(3, 3, 4, 4, 3)])

a <- basemap(limits = c(-131, -114, 29, 49), bathymetry = TRUE, bathy.style = "rcb", legends = FALSE) +
  geom_path(data = transform_coord(box), aes(x = lon, y = lat), color = "black", linewidth = 0.6) +
  geom_point(data = transform_coord(site), aes(x = lon, y = lat), color = "red", size = 2.5)

b <- basemap(limits = zoom, bathymetry = TRUE, bathy.style = "rcb") +
  geom_point(data = transform_coord(site), aes(x = lon, y = lat), color = "red", size = 4)

fig <- plot_grid(a, b, labels = c("(a)", "(b)"), rel_widths = c(0.8, 1.2))
ggsave("figures/fig1_map.png", fig, width = 11, height = 5.5, dpi = 300, bg = "white")
