context("collapse_flowlines")

test_that("collapse flowlines works as expected", {
  flines <- readRDS(list.files(pattern = "petapsco_network.rds", 
                               full.names = TRUE, recursive = TRUE))
  flines <- sf::st_set_geometry(flines, NULL)
  flines <- suppressWarnings(nhdplusTools::prepare_nhdplus(flines, 20, 1))
  flines_out <- collapse_flowlines(flines, 1)
  flines_out_exclude <- collapse_flowlines(flines, 1,
                                           exclude_cats = c(11687206,
                                                            11690332,
                                                            11687234,
                                                            11689928,
                                                            11690532,
                                                            11690260, 11690262,
                                                            11690568, 11690258))

  # problem headwater
  expect_true(flines_out$joined_toCOMID[which(flines_out$COMID == 11687206)] ==
           -9999)
  expect_true(flines_out$toCOMID[which(flines_out$COMID == 11687206)] ==
           flines$toCOMID[which(flines$COMID == 11687206)])

  # problem headwater
  expect_true(is.na(flines_out_exclude$joined_toCOMID[which(flines_out_exclude$COMID == 11687206)]))

  # Multi combination headwater
  expect_true(flines_out$joined_toCOMID[which(flines_out$COMID == 11690332)] ==
           11689092)
  expect_true(flines_out$joined_toCOMID[which(flines_out$COMID == 11689030)] ==
           11689092)

  expect_true(is.na(flines_out_exclude$joined_toCOMID[which(flines_out_exclude$COMID == 11690332)]))
  expect_true(is.na(flines_out_exclude$joined_toCOMID[which(flines_out_exclude$COMID == 11689030)]))

  # confluence join worked
  expect_true(flines_out$joined_fromCOMID[which(flines_out$COMID == 11687234)] ==
           11687224)

  expect_true(flines_out$toCOMID[which(flines_out$COMID == 11687226)] ==
           11687358 &
           flines_out$toCOMID[which(flines_out$COMID == 11687224)] ==
           11687358)

  expect_true(flines_out$LENGTHKM[which(flines_out$COMID == 11687226)] ==
           flines$LENGTHKM[which(flines$COMID == 11687226)] +
           flines$LENGTHKM[which(flines$COMID == 11687234)])

  expect_true(is.na(flines_out_exclude$joined_fromCOMID[which(flines_out_exclude$COMID == 11687234)]))

  # mainstem join worked

  expect_true(flines_out$toCOMID[which(flines_out$COMID == 11687548)] ==
           11689978)

  expect_true(flines_out$joined_fromCOMID[which(flines_out$COMID == 11689928)] ==
           11687548 &
           flines_out$joined_fromCOMID[
             which(flines_out$COMID == 11690532)] == 11687548)

  expect_true(flines_out$LENGTHKM[which(flines_out$COMID == 11687548)] ==
           (flines$LENGTHKM[which(flines_out$COMID == 11687548)] +
              flines$LENGTHKM[which(flines_out$COMID == 11689928)] +
              flines$LENGTHKM[which(flines_out$COMID == 11690532)]))

  expect_true(is.na(flines_out_exclude$joined_fromCOMID[which(flines_out_exclude$COMID == 11689928)]) &
           is.na(flines_out_exclude$joined_fromCOMID[which(flines_out_exclude$COMID == 11690532)]))

  # outlet worked

  expect_true(is.na(flines_out$toCOMID[which(flines_out$COMID == 11690256)]))

  expect_true(flines_out$joined_fromCOMID[which(flines_out$COMID == 11690260)] ==
           11690256)
  expect_true(flines_out$joined_fromCOMID[which(flines_out$COMID == 11690262)] ==
           11690256)
  expect_true(flines_out$joined_fromCOMID[which(flines_out$COMID == 11690568)] ==
           11690256)
  expect_true(flines_out$joined_fromCOMID[which(flines_out$COMID == 11690258)] ==
           11690256)

  expect_true(flines_out$LENGTHKM[which(flines_out$COMID == 11690256)] ==
           (flines$LENGTHKM[which(flines_out$COMID == 11690258)] +
              flines$LENGTHKM[which(flines_out$COMID == 11690568)] +
              flines$LENGTHKM[which(flines_out$COMID == 11690262)] +
              flines$LENGTHKM[which(flines_out$COMID == 11690260)] +
              flines$LENGTHKM[which(flines_out$COMID == 11690256)]))

  expect_true(is.na(flines_out_exclude$joined_fromCOMID[which(flines_out_exclude$COMID == 11690260)]))
  expect_true(is.na(flines_out_exclude$joined_fromCOMID[which(flines_out_exclude$COMID == 11690262)]))
  expect_true(is.na(flines_out_exclude$joined_fromCOMID[which(flines_out_exclude$COMID == 11690568)]))
  expect_true(is.na(flines_out_exclude$joined_fromCOMID[which(flines_out_exclude$COMID == 11690258)]))

})

