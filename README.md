
<!-- README.md is generated from README.Rmd. Please edit that file -->

# hyRefactor

## Tools for Manipulating the NHDPlus Network in Preparation for Hydrologic Modeling

The goal of `hyRefactor` is to provide consistent hydrologic and
hydraulic network manipulation tool chains to achieve model application
ready datasets.

This software was used to make derivatives of the features in the
NHDPlusV2 geospatial dataset for use in hydrologic model applications.
It is not intended for users to deploy/use and may produce unexpected
results outside the workflow and environment in which it was
implemented. For users seeking to deploy a version of this software,
please see <https://github.com/noaa-owp/hydrofab>. The purpose of the
official software release established in 2024 is to document the
methodology and associated software used to create:
(<https://www.sciencebase.gov/catalog/item/60be0e53d34e86b93891012b>).

## Installation

You can install the development version of `hyRefactor` like so:

``` r
install.packages("remotes")
remotes::install_github("DOI-USGS/hyRefactor")
```

### Refactoring and Aggregating

The concept of refactoring as intended here includes:

1)  **Splitting** large or long catchments to create a more uniform
    catchment size distribution,  
2)  **collapsing** catchment topology to eliminate small catchments

The concept of aggregating as intended here includes **aggregating**
catchments into groups based on existing network topology and defined
criteria. Two primary use cases are offered:

1.  Aggregating to a set of defined outlet locations
2.  Merging catchments to a uniform size with enforced minimum areas and
    lengths.

This type of functionality is especially relevant to modeling
applications that need specific modeling unit characteristics but wish
to preserve the network as much as possible for interoperability with
other applications

## Questions:

Open issues at: <https://github.com/DOI-USGS/hyRefactor/issues>

## Disclaimer

This information is preliminary or provisional and is subject to
revision. It is being provided to meet the need for timely best science.
The information has not received final approval by the U.S. Geological
Survey (USGS) and is provided on the condition that neither the USGS nor
the U.S. Government shall be held liable for any damages resulting from
the authorized or unauthorized use of the information.

This software is in the public domain because it contains materials that
originally came from the U.S. Geological Survey (USGS), an agency of the
United States Department of Interior. For more information, see the
official USGS copyright policy at
<https://www.usgs.gov/visual-id/credit_usgs.html#copyright>

Although this software program has been used by the USGS, no warranty,
expressed or implied, is made by the USGS or the U.S. Government as to
the accuracy and functioning of the program and related program material
nor shall the fact of distribution constitute any such warranty, and no
responsibility is assumed by the USGS in connection therewith.

This software is provided “AS IS.”

[![CC0](https://i.creativecommons.org/p/zero/1.0/88x31.png)](https://creativecommons.org/publicdomain/zero/1.0/)
