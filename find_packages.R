library(dplyr)
library(stringr)

# Github packages I've coauthored
github_repos <- read.table("https://raw.githubusercontent.com/robjhyndman/CV/master/github_r_repos.txt")$V1
packages <- pkgmeta::get_meta(cran_author = "Hyndman", github_repos = github_repos) 
# Exclude packages I haven't had much to do with or are outdated
packages <- packages %>%
  filter(!(package %in% c(
    "anomalous",
    "DescTools",
    "robets",
    "rmarkdown",
    "fracdiff",
    "nortsTest"
  )))

# Keep bitbucket and github packages
packages <- packages %>%
  filter(!is.na(github_url) | str_detect(url, "bitbucket")) %>%
  mutate(url = if_else(!is.na(github_url), github_url, url)) %>%
  select(package, url)

# Construct JSON file
packages %>%
  transmute(package=package, url=url, subdir=NA_character_) %>%
  jsonlite::write_json("packages.json", pretty=TRUE)

