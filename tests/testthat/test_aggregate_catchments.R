context("aggregate catchment")

test_that("walker aggregate runs", {
source(system.file("extdata", "walker_data.R", package = "hyRefactor"))

  walker_catchment_rec <- hyRefactor::clean_geometry(
    nhdplusTools:::check_valid(walker_catchment_rec), 
    keep = NULL, crs = 5070)
  
  
get_id <- function(mc) {
  ind <- match(mc, walker_catchment_rec$member_COMID)
  walker_catchment_rec$ID[ind]
}

outlets <- data.frame(ID = get_id(c("5329843", "5329339.1", "5329385", "5329303")),
                      type = c("outlet", "outlet", "outlet", "terminal"),
                      stringsAsFactors = FALSE)


aggregated       <- aggregate_catchments(flowpath = walker_fline_rec, 
                                         divide = walker_catchment_rec,
                                         outlets)

aggregated_fline <- aggregated$fline_sets
aggregated_cat   <- aggregated$cat_sets

expect_true(all(aggregated_cat$ID %in% get_id(mc = c("5329385", "5329843", "5329339.1", "5329303"))))
expect_equal(sort(aggregated_fline$ID), sort(get_id(c("5329385", "5329843", "5329339.1", "5329303"))))
expect_true(aggregated_cat$ID[1] %in% aggregated_cat$set[[1]], "outlet ids should be in the result")
expect_true(all(aggregated_cat$set[aggregated_cat$ID == 31][[1]] %in% 
                  c(29, 30, 85, 86, 31)))
expect_equal(length(aggregated_cat$set[aggregated_cat$ID == 31][[1]]),  
                  5)
expect_true(!5 %in% aggregated_cat$set[aggregated_cat$ID == 31][[1]], 
            "an upstream outlet should not be in another set")

expect_true(length(dplyr::filter(aggregated_fline, ID == 31)$set[[1]]) == 2, 
            "got the wrong number of flowpaths")

aggregate_lookup_fline <- dplyr::select(sf::st_drop_geometry(aggregated$fline_sets), ID, set) %>%
  hyRefactor:::unnest_flines() %>%
  dplyr::rename(aggregated_ID = ID, reconciled_ID = set)

expect_true(!all(walker_fline_rec$ID %in% aggregate_lookup_fline$reconciled_ID), 
            "all input ids should not be in flowline output")

aggregate_lookup_cat <- dplyr::select(sf::st_drop_geometry(aggregated$cat_sets), ID, set) 

expect_true(all(walker_fline_rec$ID %in% unlist(aggregate_lookup_cat$set)), 
            "all input ids should be in catchment output")

expect_true(all(aggregated_cat$toID %in% get_id(c(NA, "5329843", "5329339.1", "5329303"))), info = "Expect these toIDs")

expect_true(all(aggregated_cat$toID[!is.na(aggregated_cat$toID)] %in% aggregated_cat$ID),
       "All not NA toIDs should be in IDs")

### Make sure we can run split_catchment_divide on aggregate output.
crs <- sf::st_crs(walker_fdr)
aggregated_cat <- sf::st_transform(aggregated_cat, crs)
aggregated_fline <- sf::st_transform(aggregated_fline, crs)

aggregated_cat <- aggregated_cat[match(aggregated_fline$ID, aggregated_cat$ID), ]

new_geom <- do.call(c, lapply(c(1:nrow(aggregated_cat)), function(g) {
  split_catchment_divide(catchment = aggregated_cat[g, ], 
                         fline = aggregated_fline[g, ], 
                         fdr = walker_fdr, 
                         fac = walker_fac, 
                         lr = TRUE)
}))

expect_true(all(lengths(new_geom) == 2))

outlets <- data.frame(ID = get_id(c("5329843", "5329339.1", "5329385", "5329303", "5329321")),
                      type = c("outlet", "outlet", "outlet", "terminal", "outlet"),
                      stringsAsFactors = FALSE)

aggregated <- aggregate_catchments(flowpath = walker_fline_rec, 
                                   divide = walker_catchment_rec, 
                                   outlets)

aggregated_fline <- aggregated$fline_sets
aggregated_cat <- aggregated$cat_sets

expect_equal(sort(aggregated_cat$ID), sort(get_id(c("5329321", "5329385", "5329313", "5329843", "5329339.1", "5329339.3",
                                         "5329303"))))

expect_true(length(filter(aggregated_cat, ID == 23)$set[[1]]) == 5, "got the wrong number in catchment set")

outlets <- data.frame(ID = get_id(c("5329363", "5329303")),
                      type = c("outlet", "terminal"),
                      stringsAsFactors = FALSE)

aggregated <- aggregate_catchments(walker_fline_rec, walker_catchment_rec, outlets)
aggregated_fline <- aggregated$fline_sets
aggregated_cat <- aggregated$cat_sets

expect_true(!any(aggregated_cat$set[[1]] == get_id("5329373")), "shouldn't have a parallel stem in the set")

outlets <- data.frame(ID = get_id(c("5329293", "5329303")),
                      type = c("outlet", "terminal"),
                      stringsAsFactors = FALSE)

aggregated <- aggregate_catchments(walker_fline_rec, walker_catchment_rec, outlets)
aggregated_fline <- aggregated$fline_sets
aggregated_cat <- aggregated$cat_sets

expect_true(length(aggregated_cat$set[[2]]) == 101, "got the wrong number in catchment set")

# nolint start
# sf::write_sf(aggregated$cat_sets, "walker_collapse.gpkg", "boundary")
# sf::write_sf(aggregated$fline_sets, "walker_collapse.gpkg", "flowpath")
# nolint end
})

