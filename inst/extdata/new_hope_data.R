# nolint start
library(terra)
extdata <- system.file("extdata", package = "hyRefactor")

new_hope_fac <- suppressWarnings(terra::rast(file.path(extdata, "new_hope_fac.tif")))
new_hope_fdr <- suppressWarnings(terra::rast(file.path(extdata, "new_hope_fdr.tif")))

proj <- as.character(terra::crs(new_hope_fdr))

nhpgpkg <- tempfile(fileext = ".gpkg")

file.copy(file.path(extdata, "new_hope.gpkg"), nhpgpkg)

nhpgpkgref <- tempfile(fileext = ".gpkg")

file.copy(file.path(extdata, "new_hope_refactor.gpkg"), nhpgpkgref)

nhpgpkgrec <- tempfile(fileext = ".gpkg")

file.copy(file.path(extdata, "new_hope_reconcile.gpkg"), nhpgpkgrec)

nhpgpkgreccat <- tempfile(fileext = ".gpkg")

file.copy(file.path(extdata, "new_hope_cat_rec.gpkg"), nhpgpkgreccat)

nhpgpkgev <- tempfile(fileext = ".gpkg")

file.copy(file.path(extdata, "new_hope_event.gpkg"), nhpgpkgev)

new_hope_catchment <- sf::read_sf(nhpgpkg, "CatchmentSP")
new_hope_catchment <- sf::st_transform(new_hope_catchment, proj)
new_hope_flowline <- sf::read_sf(nhpgpkg, "NHDFlowline_Network")
new_hope_flowline <- sf::st_transform(new_hope_flowline, proj)
new_hope_fline_ref <- sf::read_sf(nhpgpkgref)
new_hope_fline_rec <- sf::read_sf(nhpgpkgrec)
new_hope_catchment_rec <- sf::read_sf(nhpgpkgreccat)
new_hope_events <- sf::read_sf(nhpgpkgev)

####
# This is how the raster data was created.
# start_COMID <- 8897784
# nhdplus_path("cape_fear_nhdplus.gpkg")
# preped_nhdplus <- stage_national_data()
# flines <- readRDS(preped_nhdplus$attributes)
# UT <- get_UT(flines, start_COMID)
# new_hope_subset <- subset_nhdplus(UT, "new_hope.gpkg", overwrite = TRUE)
# flowline <- read_sf(new_hope_subset, "NHDFlowline_Network")

# fac <- terra::rast("~/Documents/Projects/NWM/4_data/nhdplus_raster/fac/NHDPlusSA/NHDPlus03N/NHDPlusFdrFac03a/fac.tif")
# fdr <- terra::rast("~/Documents/Projects/NWM/4_data/nhdplus_raster/fdr/NHDPlusSA/NHDPlus03N/NHDPlusFdrFac03a/fdr.tif")
# proj <- terra::crs(fdr)
#
# catchment <- read_sf(new_hope_subset, "CatchmentSP") %>%
#   st_transform(proj)
#
# cropper <- catchment %>%
#   st_union() %>%
#   st_buffer(1000) %>%
#   as_Spatial()
#
# sub_fac <- terra::crop(fac, cropper)
# sub_fdr <- terra::crop(fdr, cropper)
# terra::writeRaster(sub_fac, "new_hope_fac.tif", overwrite = TRUE)
# terra::writeRaster(sub_fdr, "new_hope_fdr.tif", overwrite = TRUE)
# #####
#
# flowline <- sf::read_sf("new_hope.gpkg", "NHDFlowline_Network")
# refactor_nhdplus(nhdplus_flines = flowline,
#                  split_flines_meters = 2000,
#                  collapse_flines_meters = 1000,
#                  collapse_flines_main_meters = 1000,
#                  split_flines_cores = 2,
#                  out_refactored = "new_hope_refactor.gpkg",
#                  out_reconciled = "new_hope_reconcile.gpkg",
#                  three_pass = TRUE,
#                  purge_non_dendritic = FALSE,
#                  warn = FALSE)
#
# fline_ref <- sf::read_sf("new_hope_refactor.gpkg") %>%
#   st_transform(proj)
# fline_rec <- sf::read_sf("new_hope_reconcile.gpkg") %>%
#   st_transform(proj)
#
#
# cat_rec <- reconcile_catchment_divides(new_hope_catchment, fline_ref, fline_rec,
#                                 new_hope_fdr, new_hope_fac)
#
# sf::write_sf(cat_rec, "new_hope_cat_rec.gpkg")
# nolint end
