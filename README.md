# hyRefactor

## Tools for Manipulating the NHDPlus Network in Preparation for Hydrologic Modeling

The hyRefactor package was developed over a considerable period of time as part of a broad research project to develop a unified hydrofabric for the U.S. Geological Survey National Water Census and National Weather Service National Water Model. Work on this specific package has moved to a new development space under https://github.com/noaa-owp/hydrofab. That package will be released as a USGS data release when ready.

Software in this package has been rigorously tested (90% code coverage shown in [v0.4.8_coverage.html](v0.4.8_coverage.html)) and results of its use have been evaluated extensively. Any use outside of the National Hydrologic Geospatial Fabric workflow it was developed for may produce unexpected results.

Documentation in the package was developed as a best effort by the authors while the package was in development. Some exported functions may have limited documentation in which case package code should be inspected to understand nuances of the implementation.

### Installation:

```
install.packages("remotes")
remotes::install_git("https://code.usgs.gov/Water/hyRefactor")
```

This package is based around the same concepts as [nhdplusTools](https://doi.org/10.5066/P97AS8JD) and uses its utilities extensively.

Rendered documentation can be [found here.](docs/Reference_Manual_hyRefactor.md)  
Note: Large vignettes have been rendered to html and need to be downloaded and opened in a browser.

### What is Refactoring in the context of hydrographic data?

The concept of refactoring as intended here includes:

**splitting** large or long catchments to create a more uniform catchment size
distribution   
**collapsing** catchment topology to eliminate small catchments  

The package also includes "aggregation" functionality:
3) **aggregating** catchments into groups based on existing network topology  

This type of functionality is especially relevant to modeling applications that
need specific modeling unit characteristics but wish to preserve the network as
much as possible for interoperability.

### Check notes:
In addition to typical R package checking, a Dockerfile is included in this repository. Once built, it can be run with the following command.

```
docker build -t hyrefactor_test .

docker run --rm -it -v $PWD:/src hyrefactor_test /bin/bash -c "cp -r /src/* /check/ && cp /src/.Rbuildignore /check/ && cd /check && Rscript -e 'devtools::build()' && R CMD check --as-cran ../hyRefacto_*"
```

## Disclaimer

This information is preliminary or provisional and is subject to revision. It is being provided to meet the need for timely best science. The information has not received final approval by the U.S. Geological Survey (USGS) and is provided on the condition that neither the USGS nor the U.S. Government shall be held liable for any damages resulting from the authorized or unauthorized use of the information.

This software is in the public domain because it contains materials that originally came from the U.S. Geological Survey  (USGS), an agency of the United States Department of Interior. For more information, see the official USGS copyright policy at [https://www.usgs.gov/visual-id/credit_usgs.html#copyright](https://www.usgs.gov/visual-id/credit_usgs.html#copyright)

Although this software program has been used by the USGS, no warranty, expressed or implied, is made by the USGS or the U.S. Government as to the accuracy and functioning of the program and related program material nor shall the fact of distribution constitute any such warranty, and no responsibility is assumed by the USGS in connection therewith.

This software is provided "AS IS."

 [
    ![CC0](https://i.creativecommons.org/p/zero/1.0/88x31.png)
  ](https://creativecommons.org/publicdomain/zero/1.0/)
