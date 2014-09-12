# Create folder to put download the file
if(!file.exists("./data")){dir.create("./data")}

# Download the file, and keep the date. SOS CACHE
if(!file.exists("./data/storm_data.csv.bz2")){
fileurl<-"https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
download.file(fileurl, destfile="./data/storm_data.csv.bz2", method="auto")
dateDownloaded<-date()
}

# "Unzip file" to a variable
filename <- bzfile("./data/storm_data.csv.bz2")

# Load file in a dataframe. SOS CACHE
if (!exists("storm")){
storm<-read.csv(filename, stringsAsFactors = FALSE)
}

# Check the file out
dim(storm)
str(storm)
summary(storm)

# We do not need all variables. After checking the documentation we keep the following
file_intermediate<-data.frame("EVTYPE" = storm$EVTYPE, "FATALITIES" = storm$FATALITIES,
                              "INJURIES" = storm$INJURIES, "PROPDMG" = storm$PROPDMG, 
                              "PROPDMGEXP" = storm$PROPDMGEXP, "CROPDMG" = storm$CROPDMG, 
                              "CROPDMGEXP" = storm$CROPDMGEXP)

# Release memory
rm(storm)

# Check the intermediate file out
str(file_intermediate)
summary(file_intermediate)

#Check the variables connected to population health effects
sum(file_intermediate$FATALITIES)
sum(file_intermediate$INJURIES)

# Store health related variables to a separate dataframe.
health<-data.frame("EVTYPE" = file_intermediate$EVTYPE, 
                   "FATALITIES" = file_intermediate$FATALITIES,
                   "INJURIES" = file_intermediate$INJURIES)

# "Clean" data frame names
names(health)<-tolower(names(health))

# Calculate a health damage index using the fatalities and injuries variables
# We assume that one fatality weighs as much as 10 injuries in terms of health damage
health$damage <- health$injuries + 10 * health$fatalities

library(plyr)
tom<-ddply(.data=health, .variables=.(evtype) , summarize, sum = sum(damage))
head(tom)

# Explore the variables connected to monetary damages.
table(file_intermediate$PROPDMGEXP, useNA="ifany")
table(file_intermediate$CROPDMGEXP, useNA="ifany")

# Upper-case everything
file_intermediate$PROPDMGEXP<-toupper(file_intermediate$PROPDMGEXP)
file_intermediate$CROPDMGEXP<-toupper(file_intermediate$CROPDMGEXP)

# Assign everyhing that is not empty or "K", "M", "B" to Missing value
file_intermediate$PROPDMGEXP[!file_intermediate$PROPDMGEXP %in% 
                                     c("", "K","M","B")]<-NA
file_intermediate$CROPDMGEXP[!file_intermediate$CROPDMGEXP %in% 
                                     c("", "K","M","B")]<-NA

# Summarize new exponents
table(file_intermediate$PROPDMGEXP, useNA="ifany")
table(file_intermediate$CROPDMGEXP, useNA="ifany")


# Store money related variables to a separate dataframe.
economic<-data.frame("EVTYPE" = file_intermediate$EVTYPE, 
                   "PROPDMG" = file_intermediate$PROPDMG, 
                   "PROPDMGEXP" = file_intermediate$PROPDMGEXP, 
                   "CROPDMG" = file_intermediate$CROPDMG, 
                   "CROPDMGEXP" = file_intermediate$CROPDMGEXP)

# "Clean" data frame names
names(economic)<-tolower(names(economic))

# Release memory
rm(file_intermediate)

# Calculate share of missing values
good<- complete.cases(economic$propdmgexp,economic$cropdmgexp)
round(abs(sum(good)/nrow(economic)-1)*100, 2)

# Take Missing values out of economic dataframe
economic<-economic[good,]

# Release memory
rm(good)

# Check the economic file out
str(economic)
summary(economic)

# Calculate an economic damage index using the given variables
# First the exponents must be transformed to multipliers


# Suppose that property damage of one dollar weighs exactly as a crop damage of 
# one dollar in the economical damage, then the economic damage index is just 
# the sum of the crops and property product of exponents and dollar figures.

economic$damage <- economic$propdmg * economic$propdmgexp + 
        economic$cropdmg * economic$cropdmgexp
