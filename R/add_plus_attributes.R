#### these were deprecated in nhdplusTools and modified very slightly

#' Add NHDPlus Network Attributes to a provided network.
#' @description Given a river network with required base attributes, adds the
#' NHDPlus network attributes: hydrosequence, levelpath, terminalpath, pathlength,
#' down levelpath, down hydroseq, total drainage area, and terminalflag.
#' The function implements two parallelization schemes for small and large basins
#' respectively. If a number of cores is specified, parallel execution will be used.
#'
#' @param net data.frame containing comid, tocomid, nameID, lengthkm, and areasqkm.
#' Additional attributes will be passed through unchanged.
#' tocomid == 0 is the convention used for outlets.
#' If a "weight" column is provided, it will be used in \link{get_levelpaths}
#' otherwise, arbolate sum is calculated for the network and used as the weight.
#'
#' @param override numeric factor to be passed to \link{get_levelpaths}
#' @param cores integer number of processes to spawn if run in parallel.
#' @param split_temp character path to optional temporary copy of the network
#' split into independent sub-networks. If it exists, it will be read from disk
#' rather than recreated.
#' @param status logical should progress be printed?
#' @return data.frame with added attributes
#' @importFrom tidyr replace_na
#' @noRd
#' @examples
#'
#' source(system.file("extdata", "walker_data.R", package = "nhdplusTools"))
#'
#' test_flowline <- prepare_nhdplus(walker_flowline, 0, 0, FALSE)
#'
#' test_flowline <- data.frame(
#'   comid = test_flowline$COMID,
#'   tocomid = test_flowline$toCOMID,
#'   nameID = walker_flowline$GNIS_ID,
#'   lengthkm = test_flowline$LENGTHKM,
#'   areasqkm = walker_flowline$AreaSqKM)
#'
#' add_plus_network_attributes(test_flowline)

add_plus_network_attributes <- function(net, override = 5,
                                        cores = NULL, split_temp = NULL,
                                        status = TRUE) {

  add_sf <- FALSE
  if(inherits(net, "sf")) {
    add_sf <- TRUE
    geom <- dplyr::select(net)
    net <- st_drop_geometry(net)
  }

  if(any((rem <- c("hydroseq", "levelpathi", "terminalpa",
       "pathlength", "dnlevelpat", "dnhydroseq", "totdasqkm",
       "terminalfl")) %in% names(net))) {
    warning("provided flowlines contain attributes that will be over written.")
    net <- select(net, -dplyr::any_of(c(rem)))
  }

  if(!status) {
    old_opt <- pbapply::pboptions(type = "none")
    on.exit(pbapply::pboptions(type = old_opt$type))
  }

  net[["tocomid"]] <- replace_na(net[["tocomid"]], 0)

  rename_arb <- FALSE

  if(!"weight" %in% names(net)) {
    net$weight <- calculate_arbolate_sum(
      select(net, ID = "comid",
             toID = "tocomid", length = "lengthkm"))
    rename_arb <- TRUE
  }

  if(!is.null(split_temp) && file.exists(split_temp)) {
    lp <- readRDS(split_temp)
  } else {

    lp <- get_sorted(
      dplyr::rename(net,
                    ID = "comid",
                    toID = "tocomid"),
      split = TRUE)

    lp <- split(lp, lp$terminalID)

    if(!is.null(split_temp)) {
      saveRDS(lp, split_temp)
    }
  }

  if(!is.null(cores)) {

    rows <- sapply(lp, nrow)

    small_lp <- lp[rows <= 20000]
    lp <- lp[rows > 20000]

    message("running large networks")

    oplan <- future::plan(future::multisession, workers = cores)
    on.exit(future::plan(oplan), add = TRUE)

  }

  lp <- lapply(X = lp,
               FUN = function(x, override) {
                 get_levelpaths_internal(x, override_factor = override)
               }, override = override)

  if(!is.null(cores)) {

    run_small <- function(small_lp, override) {

      message("running small networks")

      small_lp <- pbapply::pblapply(X = small_lp,
                                    FUN = function(x, override, get_levelpaths_internal) {
                                      get_levelpaths_internal(x, override)
                                    }, override = override,
                                    get_levelpaths_internal = get_levelpaths_internal,
                                    cl = "future")

    }

    lp <- c(lp, run_small(small_lp, override))

  }

  combine_networks <- function(lp) {
    # ts stands for toposort here. Given that the networks retrieved above are
    # independent, we need to lag them so they don't have overlapping identifiers.
    start_ts <- 0

    for(i in seq_along(lp)) {

      lp[[i]]$levelpath <- lp[[i]]$levelpath + start_ts
      lp[[i]]$topo_sort <- lp[[i]]$topo_sort + start_ts

      start_ts <- max(lp[[i]]$topo_sort)

    }

    lp <- lapply(lp, function(x) {
      mutate(x, terminalpath = min(.data$topo_sort))
    })

    bind_rows(lp)
  }

  lp <- combine_networks(lp)

  net <- net %>%
    left_join(select(lp,
                     comid = "ID", terminalpa = "terminalpath",
                     hydroseq = "topo_sort", levelpathi = "levelpath"),
              by = "comid")

  in_pathlength <- select(net, ID = "comid", toID = "tocomid", length = "lengthkm")

  pathlength <- nhdplusTools::get_pathlength(in_pathlength)

  pathlength <- distinct(pathlength) %>%
    filter(!is.na(.data$pathlength))

  net <- left_join(net,
                       select(pathlength,
                              comid = "ID",
                              "pathlength"),
                       by = "comid")

  dn_lp <- net %>%
    left_join(select(net,
                     "comid", dnlevelpat = "levelpathi"),
              by = c("tocomid" = "comid"), ) %>%
    filter(!is.na(.data$dnlevelpat)) %>%
    select("comid", "dnlevelpat")

  net <- left_join(net, dn_lp, by = "comid") %>%
    mutate(dnlevelpat = ifelse(is.na(.data$dnlevelpat), 0, .data$dnlevelpat))

  dn_hs <- net %>%
    left_join(select(net,
                     "comid", dnhydroseq = "hydroseq"),
              by = c("tocomid" = "comid")) %>%
    select("comid", "dnhydroseq")

  net <- left_join(net, dn_hs, by = "comid") %>%
    mutate(dnhydroseq = ifelse(is.na(.data$dnhydroseq), 0, .data$dnhydroseq))

  if("areasqkm" %in% names(net)) {
    net$totdasqkm <- calculate_total_drainage_area(
      select(net, ID = "comid", toID = "tocomid", area = "areasqkm")
    )
  }

  net <- net %>%
    group_by(.data$terminalpa) %>%
    mutate(terminalfl = ifelse(.data$hydroseq == min(.data$hydroseq), 1, 0)) %>%
    ungroup()

  if(add_sf) {
    net <- sf::st_sf(cbind(net, geom))
  }

  net
}

