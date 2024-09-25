FROM rocker/geospatial:4.4.1
MAINTAINER "Ben Best" ben@ecoquants.com

RUN /rocker_scripts/install_shiny_server.sh
RUN /rocker_scripts/install_python.sh

EXPOSE 3838

RUN install2.r --error \
  dbplyr \
  DiagrammeR \
  DT \
  flexdashboard \
  fs \
  glue \
  gstat \
  gt \
  here \
  htmltools \
  httpuv \
  jsonlite \
  kableExtra \
  leaflet \
  mapedit \
  mapview \
  plumber \
  RColorBrewer \
  Rcpp \
  reticulate \
  RColorBrewer \
  rhandsontable \
  RPostgres \
  shiny \
  shinydashboard \
  shinyjs \
  shinyWidgets \
  units \
  urltools \
  webshot

RUN installGithub.r \
  r-lib/gargle \
  MarkEdmondson1234/googleAuthR \
  RinteRface/shinydashboardPlus
  
CMD ["/init"]
