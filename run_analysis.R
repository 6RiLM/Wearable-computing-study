################################################################################
#
# Script used to download and preprocess data coming from Galaxy S smartphones
# gyroscope and accelerometer. 
#
# See explanation of the frame of this study 
# http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
#
# Execute this script with an internet access to download or keep the zip file
# in rawData folder. 
# Run the script then you'll get your data clean and saved in tidyData folder
# with two different files:
# - data.csv : cleaned data where only subject, activity, mean and std dev of 
#               each features
# - averages.csv : means of previous features grouped by activity and subject
#
#
# Author : 6RiLM
# Date   : 2016-11-02
#
################################################################################

#
# Load libraries
#
library(dplyr)

#
# Scripts path managment
#
if (!file.exists("./rawData")) {dir.create("./rawData")}
if (!file.exists("./tidyData")) {dir.create("./tidyData")}

#
# Raw data downloading and unzipping
#
rawDataArchive <- "./rawData/rawDataset.zip"
if (!file.exists(rawDataArchive)) {
    write("Downloading raw data...", "")
    rawDataURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(rawDataURL, destfile = rawDataArchive, method = "curl")
    unzip(rawDataArchive, exdir = "./rawData/", junkpaths = TRUE)
} else {
    write("Raw data already downloaded!", "")
}

#
# Load raw data to be processed
#
write("Load features names...", "")
featuresNames <- read.table("./rawData/features.txt")

write("Load activities description...", "")
activities <- read.table("./rawData/activity_labels.txt", 
                         col.names = c("id", "labels"))

write("Load test dataset...", "")
testData <- cbind(read.table("./rawData/subject_test.txt", 
                             col.names = "subjectID"),
                  read.table("./rawData/y_test.txt",
                             col.names = "activity"),
                  read.table("./rawData/X_test.txt", 
                             col.names = featuresNames[,2]))

write("Load train dataset...", "")
trainData <- cbind(read.table("./rawData/subject_train.txt", 
                              col.names = "subjectID"),
                   read.table("./rawData/y_train.txt",
                              col.names = "activity"),
                   read.table("./rawData/X_train.txt", 
                              col.names = featuresNames[,2]))

#
# Process the data and their features labels
#
write("Merge raw data into one dataset...", "")
data <- tbl_df(rbind(testData, trainData))

write("Reshape dataset...", "")
data <- select(data, c(1 ,2 ,grep("mean\\.|std", names(data)))) %>%
    mutate(activity = activities[activity, "labels"])

write("Clean features names...", "")
names <- names(data)
names <- gsub("mean", "Mean", names)
names <- gsub("std", "Std", names)
names <- gsub("\\.", "", names)
names(data) <- names

#
# Compute averages of dataset group by activity, subjectId
#
write("Compute averages by group...", "")
averages <- data %>%
    group_by(activity, subjectID) %>%
    summarize_each(funs(mean), -(activity:subjectID))

#
# Save tidy data
#
write("Save data to ./tidyData/data.csv...", "")
write.csv(data, "./tidyData/data.csv")
write("Save averages to ./tidyData/averages.csv...", "")
write.csv(averages, "./tidyData/averages.csv")

#
# Free memory and end the script
#
write("Free memory of temporary variables...", "")
suppressWarnings(rm(list = c("featuresNames", "testData", "trainData",
                             "rawDataArchive", "rawDataURL", "activities", 
                             "names")))
write("\nData are now tidy and available!\n", "")