#' Calculate Arbolate Sum
#' @description Calculates arbolate sum given a dendritic
#' network and incremental lengths. Arbolate sum is the total length
#' of all upstream flowlines.
#' @param x data.frame with ID, toID, and length columns.
#' @return numeric with arbolate sum.
#' @importFrom hydroloom accumulate_downstream
#' @noRd
#' @examples
#' library(dplyr)
#' source(system.file("extdata", "walker_data.R", package = "nhdplusTools"))
#' catchment_length <- select(walker_flowline, COMID, AreaSqKM) %>%
#'   right_join(prepare_nhdplus(walker_flowline, 0, 0,
#'                             purge_non_dendritic = FALSE, warn = FALSE), by = "COMID") %>%
#'   select(ID = COMID, toID = toCOMID, length = LENGTHKM)
#'
#' arb_sum <- calculate_arbolate_sum(catchment_length)
#'
#' catchment_length$arb_sum <- arb_sum
#' catchment_length$nhd_arb_sum <- walker_flowline$ArbolateSu
#'
#' mean(abs(catchment_length$arb_sum - catchment_length$nhd_arb_sum))
#' max(abs(catchment_length$arb_sum - catchment_length$nhd_arb_sum))
#'

calculate_arbolate_sum <- function(x) {
  
  accumulate_downstream(x, "length")
  
}

#' @importFrom hydroloom add_levelpaths hy
get_levelpaths_internal <- function(x, override_factor) {
  # x <- check_names(st_drop_geometry(x), "get_levelpaths")
  
  x <- hy(select(x, all_of(c(id = "ID", toid = "toID", "nameID", "weight"))))
  
  x <- add_levelpaths(x, weight_attribute = "weight", name_attribute = "nameID",
                      override_factor = override_factor)
  
  as.data.frame(select(x, all_of(c("ID" = "id", "outletID" = "levelpath_outlet_id",
                                   "topo_sort" = "topo_sort", "levelpath" = "levelpath"))))
}

#' Total Drainage Area
#' @description Calculates total drainage area given a dendritic
#' network and incremental areas.
#' @param x data.frame with ID, toID, and area columns.
#' @return numeric with total area.
#' @importFrom dplyr select left_join
#' @importFrom hydroloom accumulate_downstream
#' @noRd
#' @examples
#' library(dplyr)
#' source(system.file("extdata", "walker_data.R", package = "nhdplusTools"))
#' catchment_area <- select(walker_flowline, COMID, AreaSqKM) %>%
#'   right_join(prepare_nhdplus(walker_flowline, 0, 0,
#'                             purge_non_dendritic = FALSE, warn = FALSE), by = "COMID") %>%
#'   select(ID = COMID, toID = toCOMID, area = AreaSqKM)
#'
#' new_da <- calculate_total_drainage_area(catchment_area)
#'
#' catchment_area$totda <- new_da
#' catchment_area$nhdptotda <- walker_flowline$TotDASqKM
#'
#' mean(abs(catchment_area$totda - catchment_area$nhdptotda))
#' max(abs(catchment_area$totda - catchment_area$nhdptotda))
#'

calculate_total_drainage_area <- function(x) {
  
  accumulate_downstream(x, "area")
  
}