context("collapse_flowlines - 2")

test_that("headwater / top of mainstem collapes works as expected", {
  flines <- readRDS(list.files(pattern = "guadalupe_network_geom.rds", recursive = TRUE))
  flines <- sf::st_set_geometry(flines, NULL)
  flines <- suppressWarnings(nhdplusTools::prepare_nhdplus(flines, 0, 0))

  flines_out <- collapse_flowlines(flines, 0.5, mainstem_thresh = 0.5)

  # small headwater gets collapsed downstream.
  expect_true(flines_out$joined_toCOMID[which(flines_out$COMID == 24670381)] ==
           3839043)

  expect_true(flines_out$LENGTHKM[which(flines_out$COMID == 24670381)] == 0)

  expect_true(flines_out$LENGTHKM[which(flines_out$COMID == 3839043)] ==
           (flines$LENGTHKM[which(flines$COMID == 3839043)] +
              flines$LENGTHKM[which(flines$COMID == 24670381)]))

  # Very short top of interconfluence flow path gets collapsed with
  # next downstream correctly
  expect_true(flines_out$joined_toCOMID[which(flines_out$COMID == 1628129)] ==
           1628527)

  expect_true(flines_out$LENGTHKM[which(flines_out$COMID == 1628129)] == 0)
  expect_true(is.na(flines_out$toCOMID[which(flines_out$COMID == 1628129)]))

  expect_true(flines_out$LENGTHKM[which(flines_out$COMID == 1628527)] ==
           (flines$LENGTHKM[which(flines$COMID == 1628527)] +
              flines$LENGTHKM[which(flines$COMID == 1628129)]))

  # second instance of very short top of interconfluence
  # flow path gets collapsed
  # with next downstream correctly and also has a collapse upstream below it.
  expect_true(flines_out$joined_toCOMID[which(flines_out$COMID == 1629537)] ==
           1629821)

  expect_true(flines_out$LENGTHKM[which(flines_out$COMID == 1629537)] == 0)
  expect_true(is.na(flines_out$toCOMID[which(flines_out$COMID == 1629537)]))

  expect_true(flines_out$joined_fromCOMID[which(flines_out$COMID == 1629565)] ==
           1629821)

  expect_true(flines_out$LENGTHKM[which(flines_out$COMID == 1629565)] == 0)
  expect_true(is.na(flines_out$toCOMID[which(flines_out$COMID == 1629565)]))

  expect_true(flines_out$LENGTHKM[which(flines_out$COMID == 1629821)] ==
           (flines$LENGTHKM[which(flines$COMID == 1629821)] +
              flines$LENGTHKM[which(flines$COMID == 1629537)] +
              flines$LENGTHKM[which(flines$COMID == 1629565)]))
  # This one collapsed in upstream direction

  expect_true(flines_out$joined_toCOMID[which(flines_out$COMID == 10840906)] ==
           10840550)
  expect_true(flines_out$joined_toCOMID[which(flines_out$COMID == 10840550)] ==
           -9999)
  expect_true(flines_out$toCOMID[which(flines_out$COMID == 10840550)] ==
           flines$toCOMID[which(flines$COMID == 10840554)])

  expect_equal(flines_out$LENGTHKM[which(flines_out$COMID == 10840550)],
           (flines$LENGTHKM[which(flines$COMID == 10840550)] +
              flines$LENGTHKM[which(flines$COMID == 10840906)] +
              flines$LENGTHKM[which(flines$COMID == 10840554)]))
  # nolint start
  # flines <- readRDS("data/petapsco_network.rds")
  # flines <- sf::st_set_geometry(flines, NULL)
  # flines <- suppressWarnings(nhdplusTools::prepare_nhdplus(flines, 0, 0))
  #
  # flines_out <- collapse_flowlines(flines, 0.5, mainstem_thresh = 1)
  # nolint end
})

context("collapse_flowlines - 3")

