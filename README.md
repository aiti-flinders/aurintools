
<!-- README.md is generated from README.Rmd. Please edit that file -->

# aurintools

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of aurintools is to provide programmatic access to the AURIN
API. This package is not affiliated with AURIN.

Current features of this package include:

-   Creation of a token to authorise access to the AURIN API
-   Search AURIN datasets
-   Retrieve the API ID for given datasets
-   Download AURIN data
-   Load a downloaded data into an R environment
-   Perform coordinate transformations

## Installation

You can install the development version of aurintools from
[GitHub](https://github.com/aiti-flinders) with:

``` r
if (!require(remotes)) {
  install.packages("remotes")
  library(remotes)
}
#> Loading required package: remotes
#> Warning: package 'remotes' was built under R version 4.0.5

remotes::install_github("aiti-flinders/aurintools")
library(aurintools)
#> Loading required package: sf
#> Warning: package 'sf' was built under R version 4.0.5
#> Linking to GEOS 3.9.0, GDAL 3.2.1, PROJ 7.2.1
```

## Authorising access to the AURIN API.

In order to access the AURIN API, you must first register through the
AURIN website. First, make sure you read and agree to the [AURIN Terms
of Use](https://aurin.org.au/legal/aurin-terms-of-use/#aurin_api).

You can register for access to the AURIN API at
<https://aurin.org.au/resources/aurin-apis/sign-up/>

Once you have received your username and password from AURIN, you can
authorise your R Project to use the API by the following command.
Replace `"username"` with your provided username and `"password"` with
your provided password. This function will create a file called
`aurin_wfs_connection.xml` in your current directory.

`aurin_authorise_api(username = "username", password = "password")`

## Downloading a file from AURIN, and reading it into R.

First, determine the API ID for the dataset you are interested. You can
browse AURIN datasets at <https://data.aurin.org.au/> or using the in
built function `fetch_aurin_id()`. This returns the top 10 results for
your search term. If you know the exact name of the dataset, use that as
your search term, and specify `exact = TRUE`.

``` r
#Search for a dataset
aurin_id("toilets")
#> Multiple AURIN datasets found. If you know the exact name of the dataset you are looking for, specify `exact = TRUE`.
#>             
#> You can likely copy and paste the title from the data below, if the search was successful.
#> # A tibble: 6 x 2
#>   title                                                  name                   
#>   <chr>                                                  <chr>                  
#> 1 Public Toilets 2004-2014 for Australia                 uq-erg-public-toilets-~
#> 2 DSS - National Public Toilets (Point) 2017             au-govt-dss-national-p~
#> 3 Department of Health - National Toilet Map - June 2018 au-govt-doh-national-t~
#> 4 SAHEALTH - Playground and Amenities (point) 2014       sa-govt-sa-health-adh-~
#> 5 SA DEW - Parks - Features and Facilities (point) 2015  sa-govt-dew-adh-dew-sa~
#> 6 VIC DELWP - Recreation Assets (Points)                 vic-govt-delwp-datavic~


#Get the API ID for a specific dataset
toilets_id <- aurin_id("DSS - National Public Toilets (Point) 2017", exact = TRUE)
```

Once you have the API ID for the data you are interested, you can
download it. Currently, the only option is to download the file as a
.geoJSON. By default, the file will be downloaded to a folder in your
current directory called `out`. If the download is successful, the
console will return `character(0)`.

``` r
toilets <- aurin_download_file(api_id = toilets_id, 
                    out_file_name = "toilets",
                    out_folder = "out")

toilets_data <- read_aurin(toilets)
#> Reading layer `aurin:datasource-AU_Govt_DSS-UoM_AURIN_national_public_toilets_2017' from data source 
#>   `C:\Users\gamb0043\OneDrive - Flinders\Projects\R\aiti-flinders\aurintools\out\toilets.geoJSON' 
#>   using driver `GeoJSON'
#> Simple feature collection with 18789 features and 46 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 113.4102 ymin: -43.582 xmax: 153.6263 ymax: -10.5702
#> Geodetic CRS:  GDA94

toilets_data
#> Simple feature collection with 18789 features and 46 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 113.4102 ymin: -43.582 xmax: 153.6263 ymax: -10.5702
#> Geodetic CRS:  GDA94
#> First 10 features:
#>                                                                                          gml_id
#> 1  datasource-AU_Govt_DSS-UoM_AURIN_national_public_toilets_2017.fid--52980058_17c06c905f3_1284
#> 2  datasource-AU_Govt_DSS-UoM_AURIN_national_public_toilets_2017.fid--52980058_17c06c905f3_1285
#> 3  datasource-AU_Govt_DSS-UoM_AURIN_national_public_toilets_2017.fid--52980058_17c06c905f3_1286
#> 4  datasource-AU_Govt_DSS-UoM_AURIN_national_public_toilets_2017.fid--52980058_17c06c905f3_1287
#> 5  datasource-AU_Govt_DSS-UoM_AURIN_national_public_toilets_2017.fid--52980058_17c06c905f3_1288
#> 6  datasource-AU_Govt_DSS-UoM_AURIN_national_public_toilets_2017.fid--52980058_17c06c905f3_1289
#> 7  datasource-AU_Govt_DSS-UoM_AURIN_national_public_toilets_2017.fid--52980058_17c06c905f3_128a
#> 8  datasource-AU_Govt_DSS-UoM_AURIN_national_public_toilets_2017.fid--52980058_17c06c905f3_128b
#> 9  datasource-AU_Govt_DSS-UoM_AURIN_national_public_toilets_2017.fid--52980058_17c06c905f3_128c
#> 10 datasource-AU_Govt_DSS-UoM_AURIN_national_public_toilets_2017.fid--52980058_17c06c905f3_128d
#>    toilet_id                                  url             name
#> 1        341  https://toiletmap.gov.au/toilet/341 Elsie Jones Park
#> 2        418  https://toiletmap.gov.au/toilet/418        Lucky Bay
#> 3        634  https://toiletmap.gov.au/toilet/634      Olds Park 2
#> 4       1150 https://toiletmap.gov.au/toilet/1150   Jaeger Reserve
#> 5       1207 https://toiletmap.gov.au/toilet/1207     Lake Jualbup
#> 6       1535 https://toiletmap.gov.au/toilet/1535      Earl Street
#> 7       1590 https://toiletmap.gov.au/toilet/1590  Truckalizer Bay
#> 8       1913 https://toiletmap.gov.au/toilet/1913       Hemisphere
#> 9       2081 https://toiletmap.gov.au/toilet/2081 Eden Valley Road
#> 10      2377 https://toiletmap.gov.au/toilet/2377      Wilson Road
#>                    address1          town             state postcode  male
#> 1              Alden Street       Clifton        Queensland     4361  TRUE
#> 2            Lucky Bay Road     Lucky Bay   South Australia     5602  TRUE
#> 3               Holley Road      Mortdale   New South Wales     2223  TRUE
#> 4               Hill Street        Orange   New South Wales     2800  TRUE
#> 5              Evans Street  Shenton Park Western Australia     6008 FALSE
#> 6               Earl Street Coffs Harbour   New South Wales     2450  TRUE
#> 7           Davidson Street    Deniliquin   New South Wales     2710  TRUE
#> 8               High Street       Belmont          Victoria     3216  TRUE
#> 9  Eden Valley-Moculta Road      Keyneton   South Australia     5353  TRUE
#> 10              Wilson Road   Wattle Glen          Victoria     3096  TRUE
#>    female unisex dump_point     facility_type access_limited payment_required
#> 1    TRUE  FALSE      FALSE   Park or reserve          FALSE            FALSE
#> 2    TRUE  FALSE      FALSE              <NA>          FALSE            FALSE
#> 3    TRUE  FALSE      FALSE   Park or reserve          FALSE            FALSE
#> 4    TRUE  FALSE      FALSE   Park or reserve          FALSE            FALSE
#> 5   FALSE   TRUE      FALSE   Park or reserve          FALSE            FALSE
#> 6    TRUE  FALSE      FALSE Sporting facility          FALSE            FALSE
#> 7    TRUE  FALSE      FALSE          Car park          FALSE            FALSE
#> 8    TRUE  FALSE      FALSE              <NA>          FALSE            FALSE
#> 9    TRUE  FALSE      FALSE   Park or reserve          FALSE            FALSE
#> 10   TRUE  FALSE      FALSE              <NA>          FALSE            FALSE
#>    key_required parking accessible_male accessible_female accessible_unisex
#> 1         FALSE   FALSE            TRUE              TRUE             FALSE
#> 2         FALSE    TRUE           FALSE             FALSE             FALSE
#> 3         FALSE   FALSE            TRUE              TRUE             FALSE
#> 4         FALSE   FALSE           FALSE             FALSE             FALSE
#> 5         FALSE   FALSE           FALSE             FALSE              TRUE
#> 6         FALSE    TRUE           FALSE             FALSE             FALSE
#> 7         FALSE    TRUE           FALSE             FALSE             FALSE
#> 8         FALSE   FALSE            TRUE              TRUE             FALSE
#> 9         FALSE   FALSE            TRUE              TRUE             FALSE
#> 10        FALSE   FALSE           FALSE             FALSE             FALSE
#>     mlak parking_accessible ambulant lh_transfer rh_transfer adult_change
#> 1  FALSE              FALSE    FALSE       FALSE       FALSE        FALSE
#> 2  FALSE               TRUE    FALSE       FALSE       FALSE        FALSE
#> 3   TRUE              FALSE    FALSE       FALSE       FALSE        FALSE
#> 4  FALSE              FALSE    FALSE       FALSE       FALSE        FALSE
#> 5  FALSE              FALSE    FALSE       FALSE       FALSE        FALSE
#> 6  FALSE               TRUE    FALSE       FALSE       FALSE        FALSE
#> 7  FALSE              FALSE    FALSE       FALSE       FALSE        FALSE
#> 8  FALSE              FALSE    FALSE       FALSE       FALSE        FALSE
#> 9  FALSE              FALSE    FALSE       FALSE       FALSE        FALSE
#> 10 FALSE              FALSE    FALSE       FALSE       FALSE        FALSE
#>          is_open baby_change showers drinking_water sharps_disposal
#> 1       AllHours       FALSE   FALSE          FALSE           FALSE
#> 2       AllHours       FALSE   FALSE          FALSE           FALSE
#> 3       Variable       FALSE   FALSE          FALSE           FALSE
#> 4  DaylightHours       FALSE   FALSE          FALSE           FALSE
#> 5       AllHours       FALSE   FALSE          FALSE            TRUE
#> 6       AllHours       FALSE   FALSE          FALSE            TRUE
#> 7       AllHours       FALSE   FALSE          FALSE           FALSE
#> 8       AllHours       FALSE   FALSE          FALSE           FALSE
#> 9       AllHours       FALSE   FALSE          FALSE           FALSE
#> 10      AllHours       FALSE   FALSE          FALSE           FALSE
#>    sanitary_disposal                                      icon_url
#> 1              FALSE https://toiletmap.gov.au/images/icons/mfa.png
#> 2               TRUE  https://toiletmap.gov.au/images/icons/mf.png
#> 3              FALSE https://toiletmap.gov.au/images/icons/mfa.png
#> 4              FALSE  https://toiletmap.gov.au/images/icons/mf.png
#> 5               TRUE https://toiletmap.gov.au/images/icons/mfa.png
#> 6              FALSE  https://toiletmap.gov.au/images/icons/mf.png
#> 7              FALSE  https://toiletmap.gov.au/images/icons/mf.png
#> 8              FALSE https://toiletmap.gov.au/images/icons/mfa.png
#> 9              FALSE https://toiletmap.gov.au/images/icons/mfa.png
#> 10             FALSE  https://toiletmap.gov.au/images/icons/mf.png
#>                              icon_alt_text   status  latitude longitude
#> 1  Male and Female, or Unisex (Accessible) Verified -27.93137  151.9128
#> 2               Male and Female, or Unisex Verified -33.70644  137.0388
#> 3  Male and Female, or Unisex (Accessible) Verified -33.95907  151.0731
#> 4               Male and Female, or Unisex Verified -33.27453  149.0949
#> 5  Male and Female, or Unisex (Accessible) Verified -31.95966  115.8110
#> 6               Male and Female, or Unisex Verified -30.30045  153.1177
#> 7               Male and Female, or Unisex Verified -35.52487  144.9788
#> 8  Male and Female, or Unisex (Accessible) Verified -38.17437  144.3429
#> 9  Male and Female, or Unisex (Accessible) Verified -34.56854  139.1270
#> 10              Male and Female, or Unisex Verified -37.66025  145.1802
#>    opening_hours openinghours_note toilet_type
#> 1           <NA>              <NA>        <NA>
#> 2           <NA>              <NA>        <NA>
#> 3        6am-9pm         6am - 9pm        <NA>
#> 4           <NA>              <NA>        <NA>
#> 5           <NA>              <NA>   Automatic
#> 6           <NA>              <NA>    Sewerage
#> 7           <NA>              <NA>    Sewerage
#> 8           <NA>              <NA>        <NA>
#> 9           <NA>              <NA>      Septic
#> 10          <NA>              <NA>        <NA>
#>                                 address_note notes parking_note
#> 1                                       <NA>  <NA>         <NA>
#> 2                                       <NA>  <NA>         <NA>
#> 3                                       <NA>  <NA>         <NA>
#> 4                                       <NA>  <NA>         <NA>
#> 5                                       <NA>  <NA>         <NA>
#> 6                                       <NA>  <NA>         <NA>
#> 7                                       <NA>  <NA>         <NA>
#> 8                                       <NA>  <NA>         <NA>
#> 9  The toilet is located at the public oval.  <NA>         <NA>
#> 10                                      <NA>  <NA>         <NA>
#>    access_parking_note accessible_note access_note                  geometry
#> 1                 <NA>            <NA>        <NA> POINT (151.9128 -27.9314)
#> 2                 <NA>            <NA>        <NA> POINT (137.0388 -33.7064)
#> 3                 <NA>            <NA>        <NA> POINT (151.0731 -33.9591)
#> 4                 <NA>            <NA>        <NA> POINT (149.0949 -33.2745)
#> 5                 <NA>            <NA>        <NA>  POINT (115.811 -31.9597)
#> 6                 <NA>            <NA>        <NA> POINT (153.1177 -30.3004)
#> 7                 <NA>            <NA>        <NA> POINT (144.9788 -35.5249)
#> 8                 <NA>            <NA>        <NA> POINT (144.3429 -38.1744)
#> 9                 <NA>            <NA>        <NA>  POINT (139.127 -34.5685)
#> 10                <NA>            <NA>        <NA> POINT (145.1802 -37.6603)
```
