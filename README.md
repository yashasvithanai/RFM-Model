# RFM Model
Purchase history holds a lot of power to understand consumers’ patterns and leverage it to target optimally for promotional activities and improving sales. 

I am provided with purchase history of 1000 customers for a brand CDNOW over the past 18 months. The objective is to segment high-value customers from the low-value ones by utilizing RFM (Recency, Frequency, Monetary Value) model.

RFM helps answer the following business questions:
1.	how recently a customer has transacted with the brand
2.	how frequently they’ve engaged with the brand
3.	how much money they’ve spent on a brand’s products and services

## Data Preparation

I first familiarize myself with the data provided. 
- The time-series data is highly granular, with purchase data from each day in 18 months. 
- I aggregate the data into monthly data with number of trips and total expenditure and total quantity purchased. 
- I also convert the data type of month and year to date format. 
- Anticipating the possibility that there are months when no trips were made by a consumer, we create rows with for total purchases in each month for a consumer. 

This prepares our data for analysis.

_Here is Aggregated Purchase Data for Consumer id 1_

<img width="586" alt="Data Preparation" src="https://user-images.githubusercontent.com/119455759/211009953-1be7f151-cbaa-4c5a-870b-8b54c5ab0501.png">

## Calculation of RFM

### Loops
When a set of tasks are to be repeated over and over again, creating loops is a critical skill which comes to use. Being a data professional, one works with tables containing thousands of rows, and therefore comes across such tasks regularly. Therefore, it is imperative to practice this skill. This project utilizes the use of loops.

### Recency 
The algorithm is written to utilize historical data identifying the number of months since the consumer made the last purchase, calculating the recency of each consumer in each month. 

### Frequency 
The data is first aggregated to find total number of trips each consumer takes in each quarter. The algorithm for frequency is written to identify the total number of trips a consumer takes in the previous quarter.

### Monetary Value
The loop utilizes historical data to calculate average monthly expenditure for a consumer, in the previous months when they purchased something. (This was challenging, my code returned incorrect values, and I spent 3 hours to figure out how to make it work! Turns out, I had to take the constant value inside the loop.)

_RFM values for Consumer id 1_
<img width="1050" alt="RFM results" src="https://user-images.githubusercontent.com/119455759/211010911-f5d38f0b-4739-48fa-99c3-f56e915f70f9.png">

### Targeting 
The factor loadings are provided. 
The RFM index is calculated as:

index = -0.05*(recency) + 3.5*(frequency) + 0.05*(monetary value)

A high-value consumer will have low recency, high frequency, and high monetary value. 

We divide the consumers into quantiles using by their index values. We find that the consumers with highest 10% index values have an average expenditure of $15.65.  
<img width="555" alt="Targeting" src="https://user-images.githubusercontent.com/119455759/211011204-41bff7b3-0c5c-4055-9ae2-a37a83e90158.png">