test_that("collapse flowlines works with small networks", {
  flines <- readRDS(list.files(pattern = "small_networks.rds", recursive = TRUE))
  flines <- suppressWarnings(nhdplusTools::prepare_nhdplus(flines, 0, 0))

  flines_collapse <- collapse_flowlines(flines, 2)

  flines <- suppressWarnings(nhdplusTools::prepare_nhdplus(
    readRDS(list.files(pattern = "frost_network.rds", recursive = TRUE)), 0, 0))

  c1 <- collapse_flowlines(flines, 1000, F, 1000)

  expect_true(c1$joined_fromCOMID[which(c1$COMID == 5877003)] == -9999)
  expect_true(c1$joined_fromCOMID[which(c1$COMID == 5876965)] == 5877003)
  expect_equal(c1$LENGTHKM[which(c1$COMID == 5877003)], 1.070)

  expect_equal(c1$LENGTHKM[which(c1$COMID == 5876985)], 1.459)

  r1 <- reconcile_collapsed_flowlines(c1)

  expect_equal(length(which(r1$ID == 1)), 6)
  expect_true(all(is.na(r1$toID)))

  flines <- suppressWarnings(nhdplusTools::prepare_nhdplus(
    readRDS(list.files(pattern = "tiny_network.rds", recursive = TRUE)), 0, 0))
  c1 <- collapse_flowlines(flines, 1000, F, 1000)

  expect_equal(c1$LENGTHKM[which(c1$COMID == 7733111)], 0.221)

  flines <- suppressWarnings(nhdplusTools::prepare_nhdplus(
    readRDS(list.files(pattern = "flag_network.rds", recursive = TRUE)), 0, 0))

  c1 <- collapse_flowlines(flines, 1000, F, 1000)

  expect_true(c1$joined_fromCOMID[which(c1$COMID == 1797871)] == 1798051)
  r1 <- reconcile_collapsed_flowlines(c1)

})

context("collapse_flowlines - 4")

test_that("collapse flowlines works as expected with add category", {
  flines <- readRDS(list.files(pattern = "petapsco_network.rds", recursive = TRUE))
  flines <- sf::st_set_geometry(flines, NULL)
  flines <- suppressWarnings(nhdplusTools::prepare_nhdplus(flines, 20, 1))
  flines <- collapse_flowlines(flines, 1, add_category = TRUE)
  expect_equal(names(flines)[9], "join_category")
})

context("collapse_flowlines - 5")

# then go look at problem headwater combinations.
test_that("collapse flowlines works as expected with mainstem thresh", {
  flines <- readRDS(list.files(pattern = "petapsco_network.rds", recursive = TRUE))
  flines <- sf::st_set_geometry(flines, NULL)
  flines <- suppressWarnings(nhdplusTools::prepare_nhdplus(flines, 20, 1))
  flines <- collapse_flowlines(flines, .5, add_category = TRUE,
                               mainstem_thresh = 1)

  expect_true(is.na(flines$joined_fromCOMID[which(flines$COMID == 11689092)]))

  expect_true(flines$toCOMID[which(flines$COMID == 11688868)] == 11690128)

  expect_true(flines$joined_fromCOMID[which(flines$COMID == 11690124)] ==
           11688868)
})

context("collapse_flowlines - 6")

test_that("repeat collapse doesn't leave orphans", {

  nhdplus_flines <- readRDS(list.files(pattern = "oswego_network.rds", recursive = TRUE))
  flines <- suppressWarnings(dplyr::inner_join(
    dplyr::select(nhdplus_flines, COMID), 
    sf::st_set_geometry(nhdplus_flines, NULL) %>%
                       nhdplusTools::prepare_nhdplus(0, 0), 
                     by = "COMID") %>%
    sf::st_as_sf() %>%
    sf::st_cast("LINESTRING") %>%
    sf::st_transform(5070))

  if (suppressWarnings(require(lwgeom)) & exists("st_linesubstring",
                                                 where = "package:lwgeom",
                                                 mode = "function")) {

  flines <- split_flowlines(flines, 2000, para = 2)
  flines <- collapse_flowlines(sf::st_set_geometry(flines, NULL),
                               (0.125), TRUE, (0.125))

  # this is right the first pass.
  expect_true(flines$joined_fromCOMID[which(flines$COMID == 21974341)] ==
           21975097)

  flines <- suppressWarnings(collapse_flowlines(flines,
                                                (0.25), TRUE, (0.25)))

  # needs to get redirected on the second pass.
  # Old Tests:
  expect_true(flines$joined_toCOMID[which(flines$COMID == 21974341)] ==
           21975095)
  expect_true(flines$joined_toCOMID[which(flines$COMID == 21975097)] ==
           21975095)
  expect_true(flines$toCOMID[which(flines$COMID == 21975777)] ==
           flines$joined_toCOMID[which(flines$COMID == 21975773)])

  }
})
