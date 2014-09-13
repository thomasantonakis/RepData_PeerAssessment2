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
The data for the  analysis cme in form of a comma-separated-value file compressed via the bzip2 algorithm to reduce its size.  
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
So, hopefully, after the csv has been loaded in a dataframe named `storm` , we can check it out a little bit


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

### Results

There should be a section titled Results in which your results are presented.

The analysis document must have at least one figure containing a plot.

Your analyis must have no more than three figures. Figures may have multiple plots in them (i.e. panel plots), but there cannot be more than three figures total.
