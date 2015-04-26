#The following packages are required to run this script.

require(dplyr)
require(reshape2)
require(plyr)

#Create a data table each for the test and train data, including the acitvity code and subject.
#Bind these two tables into one table. cbind is used to add the three files from each set to one
#another. This results in a table of test data and a table of train data, each with the same number
#of columns. rbind is used to combine the rows from test and train together, creating one large
#table.

raw_test <- cbind(read.table("./UCI HAR Dataset/test/X_test.txt"), read.table("./UCI HAR Dataset/test/Y_test.txt"), read.table("./UCI HAR Dataset/test/subject_test.txt"))
raw_train <- cbind(read.table("./UCI HAR Dataset/train/X_train.txt"), read.table("./UCI HAR Dataset/train/Y_train.txt"), read.table("./UCI HAR Dataset/train/subject_train.txt"))
raw_data <- rbind(raw_test, raw_train)

#The provided features.txt file list the columns found in X_test and X_train. It is used to create column 
#labels for the combined table. Additionally, labels are added for the activity code and subject.

col_labels <- read.table("./UCI HAR Dataset/features.txt")
colnames(raw_data) <- c(as.character(col_labels$V2), "activity_code", "subject")

#With the grepl function, use the column names to create a subset of the data that is comprised 
#of the mean() and std() #columns. Include the activity code and subject columns from the table.

sub_data <- raw_data[ , grepl("mean[[:punct:]]|std[[:punct:]]|subject|activity", names(raw_data))]

#Create a factor of the activity descriptions found in activity_labels.txt.
#By default, factor will alphabetize the levels. The levels function is used to apply a ranking
#to the data to match what is found in activity_labels.txt

act <- read.table("./UCI HAR Dataset/activity_labels.txt")
act <- act[,2]
act = factor(act, levels(act)[c(4,6,5,2,3,1)])

#Use the dplyr functions to create a new activity column with mutate that replaces the activity 
#code with the descriptor from the factor act created above. Then remove the activity_code column.

sub_data <- sub_data %>% mutate(activity = act[sub_data$activity_code]) %>% select(-activity_code)

#Melt the data. By changing subject to a factor, melt will assign factor (subject and activity in this
#case and character variables as id variables and the remainder as measured variables by default. So
#the table is transofrmed to a 4 column table with the feature columns as one column and their values
#as another column. Subject and activity are the other two columns. Use rename to update variable 
#names in the new data.frame to be more descriptive. dplyr::rename must be specified since plyr is 
#loaded and has a rename function as well.

sub_data$subject <- as.factor(sub_data$subject)
mdata <- melt(sub_data)
mdata <- dplyr::rename(mdata, features=variable)

#Use the plyr function ddply to split the data frame, apply mean, and return a new data frame.
#For each instance of a subject, activity, and feature, the mean of the values for that group is
#computed into a new variable (column) called mean.

tidy_data<-ddply(mdata, .(subject,activity,features), summarize, mean=mean(value))

#Write the tidy_data to a file. Read the file and output the result.

write.table(tidy_data, "./tidy_data_final.txt", row.name=FALSE )
data <- read.table("./tidy_data_final", header = TRUE)
View(data)
