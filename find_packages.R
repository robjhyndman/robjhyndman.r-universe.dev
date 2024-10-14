library(dplyr)
library(stringr)

# Install pkgmeta
remotes::install_github("robjhyndman/pkgmeta")

# Get most recent packages file from my CV
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

# Construct and save JSON file
packages |>
  arrange(package) |>
  transmute(package = package, url = url, subdir = NA_character_) |>
  jsonlite::write_json("packages.json", pretty = TRUE)
