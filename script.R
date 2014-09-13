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

# Load file in a dataframe. 
# We do not need all variables. After checking the documentation we keep the following
if (!exists("storm")){
storm<-read.csv(filename, stringsAsFactors = FALSE, 
                colClasses=c("NULL", NA   ,"NULL","NULL","NULL",
                             "NULL","NULL", NA   ,"NULL","NULL",
                             "NULL","NULL","NULL","NULL","NULL",
                             "NULL","NULL","NULL","NULL","NULL",
                             "NULL","NULL",NA,NA,NA,
                             NA,NA,NA,"NULL","NULL",
                             "NULL","NULL","NULL","NULL","NULL",
                             "NULL","NULL"))
}
# close(filename)

# Check the file out
dim(storm)
str(storm)
summary(storm)

# Fix dates Convert date and time to YEAR
storm$BGN_DATE <- as.numeric(format(as.Date(storm$BGN_DATE, format = "%m/%d/%Y %H:%M:%S"), "%Y"))
quantile(storm$BGN_DATE, c(seq(from=0.1, to=1, by = 0.1)))

# Histogram the years for the count of records 
hist(storm$BGN_DATE, main = "Number of storm events per year", 
     xlab = "Year")

# How many are before 1980?
round(sum(storm$BGN_DATE<1980)/nrow(storm)*100, 2)

# Decide which years to keep
storm<-storm[storm$BGN_DATE>=1980,]

# Histogram the years for the count of records 
hist(storm$BGN_DATE)

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

# Calculate sum of damages and average damage per evtype
library(plyr)
health_sum<-ddply(.data=health, .variables=.(evtype) , summarize, sum = sum(damage))
health_ave<-ddply(.data=health, .variables=.(evtype) , summarize, sum = mean(damage))
names(health_sum) [2]<- c("sum_damage")
names(health_ave) [2]<- c("avg_damage")
health_agg<-arrange(join(health_sum, health_ave), evtype)
a<-head(arrange(health_agg, sum_damage, decreasing = TRUE), 10)
a
head(arrange(health_agg, avg_damage, decreasing = TRUE), 10)

# Sum will be used
# Make a plot to illustrate greatest threats
aplot <- a$sum_damage
names(aplot) <- a$evtype
par(mar = c(4, 10, 4, 1))
barplot(aplot, col= 2, main="Top types of events in \n total health Damage index", 
        horiz=TRUE, las=1)

# Release memory
rm(health_sum,health_ave)

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
