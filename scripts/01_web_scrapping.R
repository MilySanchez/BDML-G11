##########################################################
# Title: WebScrapping.
# Description: This script webscrapes the data from the website
# https://ignaciomsarmiento.github.io/GEIH2018_sample/ the
# objective is to retrive 10 chunks of data from the website
# corresponding to a sample of GEIH 2018. Each one would be
# stored in a individual csv file also grouped in a single csv.
#
# Date: 09/02/2025
##########################################################

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =  = = = = = = = = 
# 0. Workspace configuration ====================================================================
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =  = = = = = = = = 

# Clear workspace

rm(list = ls())

# Set up paths

dir <- list()
dir$root <- getwd()
dir$raw <- file.path(dir$root, "stores", "raw")
dir$processed <- file.path(dir$root, "stores", "processed")
dir$views <- file.path(dir$root, "views")
dir$scripts <- file.path(dir$root, "scripts")
setwd(dir$root)

# Load required libraries

source(file.path(dir$scripts, "00_load_requierments.R"))

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =  = = = = = = = = 
# 1. Data scrapping ===========================================================================
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =  = = = = = = = = 

# Define the URL of the main webpage
url <- "https://ignaciomsarmiento.github.io/GEIH2018_sample/"

# Read the main page content
page <- read_html(url)

# Extract the data chunk links and corresponding URLs
data_chunk_links <- page %>% html_nodes("ul li a") %>% html_attr("href")

# Convert relative URLs to absolute URLs
data_chunk_links <- paste0(url, data_chunk_links)
data_chunk_links <- data_chunk_links[2:11]

# Function to scrape tables from each link
scrape_table <- function(link) {
  page <- read_html(link)  # Read the page content
  
  # Extract the w3-include-html attribute value
  tables <- page %>% 
    html_node("div[w3-include-html]") %>%
    html_attr("w3-include-html") 
  
  # Concatenate URL with the extracted attribute
  full_table_url <- ifelse(!is.na(tables), paste0(url, tables), NA)
  
  # Read the table content
  tables <- read_html(full_table_url) %>%
    html_table()  # Extract the table
  
  table_number <- gsub(".*page_(\\d+)\\.html", "\\1", full_table_url)

  # save the table
  write.csv(tables[[1]], file.path(dir$raw, paste0("table_geih_", table_number, ".csv")), row.names = F)
}

# Apply the function to each link
tables_list <- lapply(data_chunk_links, scrape_table)

# save the merge of all tables

cargar_unir_tablas <- function(ruta = "Insumos/", n = 10) {
  # Generar los nombres de los archivos
  archivos <- paste0(dir$raw, "/table_geih_", 1:n, ".csv")
  
  # Leer y combinar los archivos
  tabla_combinada <- archivos %>%
    lapply(read_csv) %>%
    bind_rows()
  
  return(tabla_combinada)
}

db_geih <- cargar_unir_tablas()

# Save the final table

write.csv(db_geih, file.path(dir$raw, "table_geih.csv"), row.names = F)


