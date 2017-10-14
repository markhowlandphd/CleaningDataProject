## create one R script called run_analysis.R that does the following.
## 1. Merges the training and the test sets to create one data set.

## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## Uses descriptive activity names to name the activities in the data set

## 3. Appropriately labels the data set with descriptive variable names

## 4. From the data set in step 4, creates a second, independent tidy data set with the
## average of each variable for each activity and each subject

library(readr)
library(plyr)
library(dplyr)
setwd("~/Documents/GitHub/CleaningDataProject")

## 1. Load
xTrain <- read.table("~/Documents/GitHub/CleaningDataProject/X_train.txt", header = FALSE)
yTrain <- read.table("~/Documents/GitHub/CleaningDataProject/y_train.txt", header = FALSE)
features <- read.table("~/Documents/GitHub/CleaningDataProject/features.txt", header = FALSE)
activityLabel <- read.table("~/Documents/GitHub/CleaningDataProject/activity_labels.txt", header = FALSE)
subjectTrain <- read.table("~/Documents/GitHub/CleaningDataProject/subject_train.txt", header = FALSE)

class(features)
View(features)

# colname assignments
colnames(activityLabel) <- c("activityId","activityType")
colnames(subjectTrain) <- "subId"
colnames(xTrain) <- features[,2]
colnames(yTrain) <- "activityId"

## inspect 
View(xTrain)
trainData <- cbind(yTrain,subjectTrain,xTrain)
View(trainData)

## test data load
subjectTest <- read.table("~/Documents/GitHub/CleaningDataProject/subject_test.txt", header=FALSE)
xTest <- read.table("~/Documents/GitHub/CleaningDataProject/X_test.txt", header=FALSE)
yTest <- read.table("~/Documents/GitHub/CleaningDataProject/y_test.txt", header=FALSE)

## colname assignments
colnames(subjectTest) <- "subId"
colnames(xTest) <- features[,2]
colnames(yTest) <- "activityId"

## join test data by subject
testData <- cbind(yTest,subjectTest,xTest)

## append train and test
finalData <- rbind(trainData,testData)

## load column names
colNames <- colnames(finalData)
class(colNames)
colNames

## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
data_mean_std <-finalData[,grepl("mean|std|subId|activityId",colnames(finalData))]
View(data_mean_std)

## join the label on the activityId var
data_mean_std <- join(data_mean_std, activityLabel, by = "activityId", match = "first")
View(data_mean_std)

## drop the numbered activity column
data_mean_std <-data_mean_std[,-1]
View(data_mean_std)

## remove brackets from column names
names(data_mean_std) <- gsub("\\(|\\)", "", names(data_mean_std), perl  = TRUE)

names(data_mean_std) <- make.names(names(data_mean_std))

## 3. Appropriately labels the data set with descriptive variable names
names(data_mean_std) <- gsub("Acc", "Acceleration", names(data_mean_std))
names(data_mean_std) <- gsub("^t", "Time", names(data_mean_std))
names(data_mean_std) <- gsub("^f", "Frequency", names(data_mean_std))
names(data_mean_std) <- gsub("BodyBody", "Body", names(data_mean_std))
names(data_mean_std) <- gsub("mean", "Mean", names(data_mean_std))
names(data_mean_std) <- gsub("std", "Std", names(data_mean_std))
names(data_mean_std) <- gsub("Freq", "Frequency", names(data_mean_std))
names(data_mean_std) <- gsub("Mag", "Magnitude", names(data_mean_std))
names(data_mean_std) <- gsub("Frequencyuency", "Frequency", names(data_mean_std))

## 4. creates a second, independent tidy data set with the
## average of each variable for each activity and each subject
tidydata_average_sub<- ddply(data_mean_std, c("subId", "activityType"), numcolwise(mean))
write.table( tidydata_average_sub, file="ActivitySubjectMean.txt", row.name = FALSE)
