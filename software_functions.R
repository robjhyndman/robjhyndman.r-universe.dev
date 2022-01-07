# Return CRAN packages with Hyndman as author
rjh_cran_packages <- function() {
  pkgsearch::ps("Hyndman", size = 100) %>%
    filter(purrr::map_lgl(
      package_data, ~ grepl("Hyndman", .x$Author, fixed = TRUE)
    )) %>%
    select(package) %>%
    mutate(on_cran = TRUE)
}
# Get meta data for vector of packages on CRAN
get_meta_cran <- function(packages) {
  title <- version <- date <- authors <- url <- rep(NA_character_, NROW(packages))
  for (i in seq_along(packages$package)) {
    meta <- pkgsearch::cran_package(packages$package[i])
    date[i] <- meta$date
    title[i] <- meta$Title
    version[i] <- meta$Version
    # Replace new line unicodes with spaces
    authors[i] <- gsub("<U\\+000a>", " ", meta$Author, perl=TRUE)
    # Trim final period
    authors[i] <- gsub("\\.$","",authors[i])
    if (!is.null(meta$URL)) {
      url[i] <- (str_split(meta$URL, ",") %>% unlist())[1]
    }
  }
  tibble(package = packages$package, date = date, url = url, title = title, version = version, authors = authors)
}
# Get meta data for vector of packages on github
get_meta_github <- function(repos) {
  title <- version <- date <- authors <- url <- package <- character(length(repos))
  tmp <- tempfile()
  for (i in seq_along(repos)) {
    date[i] <- gh::gh(paste0("/repos/", repos[i]))$updated_at
    download.file(gh::gh(paste0("/repos/", repos[i], "/contents/DESCRIPTION"))$download_url, tmp)
    package[i] <- desc::desc_get_field("Package", file=tmp)
    title[i] <- desc::desc_get_field("Title", file = tmp)
    version[i] <- as.character(desc::desc_get_version(tmp))
    auth <- desc::desc_get_author("aut", tmp)
    if(!is.null(auth))
      authors[i] <- paste(as.character(auth), sep = "\n", collapse = "\n")
    else
      authors[i] <- desc::desc_get_field("Author",file=tmp)
    url[i] <- desc::desc_get_field("URL", file = tmp,
                                   default = gh::gh(paste0("/repos/", repos[i]))$html_url
    )
    url[i] <- (str_split(url[i], ",") %>% unlist())[1]
  }
  tibble(package = package, date = date, url = url, title = title, version = version, authors = authors)
}

get_rjh_packages <- function(github) {
  # Check if this has been run in last day
  recent_run <- fs::file_exists(here::here("packages.rds"))
  if (recent_run) {
    info <- fs::file_info(here::here("packages.rds"))
    recent_run <- (Sys.Date() == anytime::anydate(info$modification_time))
  }
  if (recent_run) {
    return(readRDS(here::here("packages.rds")))
  }
  packages <- tibble(github = github) %>%
    # Extract packages from github repos
    mutate(
      package = stringr::str_extract(github, "/[a-zA-Z0-9\\-]*"),
      package = stringr::str_remove(package, "/"),
      package = stringr::str_extract(package, "[a-zA-Z0-9]*"),
      package = if_else(package=="sfar", "Rsfar", package)
    ) %>%
    # Add in CRAN packages
    full_join(rjh_cran_packages(), by = "package") %>%
    replace_na(list(on_cran = FALSE))

  # CRAN package meta data
  cran_meta <- packages %>%
    filter(on_cran) %>%
    get_meta_cran()

  # Github package meta data
  github_meta <- packages %>%
    filter(!on_cran) %>%
    pull(github) %>%
    get_meta_github()

  # Add URLs
  packages <- packages %>%
    mutate(
      github_url = if_else(is.na(github), NA_character_,
                           paste0("https://github.com/",github))
    )

    # Save result and return it
  saveRDS(packages, file=here::here("packages.rds"))
  return(packages)
}
