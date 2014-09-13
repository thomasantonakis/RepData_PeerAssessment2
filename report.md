---
title: "Reproducible Research: Peer Assessment 2"
output: 
  html_document:
    keep_md: true
---



# Reproducible Research Assignment 2
========================================================

## *Thomas Antonakis*

### Title

Your document should have a title that briefly summarizes your data analysis


### Synopsis

Immediately after the title, there should be a synopsis which describes and summarizes your analysis in at most 10 complete sentences.

### Data Processing

There should be a section titled Data Processing which describes (in words and code) how the data were loaded into R and processed for analysis. In particular, your analysis must start from the raw CSV file containing the data. You cannot do any preprocessing outside the document. If preprocessing is time-consuming you may consider using the cache = TRUE option for certain code chunks.

This project involves exploring the U.S. National Oceanic and Atmospheric Administration's (NOAA) storm database. THis database tracks characteristics of major storms and weather events in the United States, including when and where they occur, as well as estimates of any fatalities, injuries, property and crop damage.  
The events in the database start in the year 1950 and end in November 2011. In the earlier years of the database there are generally fewer events recorded, most likely due to lack of good records. More recent years should be considered more complete.  
The data for the  analysis came in form of a comma-separated-value file compressed via the bzip2 algorithm to reduce its size.  
Let's first of all download the file.  

```r
# Create folder to put download the file
if(!file.exists("./data")){dir.create("./data")}

# Download the file, and keep the date. 
if(!file.exists("./data/storm_data.csv.bz2")){
fileurl<-"https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
download.file(fileurl, destfile="./data/storm_data.csv.bz2", method="auto")
dateDownloaded<-date()
}
```

The file is now downloaded to a local folder. We now will unzip it and load it into a dataset in the R environment.  

*Loading the whole dataset in R, caused knitr to stop its executionand not showing anything from this point down in the report. The loading was done in R studio , some exploration was performed and below we will only load / read the variables that seem to be related with the questions of the assignment.*  


```r
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
```

This may take a couple of minutes depending on the sustem, as the csv is 47Mb big compressed and uncompressed is much much more than that: 548Mb.  
So, hopefully, after the csv has been loaded in a dataframe named `storm` , we can check it out a little bit.


```r
# Check the file out
dim(storm)
```

```
## [1] 902297      8
```

```r
str(storm)
```

```
## 'data.frame':	902297 obs. of  8 variables:
##  $ BGN_DATE  : chr  "4/18/1950 0:00:00" "4/18/1950 0:00:00" "2/20/1951 0:00:00" "6/8/1951 0:00:00" ...
##  $ EVTYPE    : chr  "TORNADO" "TORNADO" "TORNADO" "TORNADO" ...
##  $ FATALITIES: num  0 0 0 0 0 0 0 0 1 0 ...
##  $ INJURIES  : num  15 0 2 2 2 6 1 0 14 0 ...
##  $ PROPDMG   : num  25 2.5 25 2.5 2.5 2.5 2.5 2.5 25 25 ...
##  $ PROPDMGEXP: chr  "K" "K" "K" "K" ...
##  $ CROPDMG   : num  0 0 0 0 0 0 0 0 0 0 ...
##  $ CROPDMGEXP: chr  "" "" "" "" ...
```

```r
summary(storm)
```

```
##    BGN_DATE            EVTYPE            FATALITIES     INJURIES     
##  Length:902297      Length:902297      Min.   :  0   Min.   :   0.0  
##  Class :character   Class :character   1st Qu.:  0   1st Qu.:   0.0  
##  Mode  :character   Mode  :character   Median :  0   Median :   0.0  
##                                        Mean   :  0   Mean   :   0.2  
##                                        3rd Qu.:  0   3rd Qu.:   0.0  
##                                        Max.   :583   Max.   :1700.0  
##     PROPDMG      PROPDMGEXP           CROPDMG       CROPDMGEXP       
##  Min.   :   0   Length:902297      Min.   :  0.0   Length:902297     
##  1st Qu.:   0   Class :character   1st Qu.:  0.0   Class :character  
##  Median :   0   Mode  :character   Median :  0.0   Mode  :character  
##  Mean   :  12                      Mean   :  1.5                     
##  3rd Qu.:   0                      3rd Qu.:  0.0                     
##  Max.   :5000                      Max.   :990.0
```

The initial dataframe contains 902297 observations and 8 variables which are explained below:  
1. BGN_DATE is for now a character variable which contains the date of the record.  
2. EVTYPE is a character variable which contains the type of event.  
3. FATALITIES is a numeric vector containing the number of deaths caused by a specific observation.  
4. INJURIESis a numeric vector containing the number of injured persons caused by a specific observation.  
5. PROPDMG is a numeric vector containing an estimate from the researcher of the economic damage caused by a specific observation in units (see next variable) on prroperties.  
6. PROPDMGEXP is a character variable which should contain a letter, ideally one of the following "H","K","M","B". These letters should stand for Hundreds, Thousands, Millions, and Billions.  
7. CROPDMG is a numeric vector containing an estimate from the researcher of the economic damage caused by a specific observation in units (see next variable) on crops.
8. CROPDMGEXPis a character variable which should contain a letter, ideally one of the following "H","K","M","B". These letters should stand for Hundreds, Thousands, Millions, and Billions.  

We will transform the BGN_DATE variable to the year of the record. Knowing that the records span from 1950 to 2011, days, months do not really matter.


```r
# Fix dates Convert date and time to YEAR
storm$BGN_DATE <- as.numeric(format(as.Date(storm$BGN_DATE, format = "%m/%d/%Y %H:%M:%S"), "%Y"))
```

We will calculate the quantiles of the distribution of the years below.

```r
quantile(storm$BGN_DATE, c(seq(from=0.1, to=1, by = 0.1)))
```

```
##  10%  20%  30%  40%  50%  60%  70%  80%  90% 100% 
## 1982 1992 1996 1999 2002 2004 2006 2008 2010 2011
```

Let's make a histogram of the number of observations per year.

```r
# Histogram the years for the count of records 
hist(storm$BGN_DATE, main = "Number of storm events per year", 
     xlab = "Year")
```

![plot of chunk init hist for years](figure/init hist for years.png) 

In the earlier years of the database there are generally fewer events recorded, most likely due to lack of good records. More recent years should be considered more complete.  We will take out of the analysis records who date earlier than 1980.  

The propostion of observations before 1980 are the 8.35% of total observations, and will nw be dropped out.  


```r
# Decide which years to keep
storm<-storm[storm$BGN_DATE>=1980,]
```

Having now made up our minds about the years we will use, we will create an intermediate file that will be used from now on for the anaysis. The old dataframe will be deleted for memory reasons.


```r
# We do not need all variables. After checking the documentation we keep the following
file_intermediate<-data.frame("EVTYPE" = storm$EVTYPE, "FATALITIES" = storm$FATALITIES,
                              "INJURIES" = storm$INJURIES, "PROPDMG" = storm$PROPDMG, 
                              "PROPDMGEXP" = storm$PROPDMGEXP, "CROPDMG" = storm$CROPDMG, 
                              "CROPDMGEXP" = storm$CROPDMGEXP)

# Release memory
rm(storm)
```


### Results

There should be a section titled Results in which your results are presented.

The analysis document must have at least one figure containing a plot.

Your analyis must have no more than three figures. Figures may have multiple plots in them (i.e. panel plots), but there cannot be more than three figures total.
