# # ===================================================
# GBA464: RFM analysis on CDNOW data
# Author: Yufeng Huang
# Description: Lab on functions and loops
# Data: CDNOW customer data (this time full data)
# Source: provided by Professor Bruce Hardie on
#   http://www.brucehardie.com/datasets/CDNOW_sample.zip
# ==============================================================================


## Student Name: Yashasvi Thanai
## Course: MS in Business Analytics 
## Note: Double hashtags are comments added by the student


# =========================== CLEAR EVERYTHING =================================
rm(list = ls())

#========================= READ TRIAL DATA =====================================


#==================== Section 2: loading the data ==============================

df.raw[[1]] <- NULL # drop old id
names(df.raw) <- c("id", "date", "qty", "expd")



# a) generate year and month

## checking the type of the date column
typeof(df.raw$date) 

## converting into a character as the as.Date function works on characters
df.raw$date <- as.character(df.raw$date)
df.raw$date <- as.Date(df.raw$date, format = "%Y%m%d")

## extracting and creating month and year columns 
df.raw$year <- format(df.raw$date, "%Y")
df.raw$month <- format(df.raw$date, "%m")


# b) aggregate into monthly data with number of trips and total expenditure

typeof(df.raw$qty)

## using aggregate function to find total expenditure and total quantity 
## an individual spends in a particular year and month 
qty.expd <- aggregate(x = list(total_qty = df.raw$qty, total_expd = df.raw$expd), 
          by = list(id = df.raw$id, year = df.raw$year, month = df.raw$month),
          FUN = sum )


## aggregating to find the number of times an individual visits the store 
## in a particular month and year
## by counting the rows where id, year and month are the same
trips <- aggregate(x = list(trips = df.raw$date),
          by = list(id = df.raw$id, year = df.raw$year, month = df.raw$month),
          FUN = length)

## merging the aggregated data
agg_purchased_data <- merge(qty.expd, trips, by= c("id", "year", "month"))


# c) generate a table of year-months, merge, replace no trip to zero.
# Hint: how do you deal with year-months with no trip? These periods are not in the original data,
# but you might need to have these periods when you calculate RFM, right?
# Consider expanding the time frame using expand.grid() but you do not have to.


## creating a data frame with the first date of all 18 months
## and then merging it with our data set
id <- 1:1000
dates <- c("1997-01-01", "1997-02-01", "1997-03-01", "1997-04-01", "1997-05-01", "1997-06-01", "1997-07-01", "1997-08-01", "1997-09-01", "1997-10-01", "1997-11-01", "1997-12-01", "1998-01-01", "1998-02-01", "1998-03-01", "1998-04-01", "1998-05-01", "1998-06-01")

time.frame <- expand.grid(id, dates)
colnames(time.frame) <- c("id", "dates")

time.frame$dates <- as.Date(as.character(time.frame$dates), "%Y-%m-%d")
time.frame$year <- format(time.frame$dates, "%Y")
time.frame$month <- format(time.frame$dates, "%m")

time.frame$month_index <- c(rep(1, 1000),rep(2, 1000),rep(3, 1000),rep(4, 1000),rep(5, 1000),rep(6, 1000),rep(7, 1000),rep(8, 1000),rep(9, 1000),rep(10, 1000),rep(11, 1000),rep(12, 1000),rep(13, 1000),rep(14, 1000),rep(15, 1000),rep(16, 1000),rep(17, 1000),rep(18, 1000))

df <- merge(agg_purchased_data, time.frame, by= c("id", "year", "month"), all = TRUE)
## replacing the NA values with 0
df[is.na(df)] <- 0


# now we should have the dataset we need;
#   double check to make sure that every consumer is in every period (18 months in total)


# ======================= Section 3.1: recency =================================
# use repetition statement, such as a "for-loop", to generate a recency measure for each consumer 
#   in each period. Hint: if you get stuck here, take a look at Example 3 when we talked about "for-loops"
#   call it df$recency

trips <- df$trips

df$recency <- rep(NA, 18000)
df$recency[1] <- NA

## we derive recency from the trips column 

## if number of trips is not equal to zero for the previous row, 
## then recency takes the value as 1 

## if number trips is equal to 0 for the previous row, 
## then recency takes the value equal to (previous month's recency + 1)

## the code runs after identifying each individual using the loop

## for loop calculating the recency for each individual
for(i in 1:1000){
    for(m in 2:18){
        if(df[which(df$id == i)[m-1], "trips"] != 0){
            df[which(df$id == i)[m], "recency"] <- 1
        } else{
            df[which(df$id == i)[m], "recency"] <-  df$recency[which(df$id == i)[m-1]] + 1
        }   
    }
}



