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





