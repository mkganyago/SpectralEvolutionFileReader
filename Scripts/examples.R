#---------------------------------------------------------------------
#---------------------Usage Examples of reading .SED files of the Spectral Evolution Spectrometer--------
#----------------------------------Licence Agreement--------------------------------------------------------
# Copyright <2024> <Copyright Holder: Mahlatse Kganyago (mahlatse@uj.ac.za)>
# MIT Licence (https://opensource.org/license/mit)
#---------------------------------------------------------------------
# Example usage -  Reading a single file
#---------------------------
source("./Scripts/SEDReader_function.R")
example_sed_file <- read_sed("./Example_data/SpectralEvolution_files/1116037_00137.sed")

# Access metadata (list) and spectral data (dataframe)
metadata <- example_sed_file$metadata
spectral_data <- example_sed_file$data

# check the structure of metadata and spectral data
str(metadata)
str(spectral_data)

# check how it looks like
head(spectral_data)

# Plot Wvl vs Reflect  using ggplot2
library(ggplot2)
ggplot(spectral_data, aes(x = Wvl, y = Reflect)) +
  geom_line(color = "blue") +
  labs(title = "Wavelength vs Reflectance", x = "Wavelength (nm)", y = "Reflectance (%)") +
  theme_minimal()
#---------------------------------------------------------------------
# Example usage - Reading from a folder containing many files
#---------------------------
folder_path <- "./Example_data/SpectralEvolution_files/"
example_sed_files <- read_sed_dir(folder_path)
example_sed_files

# Access metadata and data for each file
for (file_name in names(example_sed_files)) {
  cat("File:", file_name, "\n")
  if (!is.null(example_sed_files[[file_name]])) {
    print(example_sed_files[[file_name]]$metadata)
    print(example_sed_files[[file_name]]$data)
  } else {
    cat("Failed to read file:", file_name, "\n")
  }
}
#---------------------------------------------------------------------
# Plot each spectral data using ggplot2 - Useful for when scanning through the data to remove bad spectra. 
for (file_name in names(example_sed_files)) {
  cat("Plotting file:", file_name, "\n")
  if (!is.null(example_sed_files[[file_name]])) {
    spectral_data <- example_sed_files[[file_name]]$data
    p <- ggplot(spectral_data, aes(x = Wvl, y = Reflect)) +
      geom_line() +
      labs(title = paste("Spectral Data -", file_name), x = "Wavelength (nm)", y = "Reflectance (%)") +
      theme_minimal()
    print(p)
  } else {
    cat("Failed to read file:", file_name, "\n")
  }
}

#---------------------------------------------------------------------
# Plot all the spectral data on a single plot
## Combine all spectral data into one dataframe with an identifier for each file. 
combined_data <- bind_rows(
  lapply(names(example_sed_files), function(file_name) {
    data <- example_sed_files[[file_name]]$data
    data$file_name <- file_name
    data
  }),
  .id = "source"
)

head(combined_data)

## Plot all spectral data on one plot using ggplot2
ggplot(combined_data, aes(x = Wvl, y = Reflect)) +
  geom_line(color = "blue") +
  labs(title = "Combined Spectral Data", x = "Wavelength (nm)", y = "Reflectance (%)") +
  theme_minimal()
#---------------------------------------------------------------------
# Plot the Minimum, Mean and Maximum statistics of all spectral data
## Compute min, mean, and max for each wavelength
summary_stats <- combined_data %>%
  group_by(Wvl) %>%
  summarise(
    min_reflect = min(Reflect, na.rm = TRUE),
    mean_reflect = mean(Reflect, na.rm = TRUE),
    max_reflect = max(Reflect, na.rm = TRUE)
  )

# Plot min, mean, and max using ggplot2
ggplot(summary_stats, aes(x = Wvl)) +
  geom_line(aes(y = min_reflect, color = "Min.")) +
  geom_line(aes(y = mean_reflect, color = "Mean")) +
  geom_line(aes(y = max_reflect, color = "Max.")) +
  labs(title = "Summary Statistics of Spectral Data", x = "Wavelength (nm)", y = "Reflectance (%)") +
  scale_color_manual(name = "", values = c("Min." = "blue", "Mean" = "green", "Max." = "red")) +
  theme_minimal()

#------------------------------END--------------------------------