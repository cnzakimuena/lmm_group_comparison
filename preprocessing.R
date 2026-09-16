
# Preprocessing class to manipulate tabular ophthalmic data.
library(R6)
library(dplyr)
library(here)

# This class manages dataset file paths and eye side labels, and combines data 
# frames. It scans the provided target directory path and extracts all .csv 
# file paths to set up the preprocessing pipeline.
PreprocessorR6 <- 
  R6Class("PreprocessorR6",
          public = 
            list(dataset_path = NULL,
                 file_paths = NULL,
                 eye_str_list = NULL,
                 prep_df = NULL,
                 
                 # constructor method
                 initialize = 
                   function(dataset_path) {
                     # define target sub folder
                     self$dataset_path <- dataset_path
                     # get full file paths for all .csv files inside folder
                     self$file_paths <- list.files(
                       path = self$dataset_path,
                       pattern = "\\.csv$",
                       full.names = TRUE
                       )
                     # create eye side strings
                     self$eye_str_list <- c("OD", "OS")
                     },
                 
                 # This method loops through the discovered CSV files, cleans 
                 # column names by stripping eye-specific suffixes, and inserts 
                 # an explicit eye column as in each data frame. It then stacks 
                 # these individual data frames row-wise and optionally saves 
                 # the consolidated dataset.
                 get_df = function(save_csv_file = FALSE) {                 

                   # initialize an empty list to store the data frames
                   df_list <- list()
                   
                   # iterate over the paths and read each CSV into the list
                   for (i in seq_along(self$file_paths)) {
                     
                     # gather eye string
                     # .*_ matches everything up to the last underscore
                     # ([^.]+) captures ≥ 1 characters that are not a dot (.)
                     # \\..* matches the dot and remaining extension
                     # \\1 returns only the captured group
                     curr_path_str <- 
                       sub(".*(_[^.]+)\\..*", "\\1", 
                           basename(self$file_paths[i]))
                     
                     # ensure eye strings match
                     if (tolower(curr_path_str) == 
                         tolower(paste0("_", self$eye_str_list[[i]]))) {
                       
                       # import csv file
                       curr_df <- read.csv(self$file_paths[i], header = TRUE)
                       
                       # remove suffix from column titles 
                       # (starting from column 4 onward)
                       colnames(curr_df)[4:ncol(curr_df)] <-
                         gsub(paste0("_", self$eye_str_list[[i]], "$"), 
                              "", colnames(curr_df)[4:ncol(curr_df)])
                       
                       # create the "eye" column, 
                       # assign eye side and place it as the 4th column
                       curr_df <- 
                         append(curr_df, 
                                list(eye = self$eye_str_list[[i]]), after = 3)
                       curr_df <- as.data.frame(curr_df)
                       
                       df_list[[i]] <- curr_df
                       
                       }
                   }
                   
                   # combine data frames
                   combined_df <- do.call(rbind, df_list)
                   
                   # create unique numeric IDs column based on appearance order 
                   # and place it at the start
                   self$prep_df <- combined_df %>%
                     mutate(id_num =
                              as.integer(factor(ID, levels = unique(ID)))) %>%
                     relocate(id_num, .before = 1)

                   # optionally save consolidated dataset
                   if (save_csv_file == TRUE) {
                     write.csv(self$prep_df, 
                               file = here("prep_data.csv"), row.names = FALSE)
                     }

                 }
                 )
)
