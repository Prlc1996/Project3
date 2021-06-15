######Proyecto de curso
###################
###################

library(data.table)
library(reshape2)


getwd()

##Dowloading file
url= "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url,destfile = "./data/Files.zip")

##Unziping from local
archivos="C:/Users/user/Desktop/tema tesis/data/Files.zip"
unzip(archivos,exdir = "C:/Users/user/Desktop/tema tesis")

##Loading data

activityLabels = fread(file.path("UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))

features = fread(file.path("UCI HAR Dataset/features.txt")
                  , col.names = c("index", "featureNames"))

View(activityLabels)
View(features)

##Editing data

#Finding locations of observations that contains mean or std
featuresWanted=grep("(mean|std)\\(\\)", features[, featureNames])
#Building the object
measurements=features[featuresWanted, featureNames]
#Editing characters
measurements=gsub('[()]', '', measurements)
str(measurements)
View(measurements)

## Loading train file 
#For x
#Load data from x_train and select the variables with gotten from the last code
train=fread(file.path("UCI HAR Dataset/train/X_train.txt"))[, featuresWanted, with = FALSE]
#Setting names
data.table::setnames(train, colnames(train), measurements)

#For y
trainY=fread(file.path("UCI HAR Dataset/train/Y_train.txt")
                         , col.names = c("Activity"))

#For subject
trainSubject=fread(file.path("UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum"))

#General table from train dataset
train=cbind(trainSubject, trainY, train)

## Loading test file
#Same as before
#Data from x_test
test=fread(file.path("UCI HAR Dataset/test/X_test.txt"))[, featuresWanted, with = FALSE]

#Setting names
data.table::setnames(test, colnames(test), measurements)

#Data from Y_test
testY=fread(file.path("UCI HAR Dataset/test/Y_test.txt")
                        , col.names = c("Activity"))

#Data from subject_test
testSubject=fread(file.path("UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("SubjectNum"))

#General table from test dataset
test=cbind(testSubject, testY, test)

##Merged data

merged= rbind(train,test)

## Making tidy data

merged[["Activity"]] <- factor(merged[, Activity]
                                 , levels = activityLabels[["classLabels"]]
                                 , labels = activityLabels[["activityName"]])

merged[["SubjectNum"]] <- as.factor(merged[, SubjectNum])

#Melting data
merged <- reshape2::melt(data = merged, id = c("SubjectNum", "Activity"))

#Casting frame
merged <- reshape2::dcast(data = merged, SubjectNum + Activity ~ variable, fun.aggregate = mean)

#Final table
data.table::fwrite(x = merged, file = "tidyData.txt", quote = FALSE)
View(merged)