source(system.file("extdata", "new_hope_data.R", package = "hyRefactor"))

new_hope_catchment_rec <- hyRefactor::clean_geometry(
  nhdplusTools:::check_valid(new_hope_catchment_rec), 
  keep = NULL, crs = 5070)

test_that("new_hope aggregate", {

  get_id <- function(mc) {
    ind <- match(mc, new_hope_catchment_rec$member_COMID)
    new_hope_catchment_rec$ID[ind]
  }

  #nolint start
  # # From manual testing with NHDPlus Gage layer.
  # outlets <- data.frame(ID = c(162L, 153L, 155L, 59L, 17L, 118L, 398L, 399L, 400L, 135L,
  #                              268L, 6L, 365L, 366L, 39L, 102L, 35L, 362L, 335L),
  #                       type = c("outlet", "outlet", "outlet", "outlet", "outlet",
  #                                "outlet", "outlet", "outlet", "outlet", "outlet", "outlet",
  #                                "outlet", "outlet", "outlet", "outlet", "outlet", "outlet",
  #                                "outlet", "terminal"))
  #
  # aggregated <- aggregate_catchments(new_hope_fline_rec, new_hope_catchment_rec, outlets)
  # nolint end

  outlets <- data.frame(ID = get_id(c("8896032.1", "8896032.2", "8896032.3", "8894360,8897784")),
                        type = c("outlet", "outlet", "outlet", "terminal"),
                        stringsAsFactors = FALSE)

  aggregated <- aggregate_catchments(flowpath = new_hope_fline_rec, 
                                     divide = new_hope_catchment_rec, 
                                     outlets = outlets)
  

  fline_sets <- aggregated$fline_sets
  cat_sets   <- aggregated$cat_sets

  expect_true(fline_sets$ID[1] %in% fline_sets$set[[1]],
         "A small headwater that was a divergence should show up as such")
  
  expect_true(filter(fline_sets, ID == 241)$toID == 335,
              "Something is off with topology")

  expect_true(all(fline_sets$ID %in% cat_sets$ID), "flines and cats should have the same ids")

  #nolint start
  expect_true(all(!fline_sets$set[fline_sets$ID == get_id("8894360,8897784")][[1]] %in% fline_sets$set[fline_sets$ID == get_id("8896032.1")][[1]]),
         "a downstream catchment should not contain flowpaths from upstream catchments")

  expect_true(all(!fline_sets$set[fline_sets$ID == get_id("8893780.2,8894326")][[1]] %in% fline_sets$set[fline_sets$ID == get_id("8896032.1")][[1]]),
         "a downstream catchment should not contain flowpaths from upstream catchments")

  expect_true(all(!fline_sets$set[fline_sets$ID == get_id("8896032.2")][[1]] %in% fline_sets$set[fline_sets$ID == get_id("8896032.1")][[1]]),
         "a downstream catchment should not contain flowpaths from upstream catchments")
  
  new_hope_catchment_rec$area_sqkm <- as.numeric(sf::st_area(
    sf::st_transform(new_hope_catchment_rec, 5070))) / (1000^2)
  
  new_hope_fline_rec <- dplyr::inner_join(new_hope_fline_rec,
                                  dplyr::select(sf::st_set_geometry(new_hope_catchment_rec, NULL),
                                          ID, area_sqkm), by = "ID")
  new_hope_fline_rec$TotDASqKM <-
    nhdplusTools::calculate_total_drainage_area(dplyr::rename(sf::st_set_geometry(new_hope_fline_rec, NULL),
                                         area = area_sqkm))

  aggregated <- aggregate_catchments(new_hope_fline_rec, new_hope_catchment_rec, outlets,
                                     da_thresh = 2, only_larger = TRUE)

  fline_sets_2 <- aggregated$fline_sets
  cat_sets_2 <- aggregated$cat_sets

  expect_true(nrow(fline_sets_2) == 6, "Should have six catchments in the output")

  expect_true(!any(get_id(c("8893788,8893784", "8894184,8894448")) %in% fline_sets_2$ID), "Shouldn't have a couple small catchments in output.")
  
  # sf::write_sf(aggregated$cat_sets, "new_hope_collapse.gpkg", "boundary")
  # sf::write_sf(aggregated$fline_sets, "new_hope_collapse.gpkg", "flowpath")
  # nolint end
})

