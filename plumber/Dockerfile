# https://www.rplumber.io/articles/hosting.html#docker:~:text=FROM%20rstudio/plumber
# https://github.com/rstudio/plumber/blob/main/Dockerfile
FROM rocker/geospatial:4.4.1

# install system dependencies
#   plumber deps; `rm` call removes `apt` cache; libpq RPostgres dep
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  curl git-core libssl-dev libcurl4-gnutls-dev libsodium-dev libxml2-dev \
  libpq-dev && rm -rf /var/lib/apt/lists/*

# install R packages on CRAN; `rm` call removes install2.r's cache
RUN install2.r --error \
 dbplyr dplyr digest fs glue here httr jsonlite librarian plumber pool purrr \
 rmarkdown RPostgres readr shiny stringr tibble tidyr yaml \
 && rm -rf /tmp/downloaded_packages

# install R packages on Github 
# RUN installGithub.r \
#  r-lib/gargle

## Remove this comment to always bust the Docker cache at this step
## https://stackoverflow.com/a/55621942/591574
#ADD https://github.com/rstudio/plumber/commits/ _docker_cache

EXPOSE 8000

#ENTRYPOINT ["R", "-e", "pr <- plumber::plumb(rev(commandArgs())[1]); args <- list(host = '0.0.0.0', port = 8000); if (packageVersion('plumber') >= '1.0.0') { pr$setDocs(TRUE) } else { args$swagger <- TRUE }; do.call(pr$run, args)"]

# Copy installed example to default file at ~/plumber.R
#ARG ENTRYPOINT_FILE=/usr/local/lib/R/site-library/plumber/plumber/04-mean-sum/plumber.R
#RUN cp ${ENTRYPOINT_FILE} ~/plumber.R

#CMD ["~/plumber.R"]

CMD Rscript /share/github/api/run-api.R

