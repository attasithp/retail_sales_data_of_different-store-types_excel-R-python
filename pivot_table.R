library(tidyverse)


# url for dataset
url = "https://raw.githubusercontent.com/attasithp/retail_sales_data_of_different-store-types_excel-R-python/main/retail_sales_data%20(clean).csv"

# Load dataset
retail <- read_csv(url, show_col_types = FALSE)

# # Add calculated columns of 'Revenue' and 'Profit'
retail <- retail %>% mutate( Revenue = `Volume`*`Price per unit`, Profit = `Volume`*(`Price per unit` - `Cost per unit`)) 

# Aggregate data and group by 'Type', 'Product group', and 'Year' of Sales, Volumes, and Profits.
long_pivot_retail <- retail %>% group_by(Type, `Product group`, Year) %>% 
                                summarize(Sales = sum(Revenue), Volumes = sum(Volume), Profits = sum(Profit))

# Transfrom log-format pivot table from the previous step into wide-format pivotable.
wide_pivot_retail <- long_pivot_retail %>% 
                     pivot_wider(names_from = Year, values_from = c(Sales, Volumes, Profits)) %>% 
                     mutate_if(is.numeric, round)

# Create Total column by sum of years
wide_pivot_retail_2 <- wide_pivot_retail %>% mutate(  Total_Sales = Sales_2011 + Sales_2012 + Sales_2013 + Sales_2014,
                                                      Total_Volumes = Volumes_2011 + Volumes_2012 + Volumes_2013 + Volumes_2014,
                                                      Total_Profits = Profits_2011 + Profits_2012 + Profits_2013 + Profits_2014)


# Calculate Grand Total Row
grand_total <- c('Grand Total', ' : ')

for (i in 3:length(wide_pivot_retail_2)) {
    grand_total[i] = sum(wide_pivot_retail_2[i])
}   

grand_total

# Bind grand total to the pivot table
wide_pivot_retail_3 <- wide_pivot_retail_2 %>% as_tibble() %>% rbind(grand_total)

# Reorder the columns corresponding to the columns order in the excel file
wide_pivot_final    <- wide_pivot_retail_3[ , c(1,2, 3,7,11, 4,8,12, 5,9,13, 6,10,14, 15,16,17)]

# Show the final output
wide_pivot_final