# ======================= Section 3.2: frequency ===============================
# first define quarters and collapse/merge data sets
#   quarters should be e.g. 1 for January-March, 1997, 2 for April-June, 1997, ...
#   and there should be six quarters in the 1.5-year period
#   Next, let's define frequency purchase occasions in PAST QUARTER
#   Call this df$frequency


## we first create a column for identifying quarters
## using the month index previously created

df$quarters <- rep(NA, 18000)

df$quarters[which(df$month_index == 1:3)] <- 1
df$quarters[which(df$month_index == 4:6)] <- 2
df$quarters[which(df$month_index == 7:9)] <- 3
df$quarters[which(df$month_index == 10:12)] <- 4
df$quarters[which(df$month_index == 13:15)] <- 5
df$quarters[which(df$month_index == 16:18)] <- 6

## using the aggregate function we calculate the total trips 
## an individual took in a quarter 

## quarterly trips data frame is created
quarterly_trips <- aggregate(x = list(trips_this_quarter = df$trips), 
                             by = list(id = df$id, quarters = df$quarters), 
                             FUN = sum)

## calculating frequency
## frequency for a particular row is equal to trips taken in the previous quarter
## we use the loop to calculate frequency for each individual in each quarter

quarterly_trips$frequency <- rep(NA, 6000)

# quarterly_trips$frequency[2] <- quarterly_trips$trips_this_quarter[1]
# quarterly_trips[which(quarterly_trips$id == 1)[1], "trips_this_quarter"]

for(i in 1:1000){
   for(q in 2:6){
       quarterly_trips[which(quarterly_trips$id == i)[q], "frequency"] <- quarterly_trips[which(quarterly_trips$id == i)[q-1], "trips_this_quarter"]
   } 
}


df <- merge(df, quarterly_trips, by = c("id", "quarters"))

# ======================== Section 3.3: monetary value =========================
# average monthly expenditure in the months with trips (i.e. when expenditure is nonzero)
#   for each individual in each month, find the average expenditure from the start of the sample to 
#   the PAST MONTH. Call this df$monvalue


## we first calculate cumulative expenditure for each individual
df$cumulative_expd <- rep(NA,18000)

for(i in 1:1000){
    df$cumulative_expd[which(df$id ==i)] <- cumsum(df$total_expd[which(df$id== i)])
}



## we first check when an id makes their first purchase

## calculating monetary value
## our code compares cumulative expenditure for previous two rows 
## if it is not equal, then our variable m (for total number of observations)
## increases by 1
## and monetary value is calculated by taking the cumulative expenditure of the previous row
## and dividing it by m 

## if the cumulative expenditure for the previous two rows are equal 
## then the monetary value is calculated by taking the previous row's monetary value

df$monvalue <- rep(NA, 18000)


for(i in 1:1000){
    m <- 0
    id1 <- which(df$id == i)
    if(df[id[1],'total_expd']  == 0){
        for(c in 3){
            df[which(df$id == i)[c], "monvalue"] <- df[which(df$id == i)[c-1], "cumulative_expd"]
        }
        for (c in 4:18) {
            if(df[which(df$id == i)[c-1],"cumulative_expd" ] != df[which(df$id == i)[c-2],"cumulative_expd" ] ){
                m <- m + 1
                df[which(df$id == i)[c], "monvalue"] <- (df[which(df$id == i)[c-1], "cumulative_expd"])/(m)
            } else{
                df[which(df$id == i)[c], "monvalue"] <- df[which(df$id == i)[c-1], "monvalue"] 
            }  
        }
        
    }else{
        for(c in 2){
            df[which(df$id == i)[c], "monvalue"] <- df[which(df$id == i)[c-1], "cumulative_expd"]
        }
        for (c in 3:18) {
            if(df[which(df$id == i)[c-1],"cumulative_expd" ] != df[which(df$id == i)[c-2],"cumulative_expd" ] ){
                m <- m + 1
                df[which(df$id == i)[c], "monvalue"] <- (df[which(df$id == i)[c-1], "cumulative_expd"])/(m)
            } else{
                df[which(df$id == i)[c], "monvalue"] <- df[which(df$id == i)[c-1], "monvalue"] 
            }  
        }
    }
    
}






# ===================== Section 4: Targeting using RFM =========================
# now combine these and construct an RFM index
#   You only need to run this section.

b1 <- -0.05
b2 <- 3.5
b3 <- 0.05

df$index <- b1*df$recency + b2*df$frequency + b3*df$monvalue

View(quarterly_trips)

View(df)











