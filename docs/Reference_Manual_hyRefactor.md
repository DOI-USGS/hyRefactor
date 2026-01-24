# Vignettes
- [Refactor Flowlines](refactor_nhdplus.md)
- [Split Flowlines](split_refactor.md)
- [Refactor Catchments](refactor_catchment.md)
- [Coastal Units with hyRefactor](coastal_units.md)

# Function Reference

- [add_lengthmap: Add Length Map to Refactored Network](#add_lengthmap: Add Length Map to Refactored Network)
- [add_lookup_table: Generate Lookup table for refactored or aggregated network](#add_lookup_table: Generate Lookup table for refactored or aggregated network)
- [add_nonnetwork_divides: Add Non Network Divides to Aggregated Fabric](#add_nonnetwork_divides: Add Non Network Divides to Aggregated Fabric)
- [aggregate_along_mainstems: Aggregate along network mainstems](#aggregate_along_mainstems: Aggregate along network mainstems)
- [aggregate_network_to_outlets: Aggregate Network](#aggregate_network_to_outlets: Aggregate Network)
- [aggregate_to_distribution: Aggregate Network to Uniform Size](#aggregate_to_distribution: Aggregate Network to Uniform Size)
- [aggregate_to_outlets: Aggregate Catchments](#aggregate_to_outlets: Aggregate Catchments)
- [clean_geometry: Clean Catchment Geometry](#clean_geometry: Clean Catchment Geometry)
- [collapse_flowlines: Collapse NHDPlus Network](#collapse_flowlines: Collapse NHDPlus Network)
- [collapse_headwaters: Collapse Headwaters](#collapse_headwaters: Collapse Headwaters)
- [create_style_row: Create a style row from the given parameters.](#create_style_row: Create a style row from the given parameters.)
- [download_elev: Download Elevation and Derivatives](#download_elev: Download Elevation and Derivatives)
- [download_fdr_fac: Download FDR FAC](#download_fdr_fac: Download FDR FAC)
- [get_minimal_network: Get Minimal Network](#get_minimal_network: Get Minimal Network)
- [get_row_col: Get Row and Column](#get_row_col: Get Row and Column)
- [map_outlet_ids: Map outlets from COMID to ID for aggregate catchments](#map_outlet_ids: Map outlets from COMID to ID for aggregate catchments)
- [prep_cat_fdr_fac: Prep catchment with FDR/FAC](#prep_cat_fdr_fac: Prep catchment with FDR/FAC)
- [read_hydrofabric: Read Catchments and Flowpaths from Geopackage](#read_hydrofabric: Read Catchments and Flowpaths from Geopackage)
- [read_qml: Read a QML file from the inst/qml directory](#read_qml: Read a QML file from the inst/qml directory)
- [reconcile_catchment_divides: Reconcile Catchment Divides](#reconcile_catchment_divides: Reconcile Catchment Divides)
- [reconcile_collapsed_flowlines: Reconcile Collapsed Flowlines](#reconcile_collapsed_flowlines: Reconcile Collapsed Flowlines)
- [refactor: Refactoring Wrapper](#refactor: Refactoring Wrapper)
- [refactor_nhdplus: Refactor NHDPlus](#refactor_nhdplus: Refactor NHDPlus)
- [split_catchment_divide: Split Catchment Divides](#split_catchment_divide: Split Catchment Divides)
- [split_flowlines: Split Flowlines](#split_flowlines: Split Flowlines)
- [trace_upstream: Trace Upstream](#trace_upstream: Trace Upstream)
- [write_hydrofabric: Write a hydrofabric gpkg](#write_hydrofabric: Write a hydrofabric gpkg)


```
Package: hyRefactor
Type: Package
Title: Hydrologic Network Refactoring and Aggregation Tools
Version: 0.6.1
Authors@R: c(person(given = "Mike", family = "Johnson", 
                    role = c("aut"), 
                    comment = c(ORCID = "0000-0002-5288-8350"), 
                                email = "jjohnson@lynker.com"),
            person("David", "Blodgett", 
                    role = c("aut", "cre"), 
                    email = "dblodgett@usgs.gov"))
Description: A collection of tools for manipulating hydrologic and hydraulic networks 
URL: https://github.com/DOI-USGS/hyRefactor
BugReports: https://github.com/DOI-USGS/hyRefactor/issues
Depends: 
    R (>= 3.5.0)
Imports: 
    data.table,
    dplyr,
    glue,
    httr,
    hydroloom,
    igraph,
    logger,
    lwgeom,
    methods,
    nhdplusTools,
    parallel,
    pbapply,
    rlang,
    rmapshaper,
    rvest,
    sf,
    stats,
    terra,
    tibble,
    tidyr,
    units,
    utils,
    yyjsonr
Suggests: 
    testthat
License: CC0 + LICENSE file
Encoding: UTF-8
LazyData: true
RoxygenNote: 7.3.3
VignetteBuilder: knitr
```

# `add_lengthmap`: Add Length Map to Refactored Network

## Description

This function replicates the member_COMID column of a refactored
network but adds a new notation Following each COMID is '.' which is proceeded
by the fraction of that COMID making up the new flowpath. For example 101.1
would indicate 100Equally 101.05 would indicate 50

## Usage

```r
add_lengthmap(flowpaths, length_table)
```

## Arguments

* `flowpaths`: a refactored flowpath network containing an member_COMID column
* `length_table`: a table of NHDPlus COMIDs and LENGTH to use as weights.
Can be found with `nhdplusTools::get_vaa("lengthkm")`

## Value

sf object

## Examples

```r
path <- system.file("extdata/walker_reconcile.gpkg", package = "hyRefactor")
fps  <- add_lengthmap(flowpaths = sf::read_sf(path),
length_table = nhdplusTools::get_vaa("lengthkm"))
```

# `add_lookup_table`: Generate Lookup table for refactored or aggregated network

## Description

Generate Lookup table for refactored or aggregated network

## Usage

```r
add_lookup_table(
  gpkg = NULL,
  refactored_gpkg = NULL,
  reconciled_layer = "flowpaths"
)
```

## Arguments

* `gpkg`: character path to gpkg containing aggregated network. Omit for 
refactored network lookup table creation.
* `refactored_gpkg`: character path to the gpkg for the refactored network 
used to create the aggregate network. If no aggregatedd gpkg is passed in, a 
lookup table will be added to this gpkg.
* `reconciled_layer`: character path layer name containing fully 
reconciled flowpaths. Ignored for aggregated network lookup table creation.

## Value

file path to modified gpkg

# `add_nonnetwork_divides`: Add Non Network Divides to Aggregated Fabric
The refactoring process intentionally drop catchments without a flowpath.
In cases where a seamless discritization of the landscape is needed, these 
area must be reintroduced from the reference dataset.

## Description

Add Non Network Divides to Aggregated Fabric
The refactoring process intentionally drop catchments without a flowpath.
In cases where a seamless discritization of the landscape is needed, these 
area must be reintroduced from the reference dataset.

## Usage

```r
add_nonnetwork_divides(
  gpkg = NULL,
  vpu = NULL,
  divides = NULL,
  huc12 = NULL,
  reference_gpkg = NULL,
  reference_divides = NULL,
  verbose = TRUE
)
```

## Arguments

* `gpkg`: a path to a gpkg
* `huc12`: huc12 to COMID crosswalk
* `reference_gpkg`: A path to the reference VPU geopackage (see get_hydrofabric(..., type = "reference"))
* `verbose`: Should messages be emitted?
* `divide`: If gpkg is NULL, then an sf data.frame, otherwise a the layer name. See details.

## Value

gpkg path

# `aggregate_along_mainstems`: Aggregate along network mainstems

## Description

Given a set of ideal catchment sizes, plus the
minimum allowable catchment size and segment length, aggregate the network along mainstems.

## Usage

```r
aggregate_along_mainstems(
  network_list,
  ideal_size_sqkm,
  min_area_sqkm,
  min_length_km,
  verbose = TRUE,
  cache_file = NULL
)
```

## Arguments

* `network_list`: a list containing flowline and catchment `sf` objects
* `min_area_sqkm`: The minimum allowable size of the output hydrofabric catchments
* `min_length_km`: The minimum allowable length of the output hydrofabric flowlines
* `ideal_size`: The ideal size of output hydrofabric catchments
* `term_cut`: cutoff integer to define terminal IDs

## Value

a list containing aggregated and validated flowline and catchment `sf` objects

# `aggregate_network_to_outlets`: Aggregate Network

## Description

Aggregates a catchment network according to a set of outlet.

## Usage

```r
aggregate_network_to_outlets(
  flowpath,
  outlets,
  da_thresh = NA,
  only_larger = FALSE,
  post_mortem_file = NA
)
```

## Arguments

* `flowpath`: sf data.frame Flowpaths with ID, toID, LevelPathID, and Hydroseq attributes.
* `outlets`: data.frame with "ID" and "type" columns. "ID" must be identifiers from
flowpath and divide data.frames. "type" should be "outlet", or "terminal".
"outlet" will include the specified ID.
"terminal" will be treated as a terminal node with nothing downstream.
* `da_thresh`: numeric Defaults to NA. A threshold total drainage area in the
units of the TotDASqKM
field of the flowpath data.frame. When automatically adding confluences to make
the network valid, tributary catchments under this threshold will be lumped with
the larger tributaries rather than being added to the set of output catchments.
* `only_larger`: boolean Defaults to TRUE. If TRUE when adding confluences to
make the network valid, only tributaries larger than the one with an upstream
outlet will be added. e.g. if a tributary is required in the model this will
add main stems that the tributary contributes to. Note that the NHDPlus treats
divergences as part of the main stem, so the da_thresh may still be needed to
eliminate small tributary catchments introduced by divergences near confluences.
* `post_mortem_file`: rda file to dump environment to in case of error

## Details

This function operates on the catchment network as a node-edge graph.
The outlet types are required to ensure that graph searches start from the
appropriate nodes and includes the appropriate catchments. Outlets such as gages
should be treated as "outlet" outlets.
While it may be possible for the algorithm to determine terminal outlets, at this
time, it is required that they be specified explicitely as "terminal" outlet types.
The function checks supplied outlets to make sure they connect downstream. Checks
verify that the outlet of the levelpath (main stem of a total catchment) of each
supplied outlet is
in the supplied outlet set. If the outlet of a levelpath is not in the supplied set, it
is added along with other catchments that contribute to the same receiving catchment.
These checks ensure that all output catchments have one and only one input and output
nexus and that all catchments are well-connected.

## Examples

```r
source(system.file("extdata", "walker_data.R", package = "nhdplusTools"))

fline <- dplyr::right_join(dplyr::select(walker_flowline, COMID),
                           nhdplusTools::prepare_nhdplus(walker_flowline, 0, 0, 0, FALSE))

fline <- dplyr::select(fline, ID = COMID, toID = toCOMID,
                       LevelPathID = LevelPathI, Hydroseq)

outlets <- data.frame(ID = c(5329357, 5329317, 5329365, 5329303, 5329435, 5329817),
                      type = c("outlet", "outlet", "outlet", "terminal", "outlet", "outlet"),
                      stringsAsFactors = FALSE)

aggregated <- aggregate_network_to_outlets(fline, outlets)

aggregated <- aggregate_network_to_outlets(fline, outlets)

outlets <- dplyr::filter(fline, ID %in% outlets$ID)

outlets <- nhdplusTools::get_node(outlets)

plot(aggregated$fline_sets$geom, lwd = 3, col = "red")
plot(walker_flowline$geom, lwd = .7, col = "blue", add = TRUE)
plot(outlets$geometry, add = TRUE)
```

# `aggregate_to_distribution`: Aggregate Network to Uniform Size

## Description

This function aggregates a network to a desired size distribution while
enforcing minimum flowpath legnths and catchment areas. Additionally a set of explicit nexus
locations can be provided over which the network cannot be aggregated (see poi_to_outlet)

## Usage

```r
aggregate_to_distribution(
  gpkg = NULL,
  vpu = NULL,
  flowpath = NULL,
  divide = NULL,
  crs = 5070,
  pois = NULL,
  ideal_size_sqkm = 10,
  min_length_km = 1,
  min_area_sqkm = 3,
  outfile = NULL,
  log = TRUE,
  overwrite = FALSE,
  cache = FALSE,
  verbose = TRUE
)
```

## Arguments

* `gpkg`: a path to a gpkg
* `flowpath`: If gpkg is NULL, then an sf data.frame, otherwise a the layer name. See details.
* `divide`: If gpkg is NULL, then an sf data.frame, otherwise a the layer name. See details.
* `ideal_size_sqkm`: The ideal size of catchments (default = 10 sqkm)
* `min_length_km`: The minimum allowable length of flowpath features (default = 1 km)
* `min_area_sqkm`: The minimum allowable area of catchment features (default = 3 sqkm)
* `outfile`: of not NULL, where to write the output files
* `log`: a filepath to write messages to or Boolean (TRUE = print to console; FALSE = no messages)
* `overwrite`: overwrite existing gf file. Default is FALSE
* `verbose`: print status updates. Default = TRUE
* `outlets`: data.frame with mandatory "ID" column and optional "POI_ID" column. "ID" must be identifiers from
flowpath and divide data.frames and POI ID must be unique.
* `nexus_locations`: a data.frame with columns specifying the ID, and the nexus type.

## Details

If gpkg is not NULL, divide and flowpath can be left NULL as well. The code attempts to
infer the correct layers. The divides layer will be the one including the word "divide" or "catchment" and the
flowpath layer will be the one including 'flowpath' or 'flowline'. If no layers, or more then one layer are deemed possible
for each input, then the function will stop and ask for explicit names.

## Value

if outfile = TRUE, a file path, else a list object

# `aggregate_to_outlets`: Aggregate Catchments

## Description

Aggregates catchments according to a set of outlet catchments. 
Network aggregation is completed using: See `[aggregate_network_to_outles](aggregate_network_to_outles)`.

## Usage

```r
aggregate_to_outlets(
  gpkg = NULL,
  flowpath = NULL,
  divide = NULL,
  outlets = NULL,
  zero_order = NULL,
  coastal_cats = NULL,
  da_thresh = NA,
  only_larger = FALSE,
  post_mortem_file = NA,
  keep = NULL
)
```

## Arguments

* `flowpath`: sf data.frame Flowpaths as generated by `refactor_nhdplus`
* `divide`: sf data.frame Reconciled catchment divides as generated by
`reconcile_catchment_divides`
* `outlets`: data.frame with "ID" and "type" columns. "ID" must be identifiers from
flowpath and divide data.frames. "type" should be "outlet", or "terminal".
"outlet" will include the specified ID.
"terminal" will be treated as a terminal node with nothing downstream.
* `zero_order`: list of vectors containing IDs to be aggregated into 0-order catchments.
* `coastal_cats`: sf data.frame with coastal catchments to be used with zero order.
* `da_thresh`: numeric See `[aggregate_network_to_outles](aggregate_network_to_outles)`
* `only_larger`: boolean See `[aggregate_network_to_outles](aggregate_network_to_outles)`
* `post_mortem_file`: rda file to dump environment to in case of error
* `keep`: logical passed along to `[clean_geometry](clean_geometry)`

## Details

See `[aggregate_network_to_outlets](aggregate_network_to_outlets)`

## Examples

```r
source(system.file("extdata", "walker_data.R", package = "hyRefactor"))
outlets <- data.frame(ID = c(31, 3, 5, 1, 45, 92),
 type = c("outlet", "outlet", "outlet", "terminal", "outlet", "outlet"),
 stringsAsFactors = FALSE)
aggregated <- aggregate_to_outlets(flowpath = walker_fline_rec, 
                                   divide = walker_catchment_rec, 
                                   outlets = outlets)
plot(aggregated$cat_sets$geom, lwd = 3, border = "red")
plot(walker_catchment_rec$geom, lwd = 1.5, border = "green", col = NA, add = TRUE)
plot(walker_catchment$geom, lwd = 1, add = TRUE)
plot(walker_flowline$geom, lwd = .7, col = "blue", add = TRUE)
plot(aggregated$cat_sets$geom, lwd = 3, border = "black")
plot(aggregated$fline_sets$geom, lwd = 3, col = "red", add = TRUE)
plot(walker_flowline$geom, lwd = .7, col = "blue", add = TRUE)
```

# `clean_geometry`: Clean Catchment Geometry

## Description

Fixes geometry issues present in catchments derived from DEMs.
These include, but are not limited to disjoint polygon fragments, artifacts
from the DEM used to generate the catchments, and non-valid geometry topologies.
A secondary goal of this functions is to provide a way to reduce the data column
of the catchments by offering a topology preserving simplification
through `[ms_simplify](https://rdrr.io/pkg/rmapshaper/man/ms_simplify.html)`.
Generally a "keep" parameter of .9 seems appropriate for the resolution of
the data but can be modified in function

## Usage

```r
clean_geometry(
  catchments,
  flowlines = NULL,
  fl_ID = NULL,
  ID = "ID",
  keep = NULL,
  crs = 5070,
  grid = 9e-04,
  gb = 8,
  force = FALSE,
  sys = NULL
)
```

## Arguments

* `catchments`: catchments geometries to fix
* `flowlines`: flowlines geometries to filter largest unit (optional)
* `fl_ID`: flowlines unique identifier
* `ID`: name of uniquely identifying column
* `keep`: proportion of points to retain in geometry simplification
(0-1; default 0.05). See `[ms_simplify](https://rdrr.io/pkg/rmapshaper/man/ms_simplify.html)`.
If NULL, then no simplification will be executed.
* `crs`: integer or object compatible with sf::st_crs coordinate reference.
Should be a projection that supports area-calculations.
* `gb`: The amount of heap memory to be allocated when force = TRUE
* `force`: should the mapshaper/mapshaper-xl binaries be used directly for simplification?
* `sys`: logical should the mapshaper system library be used. If NULL 
the system library will be used if available.

## Value

sf object

# `collapse_flowlines`: Collapse NHDPlus Network

## Description

Refactors the NHDPlus flowline network, eliminating short and
non-confluence flowlines. The aim of this function is to create flowpaths
that describe a network of catchments that combines complex hydrology near
confluences into upstream catchments and removes very short flowlines along mainstem
flow-paths.

## Usage

```r
collapse_flowlines(
  flines,
  thresh,
  add_category = FALSE,
  mainstem_thresh = NULL,
  exclude_cats = NULL,
  warn = TRUE
)
```

## Arguments

* `flines`: data.frame with COMID, toCOMID, LENGTHKM, Hydroseq, and LevelPathI columns
* `thresh`: numeric a length threshold (km). Flowlines shorter than this
will be collapsed with up or downstream flowlines.
* `add_category`: boolean if combination category is desired in output, set
to TRUE
* `mainstem_thresh`: numeric threshold for combining inter-confluence
mainstems
* `exclude_cats`: integer vector of COMIDs to be excluded from collapse modifications.
* `warn`: boolean controls whether warning an status messages are printed

## Seealso

The `[refactor_nhdplus](refactor_nhdplus)` function implements a complete
workflow using `collapse_flowlines()`.

## Value

A refactored network with merged up and down flowlines.

# `collapse_headwaters`: Collapse Headwaters

## Description

This function identifies small (pathlength or area) headwater catchments and
collapses them into the existing network until none remain.
Headwaters are those segments in which there are no inflows (!ID

## Usage

```r
collapse_headwaters(
  network_list,
  min_area_sqkm = 3,
  min_length_km = 1,
  verbose = TRUE,
  cache_file = NULL
)
```

## Arguments

* `network_list`: a list containing flowpath and catchment `sf` objects
* `min_area_sqkm`: The minimum allowable size of the output hydrofabric catchments
* `min_length_km`: The minimum allowable length of the output hydrofabric flowlines
* `verbose`: should messages be emitted?
* `cache_file`: If not NULL results will be written to a provide path (.gpkg)

## Value

a list containing flowpath and catchment `sf` objects

# `create_style_row`: Create a style row from the given parameters.

## Description

Create a style row from the given parameters.

## Usage

```r
create_style_row(gpkg_path, layer_name, style_name, style_qml)
```

## Arguments

* `gpkg_path`: Path to GeoPackage
* `layer_name`: Layer to create style for
* `style_name`: Name of the new style
* `style_qml`: QML contents for the new style

## Keyword

internal

## Value

1-row data.frame in the layer_styles table schema

# `download_elev`: Download Elevation and Derivatives

## Description

Download Elevation and Derivatives

## Usage

```r
download_elev(product, out_dir, regions = NULL)
```

## Arguments

* `product`: character DEM, or FDRFAC.
* `out_dir`: path to directory to store output.
* `regions`: character vector of two digit hydrologic

# `download_fdr_fac`: Download FDR FAC

## Description

Download FDR FAC

## Usage

```r
download_fdr_fac(out_dir, regions = NULL)
```

## Arguments

* `out_dir`: path to directory to store output.
* `regions`: character vector of two digit hydrologic

# `get_minimal_network`: Get Minimal Network

## Description

Given a set of outlets, will generate a minimal network by
calling `[aggregate_network_to_outlets](aggregate_network_to_outlets)` and adding nhdplus attributes to the result.
If geometry is included with the network, it will be merged and returned.

## Usage

```r
get_minimal_network(flowpath, outlets)
```

## Arguments

* `flowpath`: sf data.frame Flowpaths with ID, toID, LevelPathID, 
Hydroseq and LENGTHKM and AreaSqKM attributes.
* `outlets`: data.frame with "ID" and "type" columns. "ID" must be identifiers from
flowpath and divide data.frames. "type" should be "outlet", or "terminal".
"outlet" will include the specified ID.
"terminal" will be treated as a terminal node with nothing downstream.

## Value

a data.frame (potentially including an sfc list column) with
attributes generated by `[add_plus_network_attributes](https://rdrr.io/pkg/nhdplusTools/man/add_plus_network_attributes.html)`and a list column "set" containing members of each output flowpath.

## Examples

```r
source(system.file("extdata", "walker_data.R", package = "nhdplusTools"))
fline <- walker_flowline

outlets <- data.frame(ID = c(5329357, 5329317, 5329365, 5329435, 5329817),
                      type = c("outlet", "outlet", "outlet", "outlet", "outlet"))

#' Add toCOMID
fline <- nhdplusTools::get_tocomid(fline, add = TRUE)

# get attributes set
fline <- dplyr::select(fline, ID = comid, toID = tocomid,
                       LevelPathID = levelpathi, hydroseq = hydroseq,
                       AreaSqKM = areasqkm, LENGTHKM = lengthkm)

min_net <- get_minimal_network(fline, outlets)

plot(sf::st_geometry(fline), col = "blue")
plot(sf::st_geometry(min_net), lwd = 2, add = TRUE)
plot(sf::st_geometry(nhdplusTools::get_node(min_net)), add = TRUE)
```

# `get_row_col`: Get Row and Column

## Description

Get Row and Column

## Usage

```r
get_row_col(fdr, start, fac_matrix)
```

## Arguments

* `fdr`: flow direction grid
* `start`: matrix (row, col)
* `fac_matrix`: flow accumulation matrix

# `map_outlet_ids`: Map outlets from COMID to ID for aggregate catchments

## Description

given reconciled flowlines and a set of source outlets,
returns a set of outlets with reconciled IDs suitable for use with 
aggregate_catchments.

## Usage

```r
map_outlet_ids(source_outlets, reconciled)
```

## Arguments

* `source_outlets`: data.frame with COMID and type columns
* `reconciled`: data.frame as returned by refactor workflow

# `prep_cat_fdr_fac`: Prep catchment with FDR/FAC

## Description

Prep catchment with FDR/FAC

## Usage

```r
prep_cat_fdr_fac(cat, fdr, fac)
```

## Arguments

* `cat`: catchment (sf object)
* `fdr`: flow direction grid
* `fac`: flow accumulation grid

# `read_hydrofabric`: Read Catchments and Flowpaths from Geopackage
Convenience function for reading two layers into a list

## Description

Read Catchments and Flowpaths from Geopackage
Convenience function for reading two layers into a list

## Usage

```r
read_hydrofabric(
  gpkg = NULL,
  catchments = NULL,
  flowpaths = NULL,
  realization = "all",
  crs = NULL,
  verbose = Sys.getenv("hyRefactor_verbose") != "false"
)
```

## Arguments

* `gpkg`: path to geopackage
* `realization`: what layers to read? Options: "catchemnts", "flowpaths", "all"
* `crs`: desired CRS, if NULL they stay as read. If all CRS layers arenot
* `catchment_name`: name of catchment layer. If NULL, attempts to find divides layer
* `flowpath_name`: name of flowpath layer. If NULL, attempts to find flowpath layer
* `vebose`: should message be emitted?

## Value

list

# `read_qml`: Read a QML file from the inst/qml directory

## Description

Read a QML file from the inst/qml directory

## Usage

```r
read_qml(name)
```

## Arguments

* `name`: Name of QML file without extension

## Keyword

internal

## Value

the contents of name.qml.

# `reconcile_catchment_divides`: Reconcile Catchment Divides

## Description

Reconciles catchment divides according to the output of
`[reconcile_collapsed_flowlines](reconcile_collapsed_flowlines)` and `[refactor_nhdplus](refactor_nhdplus)`

## Usage

```r
reconcile_catchment_divides(
  catchment,
  fline_ref,
  fline_rec,
  fdr = NULL,
  fac = NULL,
  para = 2,
  cache = NULL,
  min_area_m = 800,
  snap_distance_m = 100,
  simplify_tolerance_m = 40,
  vector_crs = 5070,
  fix_catchments = TRUE,
  keep = NULL
)
```

## Arguments

* `catchment`: sf data.frame NHDPlus Catchment or CatchmentSP layers for
included COMIDs
* `fline_ref`: sf data.frame flowlines as returned by
`[refactor_nhdplus](refactor_nhdplus)` and `[reconcile_collapsed_flowlines](reconcile_collapsed_flowlines)`
* `fline_rec`: sf data.frame flowpaths as returned by
`[reconcile_collapsed_flowlines](reconcile_collapsed_flowlines)`
* `fdr`: character path to D8 flow direction
* `fac`: character path to flow accumulation
* `para`: integer numer of cores to use for parallel execution
* `cache`: path .rda to cache incremental outputs
* `min_area_m`: minimum area in m^2 to filter out slivers (caution, use with care!!)
* `snap_distance_m`: distance in meters to snap SpatRaster generated geometry to polygon geometry
* `simplify_tolerance_m`: dTolerance in meters for simplification of grid-cell based polygons
* `vector_crs`: integer or object compatible with sf::st_crs coordinate reference.
Should be a projection that supports area-calculations.
* `fix_catchments`: logical. should catchment geometries be rectified?
* `keep`: Only applicable if fix_catchments = TRUE. Defines the proportion 
of points to retain in geometry simplification (0-1; default 0.05). 
See `[ms_simplify](https://rdrr.io/pkg/rmapshaper/man/ms_simplify.html)`. Set to NULL to skip
simplification.

## Details

Note that all inputs must be passed in the same projection.

## Seealso

The `[refactor_nhdplus](refactor_nhdplus)` function implements a complete
workflow using `reconcile_collapsed_flowlines()` and can be used in prep
for this function.

## Value

Catchment divides that have been split and collapsed according to
input flowpaths

# `reconcile_collapsed_flowlines`: Reconcile Collapsed Flowlines

## Description

Reconciles output of collapse_flowlines giving a unique ID to
each new flowpath and providing a mapping to NHDPlus COMIDs.

## Usage

```r
reconcile_collapsed_flowlines(flines, geom = NULL, id = "COMID")
```

## Arguments

* `flines`: data.frame with COMID, toCOMID, LENGTHKM, LevelPathI, Hydroseq,
and TotDASqKM columns
* `geom`: sf data.frame for flines
* `id`: character id collumn name.

## Seealso

The `[refactor_nhdplus](refactor_nhdplus)` function implements a complete
workflow using `reconcile_collapsed_flowlines()`.

## Value

reconciled flowpaths with new ID, toID, LevelPathID, and Hydroseq identifiers.
Note that all the identifiers are new integer IDs. LevelPathID and Hydroseq are consistent
with the LevelPathID and Hydroseq from the input NHDPlus flowlines.

# `refactor`: Refactoring Wrapper

## Description

A wrapper around refactor_nhdplus and reconcile_catchment_divides

## Usage

```r
refactor(
  gpkg = NULL,
  flowpaths = NULL,
  catchments = NULL,
  pois = NULL,
  avoid = NULL,
  split_flines_meters = 10000,
  collapse_flines_meters = 1000,
  collapse_flines_main_meters = 1000,
  threshold = 25,
  min_area_m = 800,
  snap_distance_m = 100,
  simplify_tolerance_m = 40,
  cores = 1,
  fac = NULL,
  fdr = NULL,
  purge_non_dendritic = TRUE,
  keep = NULL,
  outfile = NULL
)
```

## Arguments

* `gpkg`: a starting GPKG
* `flowpaths`: Reference flowline features
* `catchments`: Reference catchment features
* `avoid`: integer vector of COMIDs to be excluded from collapse modifications.
* `split_flines_meters`: numeric the maximum length flowpath desired in the output.
* `collapse_flines_meters`: numeric the minimum length of inter-confluence flowpath desired in the output.
* `collapse_flines_main_meters`: numeric the minimum length of between-confluence flowpaths.
* `cores`: integer number of cores to use for parallel execution
* `fac`: path to flow accumulation grid. If NULL (default) then catchments are NOT reconciled.
* `fdr`: path to flow direction grid. If NULL (default) then catchments are NOT reconciled.
* `keep`: proportion of points to retain in geometry simplification (0-1; default 0.05). See ms_simplify. If NULL, then no simplification will be executed.
* `outfile`: path to geopackage to write refactored_flowlines, and if facfdr != NULL, refactored catchments.
* `events`: data.frame containing events

## Value

data to the specified gpkg

# `refactor_nhdplus`: Refactor NHDPlus

## Description

A complete network refactor workflow has been packaged
into this function. Builds a set of normalized catchment-flowpaths from
input flowline features. See details and vignettes for more information.

## Usage

```r
refactor_nhdplus(
  nhdplus_flines,
  split_flines_meters,
  split_flines_cores,
  collapse_flines_meters,
  collapse_flines_main_meters,
  out_refactored,
  out_reconciled,
  three_pass = FALSE,
  purge_non_dendritic = TRUE,
  exclude_cats = NULL,
  events = NULL,
  warn = TRUE
)
```

## Arguments

* `nhdplus_flines`: data.frame raw nhdplus flowline features as
derived from the national seamless geodatabase.
* `split_flines_meters`: numeric the maximum length flowpath desired
in the output.
* `split_flines_cores`: numeric the number of processing cores to use
while splitting flowlines.
* `collapse_flines_meters`: numeric the minimum length of
inter-confluence flowpath desired in the output.
* `collapse_flines_main_meters`: numeric the minimum length of
between-confluence flowpaths.
* `out_refactored`: character where to write a geopackage containing
the split and collapsed flowlines.
* `out_reconciled`: character where to write a geopackage containing
the reconciled flowpaths.
* `three_pass`: boolean whether to perform a three pass collapse or
single pass.
* `purge_non_dendritic`: boolean passed on to prepare_nhdplus
* `exclude_cats`: integer vector of COMIDs to be excluded from collapse modifications.
* `events`: data.frame containing events as generated by nhdplusTools::get_flowline_index()
* `warn`: boolean controls whether warning an status messages are printed

## Details

This is a convenient wrapper function that implements three phases
of the network refactor workflow: split, collapse, reconcile. See the
NHDPlus Refactor vignette for details of these three steps by running:
`vignette("refactor_nhdplus", package = "hyRefactor")`

## Seealso

In addition to `prepare_nhdplus` from the nhdplusTools package,
The following three functions are used in the `refactor_nhdplus` workflow.

1. `[split_flowlines](split_flowlines)`
1. `[collapse_flowlines](collapse_flowlines)`
1. `[reconcile_collapsed_flowlines](reconcile_collapsed_flowlines)`

## Examples

```r
source(system.file("extdata",
                   "sample_flines.R",
                   package = "nhdplusTools"))

nhdplus_flowlines <- sf::st_zm(sample_flines)

refactor_nhdplus(nhdplus_flines = nhdplus_flowlines,
                 split_flines_meters = 2000,
                 split_flines_cores = 2,
                 collapse_flines_meters = 500,
                 collapse_flines_main_meters = 500,
                 out_refactored = "temp.gpkg",
                 out_reconciled = "temp_rec.gpkg",
                 three_pass = TRUE,
                 purge_non_dendritic = FALSE,
                 warn = FALSE)
                 
unlink("temp.gpkg")
unlink("temp_rec.gpkg")
```

# `split_catchment_divide`: Split Catchment Divides

## Description

A catchment-divide splitting algorithm that works with a D8
flow direction grid and the output of nhdplus_refactor. See Vignette
for examples.

## Usage

```r
split_catchment_divide(
  catchment,
  fline,
  fdr,
  fac,
  lr = FALSE,
  min_area_m = 800,
  snap_distance_m = 100,
  simplify_tolerance_m = 40,
  vector_crs = NULL
)
```

## Arguments

* `catchment`: sf data.frame with one catchment divide
* `fline`: sf data.frame with one or more flowline segments in
upstream downstream order.
* `fdr`: character path to flow direction that fully covers the catchment
* `fac`: character path to flow accumulation that fuller covers the catchment
* `lr`: boolean should catchments be split along the left/right bank?
* `min_area_m`: minimum area in m^2 to filter out slivers (caution, use with care!!)
* `snap_distance_m`: distance in meters to snap SpatRaster generated geometry to polygon geometry
* `simplify_tolerance_m`: dTolerance in meters for simplification of grid-cell based polygons
* `vector_crs`: any object compatible with sf::st_crs. Used for vector-based calculations in case that 
fdr projection is not suitable (e.g. lon/lat) -- must result in units of meters.

## Value

Split catchment divides as an sfc geometry.

# `split_flowlines`: Split Flowlines

## Description

A wrapper for split_lines that works on nhdplus attributes

## Usage

```r
split_flowlines(flines, max_length = NULL, events = NULL, para = 0, avoid = NA)
```

## Arguments

* `flines`: data.frame with COMID, toCOMID, LENGTHKM
and LINESTRING sf column in "meters" projection
* `max_length`: maximum segment length to return
* `events`: data.frame containing events as generated by nhdplusTools::get_flowline_index() 
if an `identifier` attribute is included, it will be passed through in the output table.
* `para`: numeric how many threads to use in parallel computation
* `avoid`: vector of ids to avoid

## Seealso

The `[refactor_nhdplus](refactor_nhdplus)` function implements a complete
workflow using `split_flowlines()`.

## Value

All the flowlines with some split apart. COMIDs are returned as strings 
with a semantic part number appended. That is .1, .2, ... .10, .11, etc. are 
appended and must be treated as one would treat a semantic version. .1 is the 
most upstream and the sequence increases in the downstream direction.

## Examples

```r
source(system.file("extdata", "new_hope_data.R", package = "hyRefactor"))

new_hope_flowline <- 
  dplyr::right_join(dplyr::select(new_hope_flowline, COMID, REACHCODE, FromMeas, ToMeas),
                    suppressWarnings(nhdplusTools::prepare_nhdplus(
                      new_hope_flowline, 0, 0, 0, FALSE, warn = FALSE)),
                    by = "COMID")

split <- split_flowlines(suppressWarnings(sf::st_cast(sf::st_transform(
  new_hope_flowline, 5070), "LINESTRING")),
                         max_length = 2000, events = new_hope_events)
```

# `trace_upstream`: Trace Upstream

## Description

Trace Upstream

## Usage

```r
trace_upstream(start_point, cat, fdr, fac_matrix, fdr_matrix)
```

## Arguments

* `start_point`: row col index
* `cat`: catchment
* `fdr`: flow direction grid
* `fac_matrix`: flow accumulation matrix
* `fdr_matrix`: flow direction matrix

## Value

sfc

# `write_hydrofabric`: Write a hydrofabric gpkg
A hydrofabric consists of a flowpath, catchment,
and topology layer written to a self contained geopackage

## Description

Write a hydrofabric gpkg
A hydrofabric consists of a flowpath, catchment,
and topology layer written to a self contained geopackage

## Usage

```r
write_hydrofabric(network_list, outfile, verbose = TRUE, enforce_dm = TRUE)
```

## Arguments

* `network_list`: a list containing flowpaths and catchments
* `outfile`: a file (gpkg) where layers should be written
* `verbose`: should messages be emitted?
* `catchment_name`: the layer name for divides
* `flowpath_name`: the layer name for flowpaths

## Value

file path