test_that("new_hope aggregate", {

  get_id <- function(mc) {
    ind <- match(mc, new_hope_catchment_rec$member_COMID)
    new_hope_catchment_rec$ID[ind]
  }

  new_hope_catchment_rec$area_sqkm <- as.numeric(sf::st_area(
    sf::st_transform(new_hope_catchment_rec, 5070))) / (1000^2)
  new_hope_fline_rec <- dplyr::inner_join(new_hope_fline_rec,
                                          dplyr::select(sf::st_set_geometry(new_hope_catchment_rec, NULL),
                                                 ID, area_sqkm), by = "ID")
  new_hope_fline_rec[["TotDASqKM"]] <-
    nhdplusTools::calculate_total_drainage_area(dplyr::rename(sf::st_set_geometry(new_hope_fline_rec, NULL),
                                         area = area_sqkm))

  # HU12 FPP st_joined to get these
  outlets <- data.frame(ID = get_id(c("8894358", "8894344.2", "8893780.2,8894326",
                               "8895792", "8894336,8894342",
                               "8894154.2", "8894142.1", "8894360,8897784")),
                        type = c("outlet", "outlet", "outlet", "outlet",
                                 "outlet", "outlet", "outlet", "terminal"),
                        stringsAsFactors = FALSE)

  aggregated <- aggregate_catchments(new_hope_fline_rec, new_hope_catchment_rec, outlets)

  fline_sets <- aggregated$fline_sets
  cat_sets <- aggregated$cat_sets

  expect_true(length(which(sapply(fline_sets$set, function(x) get_id("8893342") %in% x))) == 1,
         "A connector flowpath should be added downstream of an upper hu.")

  outlets <- data.frame(ID = get_id(c("8895638", "8894360,8897784")),
                        type = c("outlet", "terminal"),
                        stringsAsFactors = FALSE)

  aggregated <- aggregate_catchments(new_hope_fline_rec, new_hope_catchment_rec, outlets,
                                     only_larger = FALSE)

  expect_true(get_id("8893780.2,8894326") %in% aggregated$cat_sets$ID,
         "expect catchment downstream of outlet where levelpath changes to be in output")
  expect_true(all(get_id(c("8896032.4,8896016", "8896054", "8895888.2,8897468")) %in% aggregated$cat_sets$ID),
         "expect contributing to the same nexus as another specified outlet")

  expect_true(length(aggregated$cat_sets$ID) == 11, "Expect 11 output catchments")
  # nolint start
  # sf::write_sf(aggregated$cat_sets, "new_hope_collapse.gpkg", "boundary")
  # sf::write_sf(aggregated$fline_sets, "new_hope_collapse.gpkg", "flowpath")
  # nolint end
})
