
# This code provides an analysis pipeline to evaluate data using 
# linear mixed-effects models across multiple dependent variables. It runs the 
# statistical analysis and saves the compiled model output. Medical data from 
# the PAPILA dataset is used for demonstration.
library(here)
library("stringr")
library(tidyverse)
library(cowplot)
library(smplot2)
library("ggpubr")
library(data.table)
library(lme4)
library(lmerTest) 
library("gtools")
library(rstatix)

source("preprocessing.R")

# This function iterates over a list of specified dependent variables to fit 
# linear mixed-effects models with a random intercept for subjects. For each 
# variable, it extracts key statistics including p-values, intercept and 
# fixed effect estimates, and 95% confidence intervals. It formats the 
# extracted metrics into a structured summary data frame and exports the final 
# output.
get_results <- function(subject_variable, 
                        group_variable, 
                        dependent_variables, 
                        input_df) {

  # initialize results vector
  results_vector <- vector(mode = "list", length = 6)
  # store results sub-vectors
  # (dependent variable column, p-values, beta0, beta1, CI lower, CI upper)  
  for (q in seq_along(results_vector)) {
    results_vector[[q]] = rep(NA, length(dependent_variables))
    }
  
  # iterate over dependent variables
  for (i in seq_along(dependent_variables)) {
    # keep only subject variable, group variable, dependent variable columns
    dependent_variable <- dependent_variables[[i]]
    curr_subset_df <-
      input_df[, c(subject_variable, group_variable, dependent_variable)]
    # remove any row with NA values
    curr_subset_df <- na.omit(curr_subset_df)
    # generate group comparison
    myformula <- 
      as.formula(paste0(dependent_variable, 
                        " ~ ", group_variable, 
                        " + (1 | ", subject_variable, ")"))
    mm <- lmer(myformula, REML = TRUE, data = curr_subset_df)
    # extract p-value from mixed effect model
    p_num <- summary(mm, ddf = "Kenward-Roger")$coefficients[2, 5]
    # extract beta coefficients from mixed effect model
    beta0_num <- coef(summary(mm))["(Intercept)", "Estimate"]
    beta1_num <- coef(summary(mm))[group_variable, "Estimate"]
    # extract confidence interval from mixed effect model
    ci_matrix <- confint(mm, oldNames = FALSE)
    ci_lower_num <- ci_matrix[group_variable, "2.5 %"]
    ci_upper_num <- ci_matrix[group_variable, "97.5 %"]
    # store results
    curr_results <- c(dependent_variable, p_num, 
                      beta0_num, beta1_num, 
                      ci_lower_num, ci_upper_num)
    for (t in seq_along(curr_results)) {
      results_vector[[t]][[i]] = curr_results[[t]]
      }
    }
  
  # create empty data frame
  results_df <- 
    setNames(data.frame(matrix(ncol = length(results_vector),
                               nrow = length(dependent_variables))),
             c("dependent_variable", "p_value",
               "beta0", "beta1", "ci_lower", "ci_upper"))
  # assign results to data frame columns
  for (w in seq_along(results_vector)) {
    results_df[, w] = results_vector[[w]]
    }
  # export results data frame as .csv
  df_file_name <- here("results.csv")
  write.csv(results_df, df_file_name, row.names = FALSE)
  
  }

# --- read data ---
example_data <- PreprocessorR6$new(dataset_path = here("data"))
example_data$get_df()

# --- variables setup ---
# assign data-specific variables
example_subject_variable <- "id_num"
example_group_variable <- "Diagnosis"
example_dependent_variables <- c("IOP_Pneumatic", "Pachymetry", "Axial_Length")
# gather subset data frame
# keep only two values from group variable column
# (0 or healthy, 1 for glaucoma, and 2 for suspicious)
example_subset_df <- 
  example_data$prep_df[
    example_data$prep_df[[example_group_variable]] %in% c(0, 1), ]

# --- obtain linear mixed model group comparisons ---
get_results(example_subject_variable, 
            example_group_variable, 
            example_dependent_variables,
            example_subset_df)
