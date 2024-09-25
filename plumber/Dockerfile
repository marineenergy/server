# https://www.rplumber.io/articles/hosting.html#docker:~:text=FROM%20rstudio/plumber
FROM rstudio/plumber
LABEL org.opencontainers.image.authors="Docker User <docker@user.org>"

# install system dependencies
RUN apt-get update && apt-get install -y \
  libpq-dev  # for RPostgres

# install R packages on CRAN
RUN install2.r --error \
 dbplyr dplyr digest fs glue here httr jsonlite librarian pool purrr rmarkdown \
 RPostgres readr shiny stringr tibble tidyr yaml

# install R packages on Github 
# RUN installGithub.r \
#  r-lib/gargle

CMD ["/share/github/api/run-api.R"]

