library(dplyr)
library(stringr)

rjh_packages <- function() {
  # Get most recent packages file
  if (fs::file_exists(here::here("packages.rds"))) {
    packages <- readRDS(here::here("packages.rds"))
    info <- fs::file_info(here::here("packages.rds"))
    recent_run <- (Sys.Date() == anytime::anydate(info$modification_time))
  } else {
    recent_run <- FALSE
  }
  if (recent_run) {
    return(packages)
  } else {
    # Create new packages tibble
    github_repos <- read.table("https://raw.githubusercontent.com/robjhyndman/CV/master/github_r_repos.txt")$V1
    packages <- pkgmeta::get_meta(cran_author = "Hyndman", github_repos = github_repos)
    # Exclude packages I haven't had much to do with or are outdated
    packages <- packages |>
      filter(!(package %in% c(
        "anomalous",
        "bayesforecast",
        "DescTools",
        "fracdiff",
        "nortsTest",
        "rmarkdown",
        "robets"
      )))
    # Keep only packages with github repos
    packages <- packages |>
      mutate(url = if_else(!is.na(github_url), github_url, url)) |>
      filter(!is.na(github_url))
    # Save result
    saveRDS(packages, file = here::here("packages.rds"))
    return(packages)
  }
}

# Construct JSON file
rjh_packages() |>
  arrange(package) |>
  transmute(package = package, url = url, subdir = NA_character_) |>
  jsonlite::write_json("packages.json", pretty = TRUE)
