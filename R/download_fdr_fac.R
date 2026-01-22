# Either export from nhdplusTools or leave this
check7z = function (){
  tryCatch({
    system("7z", intern = TRUE)
  }, error = function(e) {
    stop(simpleError(paste0("Please Install 7zip (Windows) or p7zip (MacOS/Unix).",
                            " Choose accordingly:\n        Windows: https://www.7-zip.org/download.html\n  ", 
                            "      Mac: 'brew install p7zip' or 'sudo port install p7zip'\n        ", 
                            "Linux: https://sourceforge.net/projects/p7zip/")))
  })
}

#' Download Elevation and Derivatives
#' @param product character DEM, hydroDEM, or FDRFAC.  
#' @param out_dir path to directory to store output.
#' @param regions character vector of two digit hydrologic 
#' @importFrom rvest read_html html_nodes html_attr
#' @importFrom httr RETRY write_disk progress
#' @export
download_elev <- function(product, out_dir, regions = NULL) {
  
  dev_null <- check7z()
  
  allowable <- c("DEM" = ".*NEDSnapshot.*", "hydroDEM" = ".*HydroDem.*", "FDRFAC" = ".*FdrFac.*")
  
  if(!all(product %in% names(allowable))) stop(paste("product must be one of", allowable))
  
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  
  root <- "https://dmap-data-commons-ow.s3.amazonaws.com"
  base <- "/NHDPlusV21/Data/"
  
  # NHDPlusV2nn_<dd>_<VPUid>_<RPUid>_componentname_<vv>
  
  file_list <- c("NHDPlusV21_CA_18_18a_FdrFac_01.7z", "NHDPlusV21_CA_18_18b_FdrFac_01.7z", 
                 "NHDPlusV21_CA_18_18c_FdrFac_01.7z", "NHDPlusV21_CI_21_21a_FdrFac_01.7z", 
                 "NHDPlusV21_CI_21_21b_FdrFac_01.7z", "NHDPlusV21_CI_21_21c_FdrFac_01.7z", 
                 "NHDPlusV21_CO_14_14a_FdrFac_01.7z", "NHDPlusV21_CO_14_14b_FdrFac_01.7z", 
                 "NHDPlusV21_CO_15_15a_FdrFac_01.7z", "NHDPlusV21_CO_15_15b_FdrFac_01.7z", 
                 "NHDPlusV21_GB_16_16a_FdrFac_01.7z", "NHDPlusV21_GB_16_16b_FdrFac_01.7z", 
                 "NHDPlusV21_GL_04_04a_FdrFac_03.7z", "NHDPlusV21_GL_04_04b_FdrFac_03.7z", 
                 "NHDPlusV21_GL_04_04c_FdrFac_03.7z", "NHDPlusV21_GL_04_04d_FdrFac_03.7z", 
                 "NHDPlusV21_HI_20_20a_FdrFac_01.7z", "NHDPlusV21_HI_20_20b_FdrFac_01.7z", 
                 "NHDPlusV21_HI_20_20c_FdrFac_01.7z", "NHDPlusV21_HI_20_20d_FdrFac_01.7z", 
                 "NHDPlusV21_HI_20_20e_FdrFac_01.7z", "NHDPlusV21_HI_20_20f_FdrFac_01.7z", 
                 "NHDPlusV21_HI_20_20g_FdrFac_01.7z", "NHDPlusV21_HI_20_20h_FdrFac_01.7z", 
                 "NHDPlusV21_MA_02_02a_FdrFac_01.7z", "NHDPlusV21_MA_02_02b_FdrFac_01.7z", 
                 "NHDPlusV21_MS_05_05a_FdrFac_01.7z", "NHDPlusV21_MS_05_05b_FdrFac_01.7z", 
                 "NHDPlusV21_MS_05_05c_FdrFac_01.7z", "NHDPlusV21_MS_05_05d_FdrFac_01.7z", 
                 "NHDPlusV21_MS_06_06a_FdrFac_03.7z", "NHDPlusV21_MS_07_07a_FdrFac_01.7z", 
                 "NHDPlusV21_MS_07_07b_FdrFac_01.7z", "NHDPlusV21_MS_07_07c_FdrFac_01.7z", 
                 "NHDPlusV21_MS_08_03g_FdrFac_01.7z", "NHDPlusV21_MS_08_08a_FdrFac_01.7z", 
                 "NHDPlusV21_MS_08_08b_FdrFac_01.7z", "NHDPlusV21_MS_10L_10a_FdrFac_01.7z", 
                 "NHDPlusV21_MS_10L_10b_FdrFac_01.7z", "NHDPlusV21_MS_10L_10c_FdrFac_01.7z", 
                 "NHDPlusV21_MS_10L_10d_FdrFac_01.7z", "NHDPlusV21_MS_10U_10e_FdrFac_02.7z", 
                 "NHDPlusV21_MS_10U_10f_FdrFac_02.7z", "NHDPlusV21_MS_10U_10g_FdrFac_02.7z", 
                 "NHDPlusV21_MS_10U_10h_FdrFac_02.7z", "NHDPlusV21_MS_10U_10i_FdrFac_02.7z", 
                 "NHDPlusV21_MS_11_11a_FdrFac_01.7z", "NHDPlusV21_MS_11_11b_FdrFac_01.7z", 
                 "NHDPlusV21_MS_11_11c_FdrFac_01.7z", "NHDPlusV21_MS_11_11d_FdrFac_01.7z", 
                 "NHDPlusV21_NE_01_01a_FdrFac_01.7z", "NHDPlusV21_PI_22AS_22c_FdrFac_01.7z", 
                 "NHDPlusV21_PI_22GU_22a_FdrFac_01.7z", "NHDPlusV21_PI_22MP_22b_FdrFac_01.7z", 
                 "NHDPlusV21_PN_17_17a_FdrFac_01.7z", "NHDPlusV21_PN_17_17b_FdrFac_01.7z", 
                 "NHDPlusV21_PN_17_17c_FdrFac_01.7z", "NHDPlusV21_PN_17_17d_FdrFac_01.7z", 
                 "NHDPlusV21_RG_13_13a_FdrFac_01.7z", "NHDPlusV21_RG_13_13b_FdrFac_01.7z", 
                 "NHDPlusV21_RG_13_13c_FdrFac_01.7z", "NHDPlusV21_RG_13_13d_FdrFac_01.7z", 
                 "NHDPlusV21_SA_03N_03a_FdrFac_01.7z", "NHDPlusV21_SA_03N_03b_FdrFac_01.7z", 
                 "NHDPlusV21_SA_03S_03c_FdrFac_01.7z", "NHDPlusV21_SA_03S_03d_FdrFac_01.7z", 
                 "NHDPlusV21_SA_03W_03e_FdrFac_01.7z", "NHDPlusV21_SA_03W_03f_FdrFac_01.7z", 
                 "NHDPlusV21_SR_09_09a_FdrFac_01.7z", "NHDPlusV21_TX_12_12a_FdrFac_01.7z", 
                 "NHDPlusV21_TX_12_12b_FdrFac_01.7z", "NHDPlusV21_TX_12_12c_FdrFac_01.7z", 
                 "NHDPlusV21_TX_12_12d_FdrFac_01.7z")
  
  urls <- sapply(file_list, \(x) {
    spl <- strsplit(x, "_")[[1]]
  
    paste0(root, base, "NHDPlus", spl[2], "/", x)  
  })
  
  
  if(!is.null(regions)) {
    urls <- urls[grepl(paste(paste0(".*_", regions, "?[a-z]_.*"), 
                             collapse = "|"), urls, ignore.case = TRUE)]
  }
  
  for(f in urls) {
    fi <- basename(f)
    url <- f
    out_fi <- file.path(out_dir, fi)
    
    message(out_fi)
    
    if(!file.exists(out_fi)) {
      RETRY("GET", url, write_disk(out_fi), progress())
      
      system(paste0("7z -y -o", path.expand(out_dir), " x ", 
                    path.expand(out_fi)), intern = TRUE)
    }
  }
}

#' Download FDR FAC
#' @inheritParams download_elev
#' @export
download_fdr_fac <- function(out_dir, regions = NULL) {
  
  download_elev(product = c("FDRFAC"), out_dir, regions)
  
}
