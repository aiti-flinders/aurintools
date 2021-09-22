#' Fetch the API ID for an AURIN dataset.
#'
#' @param search (string) Search term.
#' @param exact (logical) If you know the exact name of the dataset you are looking for, specify exact = TRUE.
#' This should return only one API ID.
#'
#' @return AURIN API ID for a given dataset
#' @export
#'
#' @importFrom dplyr "%>%"
#' @importFrom rlang .data
#' @examples \dontrun{aurin_api("DSS - National Public Toilets (Point) 2017", exact = TRUE)}
#'
aurin_id <- function(search, exact = FALSE) {
  url <- paste0("https://data.aurin.org.au/api/3/action/package_search?q=", search, "&rows=10")

  json_data  <- jsonlite::read_json(path = url, simplifyVector = TRUE)

  results <- data.frame(json_data$result$results)

  results <- tidyr::unnest(results[c("title", "name", "extras")], .data$extras)


  if (isTRUE(exact) | nrow(dplyr::distinct(results, .data$title)) == 1) {

    results %>%
      dplyr::filter(grepl(search, .data$title, fixed = TRUE),
                    .data$key == "AURIN Open API ID") %>%
      dplyr::pull(.data$value)

  } else if (nrow(dplyr::distinct(results, .data$title)) > 1) {

    message("Multiple AURIN datasets found. If you know the exact name of the dataset you are looking for, specify `exact = TRUE`.
            \nYou can likely copy and paste the title from the data below, if the search was successful.")
    results %>%
      dplyr::distinct(.data$title)

  }


}

#' Authorise project to use AURIN API.
#'
#' @description This creates an aurin_wfs_connection.xml file if one
#' does not already exist. If you specify a username and password, it will
#' also add them to the .xml file. See `https://aurin.org.au/resources/aurin-apis/`
#' to register for access to the API.
#'
#' @param username AURIN API username as provided by AURIN.
#' @param password AURIN API password as provided by AURIN.
#'
#' @return NULL
#' @export
#'
#' @importFrom rlang .data
#'
#' @examples \dontrun{aurin_authorise_api()}
aurin_authorise_api <- function(username = NULL, password = NULL) {

  #First check the file exists:


  exists <- file.exists(here::here("aurin_wfs_connection.xml"))

  if (isFALSE(exists)) {

    message("No `aurin_wfs_connection.xml` file found in current working directory.
            \nCreating a new one.")

    aurin_create_wfs_connection()

    if (!is.null(username) & !is.null(password)) {

      aurin_api_credentials(username, password)

    } else {

      message("\naurin_wfs_connection.xml created, but no credentials provided.
              \nAdd your credentials with `api_credentials(username = username, password = password)`")
    }

  }
}

#' Download a file using the AURIN API.
#'
#' @param api_id The API ID of the dataset you wish to download. See `?aurin_id` for methods of getting the API ID.
#' @param out_file_name What name to save the downloaded file.
#' @param out_folder A path to where the file should be downloaded. The default is a folder `out` inside the current working directory.
#' @param ... additional options passed on to ogr2ogr2. See `?ogr2ogr2` for available options.
#'
#' @return The path of the downloaded file
#' @export
#'
#' @examples \dontrun{aurin_download_file(api_id = aurin_id("DSS - National Public Toilets (Point) 2017"),
#' out_file_name = "toilets")}
aurin_download_file <- function(api_id,
                                out_file_name,
                                out_folder = "out", ...) {

  #Check that the wfs_connection file exists.

  exists <- file.exists(here::here("aurin_wfs_connection.xml"))

  if (isFALSE(exists)) {

    stop("You need to authorise your R project for access to the AURIN API. See `?aurin_authorise_api` for more details. ")
  }

  #Create the path

  if (!dir.exists(out_folder)) {

    dir.create(out_folder)

  }

  datasource_name <- here::here(paste0(out_folder,"/", out_file_name, ".geoJSON"))

  gdalUtils::ogr2ogr(src_datasource_name = here::here("aurin_wfs_connection.xml"),
                     dst_datasource_name = datasource_name,
                     layer = api_id,
                     f = "GeoJSON",
                     oo = "INVERT_AXIS_ORDER_IF_LAT_LONG = NO",
                     progress = TRUE)

  return(datasource_name)
}


#' Create a aurin_wfs_connection.xml file for use with the AURIN API.
#'
#' @return NULL
#'
aurin_create_wfs_connection <- function() {
  aurin_xml <- xml2::as_xml_document(
    "<OGRWFSDataSource>
    <URL>http://openapi.aurin.org.au/wfs?version=1.0.0</URL>
    <HttpAuth>BASIC</HttpAuth>
    <UserPwd>username:password</UserPwd>
    </OGRWFSDataSource>")

  xml2::write_xml(x = aurin_xml,
                  file = here::here("aurin_wfs_connection.xml"),
                  options = "no_declaration")
}

#' Add a username and password to an existing wfs_connection xml file.
#'
#' @description Edits an existing aurin_wfs_connection.xml file to
#' add a username and password. This function is not exported and should not
#' be called directly.
#'
#' @param username AURIN API username as provided by AURIN.
#' @param password AURIN API password as provided by AURIN.
#'
#' @return NULL
#'
aurin_api_credentials <- function(username, password) {

  aurin_xml <- xml2::read_xml(here::here("aurin_wfs_connection.xml"))

  user_password <- xml2::xml_find_all(aurin_xml, ".//UserPwd")

  xml2::xml_text(user_password) <- paste0(username, ":", password)


  xml2::write_xml(x = aurin_xml, file = here::here("aurin_wfs_connection.xml"), options = "no_declaration")

}

#' Read a downloaded AURIN Dataset into R memory.
#'
#' @param aurin_file A path to the file downloaded from the AURIN API.
#'
#' @return A simple features file
#' @importFrom sf st_read
#' @export
#'
#' @examples \dontrun{read_aurin("out/aurin_file.geoJSON")}
read_aurin <- function(aurin_file) {

  sf::st_read(aurin_file)

}

#' Set the coordinate system for a simple features dataset.
#'
#' @param data simple features dataset
#' @param srid A numeric identifier of a coordinate system
#'
#' @return A simple features file
#' @export
#'
#' @importFrom sf st_transform
#'
#' @examples \dontrun{set_coordinate_system(aurin_data, srid = 4326)}
set_coordinate_system <- function(data, srid) {

  sf::st_transform(data, srid)

}



