# ---- Step 1 : Import data ----

# Import Library
import pandas as pd
import numpy as np

# เก็บ Data เอาไว้อยู่ในตัวแปรที่ชื่อ retail
url = "https://raw.githubusercontent.com/attasithp/sales_data_of_different-channels_excel-R-python/main/retail_sales_data%20(raw).csv"
retail = pd.read_csv(url)




# ---- Step 2 : Empty rows ----

# เริ่มจากเอาหน้าตา Empty row ขึ้นมาดูก่อน
retail[(retail.isna().sum(axis=1) == len(retail.columns))]

# Filter Empty Row
retail_no_emp_row  = retail[(retail.isna().sum(axis=1) != len(retail.columns))]




# ---- Step 3 : Data type error & Missing Values ----

# Convert data type ด้วย ของคอลัมน์ Year จาก float เป็น integer
retail_no_emp_row = retail_no_emp_row.astype({'Year' : int})

# ดู Structure ของข้อมูลหลังจากเอา Empty rows ออก
# ให้สังเกตว่าคอลัมน์ 'Volume' และ 'Cost per unit' เป็น object ไม่ใช่ float
retail_no_emp_row.info()

# เอาไว้สังเกตอีกรอบว่าใน 'Volume' และ 'Cost per unit' มีแถวที่มี Text ไม่ใช่ตัวเลขกี่ตัว
retail_no_emp_row.apply(lambda data: pd.to_numeric(data, errors='coerce').notnull().sum())

# เข้าไปดูภายในว่าแถวไหนที่มี Text ที่ไม่ใช่ตัวเลขปะปนมา
retail_no_emp_row[retail_no_emp_row['Volume'].str.replace(r'.', '', regex=False).str.contains(r'\D', regex=True)]
retail_no_emp_row[retail_no_emp_row['Cost per unit'].str.replace(r'.', '', regex=False).str.contains(r'\D', regex=True)]

# แก้ไขข้อมูล
retail_no_emp_row.loc[288, 'Volume'] = 90

# ส่วนแถวอื่นที่มีเครื่องหมาย ( ` ) นั้นทำการ drop ทิ้งไป 
retail_no_emp_row = retail_no_emp_row.drop([138, 3634], axis = 0)
 
 
# แปลง Daty Type ของคอลัมน์ 'Volume' และ 'Cost per unit' ให้เป็น numeric
# สร้างตัวแปรใหม่มารับ ชื่อ retail_correct_dtype
retail_correct_dtype = retail_no_emp_row.astype({'Volume': float, 'Cost per unit' : float})
 
 
# หลังจากที่เราลบแถวไปแล้ว คราวนี้เลข index แถวจะไม่เรียงลำดับกันแล้วให้ทำการ reset index ใหม่
retail_correct_dtype = retail_correct_dtype.reset_index().drop(columns=['index'])


# สร้างตัวแปร เพื่อเอาไว้เก็บ index แถวที่มี Missing Values
retail_no_na = retail_correct_dtype
row_to_show_na = []
 
for column in retail_correct_dtype.columns :
    if retail_correct_dtype[column].isna().sum(axis=0) != 0 :
        blank_row = retail_correct_dtype[retail_correct_dtype[column].isna()].index
        row_to_show_na.extend(list(range(blank_row[0]-2, blank_row[0] + 3)))
 
retail_no_na.iloc[row_to_show_na, ]

# แก้ไขข้อมูล
retail_no_na.loc[7140, 'Product group'] = 'Cosmetics'
retail_no_na.loc[135, 'Producer'] = 'J&F'

# ตรวจสอบข้อมูลอีกครั้ง
retail_no_na.info()




# ---- Step 4 : Duplicated rows ----

# เอาเฉพาะแถวซ้ำขึ้นมาดู
retail_no_na[retail_no_na.astype(str)[list(retail_no_na.columns)].apply("/".join, axis=1).duplicated()]


# ทำการ Slice ให้เหลือเฉพาะบรรทัดที่ไม่ duplicated 
retail_no_dup = retail_no_na[retail_no_na.astype(str)[list(retail_no_na.columns)].apply("/".join, axis=1).duplicated() == False]

 
 

# ---- Step 5 : Whitspace & misspelling ----

# ตรวจสอบคอลัมน์ Producer
retail_no_dup.value_counts('Producer')

# เรียกเฉพาะกรณี WC Net ขึ้นมาดู
retail_no_dup[retail_no_dup['Producer'].str.contains('WC')].value_counts('Producer')

# ทำการสร้างตัวแปรใหม่ชื่อว่า retail_clean มาเก็บเอาไว้ก่อน
retail_clean = retail_no_dup
 
 
# ทำการลบ white space ด้วย .str.strip() method จาก pandas
retail_clean['Producer'] = retail_clean['Producer'].str.strip()
 
 
# จากนั้นเรียกว่าคำที่มี WC ขึ้นมาดูอีกรอบ
retail_clean[retail_clean['Producer'].str.contains('WC')].value_counts('Producer')

# แก้คำผิดของคำว่า Corny
retail_clean['Producer'] = retail_clean['Producer'].str.replace('Cor .*', 'Corny', regex = True)
 
 
# แก้ไขคำว่า Saphora โดยลองเขียน Code อีกแบบ
# แทนการใช้ str.replace()
retail_clean['Producer'][retail_clean['Producer']=='Saphora'] = 'Sephora'




# ---- Step 6 : Export .csv file ----
retail_clean.to_csv('retail_sales_data_(clean-by-Python).csv')