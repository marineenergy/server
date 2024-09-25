# https://www.rplumber.io/articles/hosting.html#docker:~:text=FROM%20rstudio/plumber
FROM rstudio/plumber
LABEL org.opencontainers.image.authors="Docker User <docker@user.org>"

RUN install2.r --error \
 dbplyr dplyr digest fs glue here httr jsonlite librarian pool purrr rmarkdown \
 RPostgres readr shiny stringr tibble tidyr yaml
 
# RUN installGithub.r \
#  r-lib/gargle

CMD ["/share/github/api/run-api.R"]

