# Import library
import pandas as pd
import numpy as np

# url for dataset
url = "https://raw.githubusercontent.com/attasithp/retail_sales_data_of_different-store-types_excel-R-python/main/retail_sales_data%20(clean).csv"

# read .csv for dataset
retail = pd.read_csv(url)

# Add calculated columns of 'Revenue' and 'Profit'
retail['Revenue'] = retail['Volume']*retail['Price per unit']
retail['Profit'] = (retail['Price per unit'] - retail['Cost per unit'])*retail['Volume']

# สร้างตาราง pivot table ได้ตรงๆ ด้วย method ที่ชื่อว่า pivot_table
retail.pivot_table(index = ["Type", "Product group"], 
                   columns = "Year", 
                   values =  ['Revenue', 'Volume', 'Profit'], 
                   aggfunc = np.sum , 
                   margins = True).round()