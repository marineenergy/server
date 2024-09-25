FROM rocker/geospatial:4.4.1
LABEL org.opencontainers.image.authors="ben@ecoquants.com"

RUN /rocker_scripts/install_shiny_server.sh
RUN /rocker_scripts/install_python.sh

EXPOSE 3838  # open port for Shiny

RUN install2.r --error \
  dbplyr DiagrammeR DT DTedit flexdashboard fs glue gstat gt here htmltools httpuv \
  jsonlite kableExtra leaflet librarian mapedit mapview plotly plumber \
  RColorBrewer Rcpp reticulate RColorBrewer rhandsontable RPostgres shiny \
  shinycssloaders shinydashboard shinyFeedback shinyjs shinyWidgets units \
  urltools webshot

RUN installGithub.r \
  r-lib/gargle \
  MarkEdmondson1234/googleAuthR \
  RinteRface/shinydashboardPlus
  
CMD ["/init"]
