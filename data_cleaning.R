# ---- Step 1 : Import data ----

library(tidyverse)

# เก็บ Data เอาไว้อยู่ในตัวแปรที่ชื่อ retail
retail <- read_csv("https://raw.githubusercontent.com/attasithp/sales_data_of_different-channels_excel-R-python/main/retail_sales_data%20(raw).csv") 




# ---- Step 2 : Empty rows ----

# เริ่มจากเอาหน้าตา Empty row ขึ้นมาดูก่อน
retail[rowSums(is.na(retail)) == ncol(retail), ]

# ฉะนั้นเราจะเลือกเอาแถวที่เป็น Empty Rows ออก
retail_no_emp_row <- retail[rowSums(is.na(retail)) != ncol(retail), ] 




# ---- Step 3 : Data type error & Missing Values ----

# Note : สำหรับ R นั้นเราไม่สามารถเชค Data type อะไรได้ เนื่องจากข้อมูลถูก drop ทิ้งไปแล้ว

# ตรวจสอบว่าคอลัมน์ไหนมี data type เป็น numeric
retail_no_emp_row %>% map(~sum(is.numeric(.)))

# ตรวจสอบว่าคอลัมน์ไหนมี data type เป็น character
retail_no_emp_row %>% map(~sum(is.character(.)))

# Check จำนวน Missing Values ในแต่ละคอลัมน์
retail_no_emp_row %>% map(~sum(is.na(.)))


# เนื่องจาก R ไม่เหมือน Python ที่จะมี index ของแถวมาให้ เราจึงต้องสร้างเอง
# เพื่อให้เราสามารถเห็นแถวที่มี Missing Values ได้ว่าแถวที่เท่าไร
# ด้วยการสร้างตัวแปรใหม่ที่ชื่อ retail_index ขึ้นมาเก็บ
 
retail_index <- retail_no_emp_row %>% mutate(index = row_number()) %>% 
                select(index, everything())
 
 
 
for(column in colnames(retail_index)){
 
   # สร้างตัวแปร เพื่อเอาไว้เก็บ index แถวที่มี Missing Values
    row_with_na <- (retail_index %>% filter(is.na(eval(as.name(column)))))$index
  
   # Run เสร็จแล้วช่วยแจ้งด้วยว่าอยู่แถวไหน
    cat("For row number of Missing Values in ", column, " column \r\n", sep = "")
    print(row_with_na)
 
   # จากนั้นก็ทำการเรียกแถวที่มี Missing Values และแถวรอบๆ ขึ้นมาดู
    for(row in row_with_na){
        cat("from ", column, " column.", sep = "")
        print(retail_index[ seq(row-3, row+3, 1), ])
    }
}


retail_no_na <- retail_index %>% 
                drop_na(c("Volume", "Cost per unit"))

# Product Group อยู่แถวที่ 7143 ควรจะแทนค่าด้วย "Cosmetics"
# Producer อยู่แถวที่ 136 ควรจะแทนค่าด้วย "J&F"

retail_index[7143, "Product group"] <- "Cosmetics"
retail_index[136, "Producer"] <- "J&F"




# ---- Step 4 : Duplicated rows ----

# จัดการกับ Duplicated Row
retail_together <- retail_no_na %>% select(-index) %>% unite(together, 1:ncol(.), sep=",")

# ดูว่าแถวไหน Duplicated
retail_no_na[duplicated(retail_together), ]
retail_index[c(3470,3471,3596, 3597, 4106, 4107), ]

# เอา Duplicated ออก
retail_no_dup <- retail_no_na[!duplicated(retail_together), ] 




# ---- Step 5 : Whitspace & misspelling ----
  
# สร้างตัวแปรใหม่ เพราะเราสามารถเอา Indexing column ออกได้แล้ว
retail_clean <- retail_no_dup %>% select(-index)
retail_clean %>% count(`Producer`) 
retail_clean %>% count(`Producer`) %>% count()

# Clean Double White space ที่อยู่ตรงกลางคำ ครั้งที่ 1
retail_clean$`Producer` <- str_squish(retail_clean$`Producer`)

# String Replace เพื่อแก้ไขคำอีกครั้ง เป็นอันเสร็จ
retail_clean$Producer <- str_replace(retail_clean $Producer, "Cor .*", "Corny")

# สำหรับคำว่า Saphora นั้นเราก็จะแทนค่าแก้คำให้เรียบร้อย
# โดยใช้ str_replace() เช่นเดียวกัน
retail_clean$Producer <- str_replace(retail_clean $Producer, "Saphora", "Sephora")




# ---- Step 6 : Export .csv file ----
  
# Write .csv ออกได้เลย
retail_clean %>% write_csv("retail_sales_data_(clean-by-R).csv")

