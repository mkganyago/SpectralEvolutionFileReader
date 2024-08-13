# SpectralEvolutionFileReader
This repository provides functions to read spectral data from Spectral Evolution spectrometers. The functions include handling `.sed` files, extracting metadata, and cleaning the headings of the data, while examples enable the plotting of spectral data.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Installation

No installation is needed. The functions in this repository use R-packages: `"readr"`, `"stringr"`, `"ggplot2"`, and `"dplyr"`, which will be installed if not already available on your computer. Simply, clone the repository or download and extract it, and source the `SEDReader_function.R` script as follows:

```r
source("./Scripts/SEDReader_function.R")
```

### Function 1

`read_sed(file_path)`

Reads a single .sed file, extracts metadata, and returns a list containing both the metadata and spectral data.

Arguments:

`file_path`: Character string specifying the path to the data file.

Returns:

A list with two elements:

`metadata`: A named list containing the metadata extracted from the .sed file.
`data`: A data frame containing the spectral data.

## Example usage 1 (see usage examples script)

```r
sed_data <- read_sed("path/to/your/file.sed")
print(sed_data$metadata)
head(sed_data$data)
```
### Function 2

`read_sed_dir(folder_path)`

Reads all `.sed` files in a specified folder, extracts metadata, and returns a list containing both the metadata and spectral data for each file.

Arguments:

`folder_path`: Character string specifying the path to the folder containing `.sed` files.

Returns:

A list of lists, where each inner list contains:

`metadata`: A named list containing the metadata extracted from the file.
`data`: A data frame containing the spectral data.

## Example Usage 2 (see usage examples script)
```r
folder_path <- "./Example_data/SpectralEvolution_files/"
example_sed_files <- read_sed_dir(folder_path)

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
```

## Plotting summary statistics

After reading and having a glimpse of the data, you can plot the minimum, mean, and maximum reflectance values from all files:

```r
# Combine all data into one dataframe for plotting
all_data <- bind_rows(lapply(example_sed_files, function(x) x$data), .id = "file_name")

# Calculate min, mean, and max
summary_data <- all_data %>%
  group_by(Wvl) %>%
  summarize(
    min_Reflect = min(Reflect, na.rm = TRUE),
    mean_Reflect = mean(Reflect, na.rm = TRUE),
    max_Reflect = max(Reflect, na.rm = TRUE)
  )

# Plot the min, mean, and max
ggplot(summary_data, aes(x = Wvl)) +
  geom_line(aes(y = min_Reflect, color = "Min.")) +
  geom_line(aes(y = mean_Reflect, color = "Mean")) +
  geom_line(aes(y = max_Reflect, color = "Max.")) +
  labs(title = "Spectral Data Summary", x = "Wavelength (Wvl)", y = "Reflectance") +
  scale_color_manual(values = c("Min." = "blue", "Mean" = "green", "Max." = "red")) +
  theme_minimal()
```
![image](https://github.com/user-attachments/assets/28f23951-19e6-42aa-a646-9f84c6fcdf9b)

# Contributing to the scripts

You can contribute to this repository by opening issues or submitting pull requests. Indicate what kind of changes you like to make when submitting a pull request. 

# Contact

For any questions or suggestions, please contact Mahlatse Kganyago at mahlatse@uj.ac.za.





