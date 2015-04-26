
CodeBook.md

This is the CodeBook file for run_analysis.md. Please see README.md for a description of the data source and information on the data used from the data source.

run_analysis.md creates a tidy data set from the data source. The tidy data set is created from a data frame with 4 variables.

___
Code Book (description of the variables)
___

subject : 
        Identifies the subject who performed the activity for each sample. Its range is from 1                                                 to 30 found in the files 'train/subject_train.txt' and 'test/subject_test.txt'
        
activity: 
        The activity name 'activity_labels.txt' There are six possible options-
        WALKING           
        WALKING_UPSTAIRS   
        WALKING_DOWNSTAIRS 
        SITTING            
        STANDING          
        LAYING
        Each activity has an associated value with a range of 1 to 6. The activity is specified in the files ('train/y_train.txt' and 'test/y_test.txt') which correspond to the train and test set.
        
features: 
        There are 66 possible features which are selected from the larger feature set in the original train and test set. Specifically, variables that measure mean() (Mean value) and std()(Standard deviation) have been selected from 'train/X_train.txt' and 'test/X_test.txt' Variables that include 'mean' or 'std' in the name but are not explicit a mean() or std() function computation are not included.
        
        The features are described fully in the features_info.txt file with the original data and appear as variables in the original data. They are melted into one variable called feature by run_analysis.R. The following information is taken from that file to explain the the meaning of the feature names that can appear in the features column.
        
        "The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz. 

        Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag). 

        Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals). 

        These signals were used to estimate variables of the feature vector for each pattern:  
'-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.

        tBodyAcc-XYZ
        tGravityAcc-XYZ
        tBodyAccJerk-XYZ
        tBodyGyro-XYZ
        tBodyGyroJerk-XYZ
        tBodyAccMag
        tGravityAccMag
        tBodyAccJerkMag
        tBodyGyroMag
        tBodyGyroJerkMag
        fBodyAcc-XYZ
        fBodyAccJerk-XYZ
        fBodyGyro-XYZ
        fBodyAccMag
        fBodyAccJerkMag
        fBodyGyroMag
        fBodyGyroJerkMag

        The set of variables that were estimated from these signals are: 

        mean(): Mean value
        std(): Standard deviation""

        Additional vectors and variables used in the original data but that are not included in this data set have not been described here. 
        
value   : 
        The value of a given feature for a subject performing a specified activity. The computation of this value is described more fully above in "features".
        
___
Study Design
___
Please see the README.md file for information on the study source in order to obtain background information on the study design.

___
Summary
___

The following section documents the choices made in the run_analysis.R script.

The data provided for the train and test information was included across 3 files for each data set- X, Y, and subject. Each of these contain the same number of variables in the train and test sets. The number of observations differs in each set.

The data is initially combined into two data frames by binding the columns- raw_test and raw_train. Each data frame has 563 variables- 561 from X, 1 from Y and 1 from subject. These two data frames are then combined into one, using rbind, resulting in a 563 variable data frame with the observations from test and train. This data frame is called raw_data.

features.txt contains the name of the 561 variables in the data set. This file is read then the values of the second variable, V2, are applied to the first 561 variables of raw_data, followed by the column names "activity_code" and "subject" which correspond to the Y and subject data that form the last 2 variables of the data frame.

Now that the data frame has column names, the grepl function can be used to create a subset of the data with the variables that use from the signal that are computed using mean() and std(). In order to restrict the sub-setting to mean() and std(), [[:punct:]] is used in the grep function to account for the () in the variable name. The parameters in the grepl function will also pull the subject and activity_code variables. The resulting subset of data, sub_data, contains 68 variables.

In order to transform the numbers in the activity_code column to their corresponding descriptive labels provided in the acitvity_labels.txt file, a factor called "act" is created with 6 levels (the 6 activity labels). By default, the levels of the factor are sorted alphabetically. To counteract this, level is used to explicitly assign levels to each label so they match activity_labels.txt.

Mutate (part of dplyr) is used to create a new variable in sub_data called activity that applies the levels of act to the activity_code variable. Select is then used on sub_data to select all variables except activity_code. The ability of dplyr to chain actions on the same data frame is utilized and the resulting data is assigned back to sub_data.

Melt (part of reshape2) is used to transform the data set to a new data frame, mdata, by collapsing the 66 features variables into one variable called features. The values then become the variable names. Now there are 4 variables-- subject, activity, variable, and value-- as described above. The dplyr rename function is used to rename variable to features. mdata is a tidy data set created from the initial raw data that can be used for analysis purposes.

An independent second tidy data set, tidy_data, is created from mdata. It computes the average of each variable for each activity and each subject. This is done via the plyr function ddply to split the data frame, apply mean, and return a new data frame. The new data frame contains the variables subject, activity, and features (as described above) and a new variable- mean. Where mdata has multiple observations for a given subject, activity, and feature tidy_data has one observation for a given subject, activity, and feature which is the mean of all the values for those variables in mdata.


