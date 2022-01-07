library(tidyverse)
source("software_functions.R")

# Github packages I've coauthored
github <- c(
  "AU-BURGr/ozdata",
  "earowang/hts",
  "earowang/sugrrants",
  "eddelbuettel/binb",
  "FinYang/tsdl",
  "haghbinh/sfar",
  "jforbes14/eechidna",
  "mitchelloharawild/fasster",
  "mitchelloharawild/vitae",
  "pridiltal/oddstream",
  "pridiltal/oddwater",
  "pridiltal/stray",
  "robjhyndman/addb",
  "robjhyndman/anomalous",
  "robjhyndman/compenginets",
  "robjhyndman/demography",
  "robjhyndman/expsmooth",
  "robjhyndman/fma",
  "robjhyndman/forecast",
  "robjhyndman/fpp",
  "robjhyndman/fpp2-package",
  "robjhyndman/fpp3-package",
  "robjhyndman/hdrcde",
  "robjhyndman/Mcomp",
  "robjhyndman/MEFM-package",
  "numbats/monash",
  "robjhyndman/thief",
  "robjhyndman/tscompdata",
  "robjhyndman/tsfeatures",
  "ropenscilabs/cricketdata",
  "ropenscilabs/ozbabynames",
  "ropenscilabs/rcademy",
  "sayani07/gravitas",
  "sevvandi/lookout",
  "thiyangt/seer",
  "tidyverts/fable",
  "tidyverts/fabletools",
  "tidyverts/feasts",
  "tidyverts/tsibble",
  "tidyverts/tsibbledata",
  "verbe039/bfast",
  "ykang/gratis",
  "AndriSignorell/DescTools",
  NULL
)
get_rjh_packages(github) %>%
  # Exclude packages I haven't had much to do with or are outdated
  filter(!package %in% c(
    "anomalous",
    "bayesforecast",
    "DescTools",
    "fracdiff",
    "nortsTest",
    "rmarkdown",
    "robets"
  )) %>%
  # Construct JSON file
  transmute(package=package, url=url, subdir=NA_character_) %>%
  jsonlite::write_json("packages.json", pretty=TRUE)

