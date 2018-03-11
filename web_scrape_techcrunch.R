library(rvest)
library(xtable)

args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 1) key <- "" else key <- paste("search/", args[1])

url <- paste("https://beta.techcrunch.com/", key, sep = "")
content <- read_html(url)

title <- content %>% html_nodes("h2.post-block__title") %>% html_text() %>% trimws()
link <- content %>% html_nodes("h2.post-block__title a.post-block__title__link") %>%
        html_attr("href")
date <- content %>% html_nodes("div.post-block__meta div.river-byline time") %>%
        html_text()

df <- data.frame(title = title, link = link, date = date)

df$date <- trimws(df$date)
df$date <- as.Date(df$date, format = "%b %d, %Y")
df <- df[order(df$date, decreasing = TRUE), ]
df$date <- as.character(df$date)

msg <- paste("<!DOCTYPE html>
<head>
  <meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
  <meta name='viewport' content='width=device-width, initial-scale=1.0'>
</head>
<body>", print(xtable(df), type = "html"), ",</body>
</html>")

msg <- gsub("(http([[:alnum:]]|[[:punct:]])+/)", "<a target='__blank' href='\\1'>\\1</a>", msg)

write(msg, file = paste(args[1], ".html", sep = ""))