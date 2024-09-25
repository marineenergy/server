# https://www.rplumber.io/articles/hosting.html#docker:~:text=FROM%20rstudio/plumber
FROM rstudio/plumber
LABEL org.opencontainers.image.authors="Docker User <docker@user.org>"

RUN R -e "install.packages('dbplyr','dplyr','digest','fs','glue','here','httr','jsonlite','librarian','pool','purrr','rmarkdown','readr','shiny','stringr','tibble','tidyr','yaml')

CMD ["/share/github/api/run-api.R"]

