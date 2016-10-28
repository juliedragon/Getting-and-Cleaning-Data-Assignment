#Load the needed library
library(plyr)

#Merge the training and the test sets with their activity label files then create one data set.
testdf <- read.table("./Dataset/test/X_test.txt")
testlabels <- read.table("./Dataset/test/Y_test.txt")
testsubject <-read.table("./Dataset/test/subject_test.txt")
test <- cbind(testsubject, testlabels, testdf)
traindf <- read.table("./Dataset/train/X_train.txt")
trainlabels <- read.table("./Dataset/train/Y_train.txt")
trainsubject <-read.table("./Dataset/train/subject_train.txt")
train <- cbind(trainsubject, trainlabels, traindf)
combodf <- rbind(test, train)

#Tidy the feature labels to remove unwanted characters and add them as column headers
Features <- read.table("./Dataset/features.txt", header = FALSE, 
                       col.names = c("Number", "DataFeature")) 
FeaturesTidy <- gsub("-|\\(|,|\\)", "", as.character(Features[ , "DataFeature"]))
colnames(combodf)<- c("Subject", "Activity", FeaturesTidy)

#Extract only the measurements on the mean and standard deviation for each feature.
combodfFiltered <- combodf[,grep("Subject|Activity|mean|std",colnames(combodf))]
combodfExtractionMean <- ddply(combodfFiltered,.(Subject,Activity),colwise(mean))
      
#Add the descriptive activity labels to the extracted feature measures from the combined data set
ActivityLabels <- read.table("./Dataset/activity_labels.txt", header = FALSE, 
                             col.names = c("Number", "Activity"))
ActivityLabels <- tolower(ActivityLabels$Activity)
ActivityLabelsTidy <- gsub("_", "", ActivityLabels)

combodfExtractionMean$Activity <- as.factor(combodfExtractionMean$Activity)
levels(combodfExtractionMean$Activity) <- ActivityLabelsTidy

#From the combined data set feature means, create a second, independent tidy data set 
#with the average of each variable for each activity and each subject.
write.table(combodfExtractionMean, file="TidyMean.txt", row.names = FALSE, 
            sep = "\t")
