context("Test refactor wrapper")

Sys.setenv(TURN_OFF_SYS_MAPSHAPER = "YUP")

test_that("refactor wrapper", {
  
  skip("data doesn't work")
  
  source(system.file("extdata", "walker_data.R", package = "hyRefactor"))
  
  temp_dir <- file.path(tempdir(), "fdrfac")
  dir.create(temp_dir, recursive = TRUE, showWarnings = FALSE)
  
  file.copy(file.path(extdata, "walker_fdr.tif"), file.path(temp_dir, "18b_fdr.tif"))
  file.copy(file.path(extdata, "walker_fac.tif"), file.path(temp_dir, "18b_fac.tif"))
  
  refactor <- refactor(flowpaths  = walker_flowline,
                       catchments = walker_catchment,
                       split_flines_meters = 2000,
                       collapse_flines_meters = 1,
                       collapse_flines_main_meters = 1,
                       fac = file.path(temp_dir, "18b_fac.tif"),
                       fdr = file.path(temp_dir, "18b_fdr.tif"))
  
  expect_true(nrow(refactor$flowpaths) == nrow(refactor$catchments), "failed wrapper")

})

Sys.unsetenv("TURN_OFF_SYS_MAPSHAPER")
