#---------------------------------------------------------------------
#---------------------A function and example to read .SED files from Spectral Evolution Spectrometer--------
#----------------------------------Licence Agreement--------------------------------------------------------
# Copyright <2024> <Copyright Holder: Mahlatse Kganyago (mahlatse@uj.ac.za)>
#  MIT Licence (https://opensource.org/license/mit)
#---------------------------------------------------------------------
# Install required packages if not available already.
if (!requireNamespace("readr", quietly = TRUE)) install.packages("readr")
if (!requireNamespace("stringr", quietly = TRUE)) install.packages("stringr")
if (!requireNamespace("ggplot2", quietly = TRUE)) install.packages("ggplot2")
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")

# Load the required packages. 
library(readr)
library(dplyr)
library(stringr)
library(dplyr)
#---------------------------------------------------------------------
#' Read spectral data from an .sed file
#'
#' This function reads spectral data from a file, extracts metadata, and returns a list
#' containing both the metadata and cleaned spectral data.
#'
#' @param file_path Character string specifying the path to the data file.
#' @return A list with two elements: 'metadata' (a named list) and 'data' (a dataframe).
#'
#' @examples
#' read_sed("path/to/your/file.sed")
#'
#' @importFrom stringr str_extract
#' @importFrom readr read_lines read_table
#'
read_sed <- function(file_path) {
  # Check if the file exists
  if (!file.exists(file_path)) {
    stop("File not found. Please provide a valid file path.")
  }
  
  # Read the entire file
  file_content <- read_lines(file_path)
  
  metadata <- list()
  data <- data.frame()
  
  # Extract the metadata from the file
  metadata$Version <- str_extract(file_content[2], "(?<=Version: ).*")
  metadata$Instrument <- str_extract(file_content[4], "(?<=Instrument: ).*")
  metadata$Detectors <- str_extract(file_content[5], "(?<=Detectors: ).*")
  metadata$Measurement <- str_extract(file_content[6], "(?<=Measurement: ).*")
  metadata$Date <- str_extract(file_content[7], "(?<=Date: ).*")
  metadata$Time <- str_extract(file_content[8], "(?<=Time: ).*")
  metadata$Temperature <- str_extract(file_content[9], "(?<=Temperature \\(C\\): ).*")
  metadata$BatteryVoltage <- str_extract(file_content[10], "(?<=Battery Voltage: ).*")
  metadata$Averages <- str_extract(file_content[11], "(?<=Averages: ).*")
  metadata$Integration <- str_extract(file_content[12], "(?<=Integration: ).*")
  metadata$DarkMode <- str_extract(file_content[13], "(?<=Dark Mode: ).*")
  metadata$Foreoptic <- str_extract(file_content[14], "(?<=Foreoptic: ).*")
  metadata$RadiometricCalibration <- str_extract(file_content[15], "(?<=Radiometric Calibration: ).*")
  metadata$Units <- str_extract(file_content[16], "(?<=Units: ).*")
  metadata$WavelengthRange <- str_extract(file_content[17], "(?<=Wavelength Range: ).*")
  metadata$Latitude <- str_extract(file_content[18], "(?<=Latitude: ).*")
  metadata$Longitude <- str_extract(file_content[19], "(?<=Longitude: ).*")
  metadata$Altitude <- str_extract(file_content[20], "(?<=Altitude: ).*")
  metadata$GPSTime <- str_extract(file_content[21], "(?<=GPS Time: ).*")
  metadata$Satellites <- str_extract(file_content[22], "(?<=Satellites: ).*")
  metadata$CalibratedReferenceCorrectionFile <- str_extract(file_content[23], "(?<=Calibrated Reference Correction File: ).*")
  metadata$Channels <- str_extract(file_content[24], "(?<=Channels: ).*")
  
  # Extract column names and data
  data_start_index <- which(file_content == "Data:") + 1
  if (length(data_start_index) == 0) {
    stop("Data section not found in the file. Please check the file format.")
  }
  
  data_columns <- str_split(file_content[data_start_index], "\\s+")[[1]]
  data_lines <- file_content[(data_start_index + 1):length(file_content)]
  
  # Read data into a dataframe
  data_text <- paste(data_lines, collapse = "\n")
  spectral_data <- read.table(text = data_text, header = FALSE, col.names = data_columns, fill = TRUE, strip.white = TRUE)
  
  # Rename columns
  colnames(spectral_data) <- c("Wvl", "Rad_Ref", "Rad_Target", "minus_log_Reflect", "Reflect")
  
  # Remove columns with NA values
  cleaned_spectral_data <- spectral_data[, !colSums(is.na(spectral_data)) > 0]
  
  list(metadata = metadata, data = cleaned_spectral_data)
}
#---------------------------------------------------------------------
# In case a folder is provided instead of a single file, this function will read multiple .sed files from a folder
#' Read spectral data from multiple files in a folder
#'
#' This function reads spectral data from all .sed files in a specified folder,
#' extracts metadata, and returns a list containing both the metadata and cleaned
#' spectral data for each file.
#'
#' @param folder_path Character string specifying the path to the folder containing .sed files.
#' @return A list of lists, where each inner list contains 'metadata' (a named list) and 'data' (a dataframe).
#'
#' @examples
#' read_sed_dir("path/to/your/folder")
#'
#' @importFrom stringr str_extract
#' @importFrom readr read_lines read_table
#'
read_sed_dir <- function(folder_path) {
  # Check if folder exists
  if (!dir.exists(folder_path)) {
    stop("The specified folder does not exist.")
  }
  
  # Get a list of .sed files in the folder
  file_list <- list.files(path = folder_path, pattern = "\\.sed$", full.names = TRUE)
  
  # Check if any .sed files are found
  if (length(file_list) == 0) {
    stop("No .sed files found in the specified folder.")
  }
  
  # Initialize an empty list to store results
  result_list <- list()
  
  # Loop through each file and read it using read_sed
  for (file in file_list) {
    file_name <- basename(file)
    result_list[[file_name]] <- tryCatch(
      read_sed(file),
      error = function(e) {
        message(paste("Error reading file:", file_name, "-", e$message))
        NULL
      }
    )
  }
  
  result_list
}

#---------------------------------------------------------------------
