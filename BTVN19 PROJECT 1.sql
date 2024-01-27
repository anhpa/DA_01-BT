--1) Chuyển đổi kiểu dữ liệu phù hợp cho các trường ( sử dụng câu lệnh ALTER)
select * from public.sales_dataset_rfm_prj
ALTER TABLE public.sales_dataset_rfm_prj ALTER COLUMN ordernumber TYPE integer USING (ordernumber::integer),
ALTER TABLE public.sales_dataset_rfm_prj ALTER COLUMN quantityordered TYPE integer USING (quantityordered::integer),
ALTER TABLE public.sales_dataset_rfm_prj ALTER COLUMN orderlinenumber TYPE integer USING (orderlinenumber::integer),
ALTER TABLE public.sales_dataset_rfm_prj ALTER COLUMN sales TYPE numeric USING (sales::numeric),
ALTER TABLE public.sales_dataset_rfm_prj ALTER COLUMN msrp TYPE numeric USING (msrp::numeric),
ALTER TABLE public.sales_dataset_rfm_prj ALTER COLUMN orderdate TYPE date USING (orderdate::date)

--2) Check NULL/BLANK (‘’)  ở các trường: ORDERNUMBER, QUANTITYORDERED, PRICEEACH, ORDERLINENUMBER, SALES, ORDERDATE.
select count (*) from public.sales_dataset_rfm_prj
where ordernumber is null or 
quantityordered is null or 
priceeach is null or 
orderlinenumber is null or 
sales is null or 
orderdate is null

--3)Thêm cột CONTACTLASTNAME, CONTACTFIRSTNAME được tách ra từ CONTACTFULLNAME . 
--Chuẩn hóa CONTACTLASTNAME, CONTACTFIRSTNAME theo định dạng chữ cái đầu tiên viết hoa, chữ cái tiếp theo viết thường. 
alter table public.sales_dataset_rfm_prj
add column contact_lastname varchar(50);
alter table public.sales_dataset_rfm_prj
add column contact_firstname varchar(50);

UPDATE public.sales_dataset_rfm_prj
SET CONTACT_FIRSTNAME=(upper(left(contactfullname,1))||substring(contactfullname from 2 for POSITION ( '-' IN contactfullname)-2));
UPDATE public.sales_dataset_rfm_prj
SET CONTACT_LASTNAME=(upper(substring(contactfullname from POSITION ( '-' IN contactfullname)+1 for 1))||right(contactfullname,POSITION ( ' ' IN contactfullname)-POSITION ( '-' IN contactfullname)-1))

--4)Thêm cột QTR_ID, MONTH_ID, YEAR_ID lần lượt là Qúy, tháng, năm được lấy ra từ ORDERDATE 
alter table public.sales_dataset_rfm_prj
add column QTR_ID integer;
alter table public.sales_dataset_rfm_prj
add column MONTH_ID integer;
alter table public.sales_dataset_rfm_prj
add column YEAR_ID integer;

UPDATE public.sales_dataset_rfm_prj
set qtr_id= (extract(quarter from orderdate))
UPDATE public.sales_dataset_rfm_prj
set year_id= (extract(year from orderdate))
UPDATE public.sales_dataset_rfm_prj
set month_id= (extract(month from orderdate))

--5)Hãy tìm outlier (nếu có) cho cột QUANTITYORDERED và hãy chọn cách xử lý cho bản ghi đó (2 cách) ( Không chạy câu lệnh trước khi bài được review)

--Cách 1 : BOX PLOT
with twt_min_max_value as (
select Q1-1.5*IQR as min_value,
Q3+1.5*IQR as max_value
from (
select 
percentile_cont(0.25) within group (order by quantityordered) as Q1,
percentile_cont(0.75) within group (order by quantityordered) as Q3,
percentile_cont(0.75) within group (order by quantityordered)-percentile_cont(0.25) within group (order by quantityordered) as IQR
 from public.sales_dataset_rfm_prj) as a1)
select ordernumber,quantityordered from public.sales_dataset_rfm_prj
where quantityordered< (select min_value from twt_min_max_value) or
quantityordered>(select max_value from twt_min_max_value)

--Cách 2: z-Score
with cte as 
(select ordernumber, quantityordered,
(select avg(quantityordered) from public.sales_dataset_rfm_prj) as avg, 
 (select stddev(quantityordered)from public.sales_dataset_rfm_prj) as stddev
 from public.sales_dataset_rfm_prj)
 
 select ordernumber,quantityordered,(quantityordered-avg)/stddev as z_score
 from cte
 where abs((quantityordered-avg)/stddev)>3.5



