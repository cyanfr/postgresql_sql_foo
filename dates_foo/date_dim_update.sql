-- this script requires a table public.federal_holidays.
-- see ddl.public.federal_holidays.sql for an example ddl and inserts

-- also see lines 209 and 210.  Replace <VARIABLE> on each line with an integer.

drop table if exists public.date_dim;

create temp table date_dim_additions
as
select
to_char(j.full_dt,'YYYYMMDD')::int4 as date_key  -- integer not null,  date as 8 digits in format YYYYMMDD
, j.full_dt  -- date,
, (j.full_dt - interval '1 day')::date as prev_full_dt  -- date,
, (j.full_dt - interval '7 days')::date as prev_7_full_dt  -- date,
, (j.full_dt - interval '30 days')::date as prev_30_full_dt  -- date,
, (j.full_dt - interval '60 days')::date as prev_60_full_dt  -- date,
, (j.full_dt - interval '90 days')::date as prev_90_full_dt  -- date,
, (j.full_dt - interval '120 days')::date as prev_120_full_dt  -- date,
, to_char(j.full_dt,'Day')::varchar(10) as day_of_week_name  -- character varying(10),
, to_char(j.full_dt,'ID')::int2 as day_of_week_mo_su_num  -- smallint,
, to_char(j.full_dt,'D')::int2 as day_of_week_su_sa_num  -- smallint,
, to_char(j.full_dt,'DD')::int2 as day_of_month_num  -- smallint,
, to_char(j.full_dt,'DDD')::int2 as day_of_year_num  -- smallint,
, (7 - to_char(j.full_dt,'D')::int2) as days_left_in_week  -- smallint,
, (to_char(((date_trunc('month',j.full_dt) + interval '1 month') - interval '1 day'),'DD')::int2) 
  - (to_char(j.full_dt,'DD')::int2) as days_left_in_month  -- smallint,
, (to_char(((date_trunc('year',j.full_dt) + interval '1 year') - interval '1 day'),'DDD')::int2) 
  - (to_char(j.full_dt,'DDD')::int2) as days_left_in_year  -- smallint,
, (case when f.holiday_date is null
   and to_char(j.full_dt,'D')::int2 not in (1,7)
   then 'Y' else 'N' end)::varchar(1) as fed_business_day_fl  -- character(1),
, (case when f.holiday_date is null 
   then 'N' else 'Y' end)::varchar(1) as fed_holiday_fl  -- character(1),
-- WILL BE POPULATED IN NEXT STEP
-- XXXXXXXXXXXXXXXXXXXXX
, null::int4 as fed_business_day_num  -- integer,
, null::int4 as prev_fed_business_day_num  -- integer,
-- XXXXXXXXXXXXXXXXXXXXX
, (case when j.full_dt = ((date_trunc('month',j.full_dt) + interval '1 month') - interval '1 day') 
        then 'Y' else 'N' end)::varchar(1) as last_day_of_month_fl  -- character(1),
-- WILL BE POPULATED IN NEXT STEP
-- XXXXXXXXXXXXXXXXXXXXX
, null::date as fed_next_biz_full_dt  -- date,
, null::date as fed_prev_biz_full_dt  -- date,
-- XXXXXXXXXXXXXXXXXXXXX
, (extract(epoch from (j.full_dt::timestamp without time zone - '1970-01-01 00:00:00'))::int8)/60/60/24 as unix_days  -- integer,
, extract(epoch from (j.full_dt::timestamp without time zone - '1970-01-01 00:00:00'))::int8 as unix_start_secs  -- bigint,
, (extract(epoch from (j.full_dt::timestamp without time zone - '1970-01-01 00:00:00'))::int8 - 1) as unix_end_secs  -- bigint,
, (case when to_char(j.full_dt,'D')::int2 in (1,7) then 'N' else 'Y' end)::varchar(1) as weekday_fl  -- character(1),
-- WEEK_SU_SA_ID
, (to_char(j.full_dt,'YYYY')||
  lpad((ceiling(((to_char(j.full_dt,'DDD')::numeric)
  +((to_char(date_trunc('year',j.full_dt),'D')::numeric)-1))/7))::varchar,2,'0'))::int4 as week_su_sa_id  -- integer,
-- WEEK_IN_YEAR_SU_SA_NUM
, (ceiling(((to_char(j.full_dt,'DDD')::numeric)
  +((to_char(date_trunc('year',j.full_dt),'D')::numeric)-1))/7))::int4 as week_in_year_su_sa_num  -- smallint,
-- PREV_WEEK_IN_YEAR_SU_SA_NUM
, (ceiling(((to_char((j.full_dt - interval '7 days'),'DDD')::numeric)
  +((to_char(date_trunc('year',(j.full_dt - interval '7 days')),'D')::numeric)-1))/7))::int4 as prev_week_in_year_su_sa_num  -- smallint,
-- WEEK_SU_SA_START_DT
, (case when to_char(j.full_dt,'D')::int2 = 1
       then j.full_dt
       else (date_trunc('week',j.full_dt) - interval '1 day')::date
       end) as week_su_sa_start_dt  -- date,
-- WEEK_SU_SA_END_DT
, case when to_char(j.full_dt,'D')::int2 = 1
       then (j.full_dt + interval '6 days')::date
       when to_char(j.full_dt,'D')::int2 = 7
       then j.full_dt
       else ((j.full_dt) + interval '1 day'*(7-to_char(j.full_dt,'D')::int2))::date
       end as week_su_sa_end_dt  -- date,
-- WEEK_MO_SU_ID
, (to_char(j.full_dt,'YYYY')||
  case when to_char(date_trunc('year',j.full_dt),'D')::int2 = 1
  then lpad((ceiling(((to_char(j.full_dt,'DDD')::numeric)+((to_char(date_trunc('year',j.full_dt),'D')::numeric)+5))/7))::varchar,2,'0')
  else lpad((ceiling(((to_char(j.full_dt,'DDD')::numeric)+((to_char(date_trunc('year',j.full_dt),'D')::numeric)-2))/7))::varchar,2,'0')
  end)::int4 as week_mo_su_id  -- integer,
-- WEEK_IN_MONTH_MO_SU_NUM
, (case when to_char(date_trunc('month',j.full_dt),'D')::int2 = 1
  then (ceiling(((to_char(j.full_dt,'DD')::numeric)+(to_char(date_trunc('month',j.full_dt),'D')::numeric)+5)/7))
  else (ceiling(((to_char(j.full_dt,'DD')::numeric)+(to_char(date_trunc('month',j.full_dt),'D')::numeric)-2)/7))
  end)::int2 as week_in_month_mo_su_num  -- smallint,
-- PREV_WEEK_IN_MONTH_MO_SU_NUM
, (case when to_char(date_trunc('month',(j.full_dt - interval '7 days')::date),'D')::int2 = 1
  then (ceiling(((to_char((j.full_dt - interval '7 days')::date,'DD')::numeric)+(to_char(date_trunc('month',(j.full_dt - interval '7 days')::date),'D')::numeric)+5)/7))
  else (ceiling(((to_char((j.full_dt - interval '7 days')::date,'DD')::numeric)+(to_char(date_trunc('month',(j.full_dt - interval '7 days')::date),'D')::numeric)-2)/7))
  end)::int2 as prev_week_in_month_mo_su_num  -- smallint,      
-- WEEK_IN_YEAR_MO_SU_NUM
, (case when to_char(date_trunc('year',j.full_dt),'D')::int2 = 1
  then (ceiling(((to_char(j.full_dt,'DDD')::numeric)+((to_char(date_trunc('year',j.full_dt),'D')::numeric)+5))/7))
  else (ceiling(((to_char(j.full_dt,'DDD')::numeric)+((to_char(date_trunc('year',j.full_dt),'D')::numeric)-2))/7))
  end)::int2 as week_in_year_mo_su_num  -- smallint,
-- PREV_WEEK_IN_YEAR_MO_SU_NUM
, (case when to_char(date_trunc('year',(j.full_dt - interval '7 days')),'D')::int2 = 1
  then (ceiling(((to_char((j.full_dt - interval '7 days'),'DDD')::numeric)+((to_char(date_trunc('year',(j.full_dt - interval '7 days')),'D')::numeric)+5))/7))
  else (ceiling(((to_char((j.full_dt - interval '7 days'),'DDD')::numeric)+((to_char(date_trunc('year',(j.full_dt - interval '7 days')),'D')::numeric)-2))/7))
  end)::int2 as prev_week_in_year_mo_su_num  -- smallint,
-- WEEK_MO_SU_START_DT
, date_trunc('week',j.full_dt)::date as week_mo_su_start_dt  -- date,
-- WEEK_MO_SU_END_DT
, (date_trunc('week',j.full_dt) + interval '6 days')::date as week_mo_su_end_dt  -- date,
-- month_id is 4 digit year and 2 digit month in format YYYYMM
, to_char(j.full_dt,'YYYYMM')::int4 as month_id  -- integer,
, to_char((j.full_dt - interval '1 month'),'YYYYMM')::int4 as prev_month_id  -- integer,
, to_char((j.full_dt - interval '3 months'),'YYYYMM')::int4 as prev_three_month_id  -- integer,
, to_char((j.full_dt - interval '6 months'),'YYYYMM')::int4 as prev_six_month_id  -- integer,
, to_char((j.full_dt - interval '9 months'),'YYYYMM')::int4 as prev_nine_month_id  -- integer,
, to_char((j.full_dt - interval '12 months'),'YYYYMM')::int4 as prev_twelve_month_id  -- integer,
-- date for first day of month
, date_trunc('month',j.full_dt)::date as month_dt  -- date,
-- date for last day of month
, ((date_trunc('month',j.full_dt) + interval '1 month') - interval '1 day')::date as month_end_dt  -- date,
-- date for LAST day of month 1 month ago
, (date_trunc('month',j.full_dt) - interval '1 day')::date as ldom_01_back_dt  -- date,
-- date for LAST day of month 3 month ago
, ((date_trunc('month',j.full_dt) - interval '2 months') - interval '1 day')::date as ldom_03_back_dt  -- date,
-- date for LAST day of month 6 month ago
, ((date_trunc('month',j.full_dt) - interval '5 months') - interval '1 day')::date as ldom_06_back_dt  -- date,
-- date for LAST day of month 12 month ago
, ((date_trunc('month',j.full_dt) - interval '11 months') - interval '1 day')::date as ldom_12_back_dt  -- date,
-- Just the month name
, to_char(j.full_dt,'Month')::varchar(10) as month_name  -- character varying(10),
-- Month label in form Mmm-YY
, ((to_char(j.full_dt,'Mon')||'-'||to_char(j.full_dt,'YY')))::varchar(200) as month_full_short_name  -- character varying(200),
-- Month label in form YYYY Month
, (to_char(j.full_dt,'YYYY')||' '||to_char(j.full_dt,'Month'))::varchar(200) as month_full_long_name  -- character varying(200),
-- number of month 1 to 12
, to_char(j.full_dt,'MM')::int2 as month_num  -- smallint,
-- number of previous month
, to_char((date_trunc('month',j.full_dt) - interval '1 day'), 'MM')::int2 as prev_month_num  -- smallint,
, (to_char(((date_trunc('month',j.full_dt) + interval '1 month') - interval '1 day'),'DD')::int2) as number_of_days_in_month  -- smallint,
-- quarter id in form YYYYQ
, (to_char(j.full_dt,'YYYY')||to_char(j.full_dt,'Q'))::int4 as quarter_id  -- integer,
-- just number of quarter 1 to 4.
, to_char(j.full_dt,'Q')::int2 as quarter_num  -- smallint,
, (to_char(j.full_dt,'Q')::int2 - 1) as prev_quarter_num  -- smallint,
-- label of quarter in form YYYY Q#. eg 2016 Q1
, ((to_char(j.full_dt,'YYYY')||' Q'||to_char(j.full_dt,'Q')))::varchar(26) as quarter_full_name  -- character varying(26),
, (EXTRACT(EPOCH FROM ((date_trunc('quarter',j.full_dt) + interval '3 months')
                       - date_trunc('quarter',j.full_dt)))/60/60/24)::int2 as number_of_days_in_quarter  -- smallint,
, to_char(j.full_dt,'YYYY')::integer as year  -- integer,
, (to_char(j.full_dt,'YYYY')::integer - 1) as prev_year  -- integer,
-- WILL BE POPULATED IN NEXT STEP
-- XXXXXXXXXXXXXXXXXXXXX
-- Integer representing total number of federal stays since inception at start of year.
, null::int4 as fed_business_day_soy  -- integer,
-- -- Integer representing total number of federal stays since inception at end of year.
, null::int4 as fed_business_day_eoy  -- integer,
-- XXXXXXXXXXXXXXXXXXXXX
-- date for first day of year
, date_trunc('year',j.full_dt)::date as year_start_dt  -- date,
-- date for last day of year
, ((date_trunc('year',j.full_dt) + interval '1 year') - interval '1 day')::date as year_end_dt  -- date,
, to_char(((date_trunc('year',j.full_dt) + interval '1 year') - interval '1 day'),'DDD')::int2 as number_of_days_in_year  -- smallint
-- comment out line 158 and uncomment line 156 to create the table with 5 years of data starting with Jan 1, 2016 and going through end of year 2020.
--from (select (generate_series('2016-01-01', (('2016-01-01'::date + interval '5 years') - interval '1 day'), '1 day'::interval))::date as full_dt) j
-- to change the date ranges created in this table, change the start enad end dates in the line below.
from (select (generate_series('2016-01-01', '2017-12-31', '1 day'::interval))::date as full_dt) j
left join public.federal_holidays f
on j.full_dt = f.holiday_date;

create temp table date_dim_windows
as
select
y.full_dt
, y.year
, y.day_of_year_num
, y.day_of_week_name
, y.fed_business_day_fl
, y.fed_business_day_num
, y.prev_fed_business_day_num
-- FED_NEXT_BIZ_FULL_DT
, (case when y.fed_business_day_fl = 'Y' and y.fed_next_biz_day_set_row_num = 1 
  then y.full_dt + interval '1 day'*((lead(y.fed_next_biz_day_set_row_num) over (order by full_dt))+1)
  when y.fed_business_day_fl = 'Y' and y.fed_next_biz_day_set_row_num > 1
  then (y.full_dt + interval '1 day')::date
  else (y.full_dt + interval '1 day'*y.fed_next_biz_day_set_row_num)
  end)::date as fed_next_biz_full_dt
-- FED_PREV_BIZ_FULL_DT
, (case when y.fed_business_day_fl = 'Y' and y.fed_prev_biz_day_set_row_num = 1 
  then y.full_dt - interval '1 day'*((lag(y.fed_prev_biz_day_set_row_num) over (order by full_dt))+1)
  when y.fed_business_day_fl = 'Y' and y.fed_prev_biz_day_set_row_num > 1
  then (y.full_dt - interval '1 day')::date
  else (y.full_dt - interval '1 day'*y.fed_prev_biz_day_set_row_num)
  end)::date as fed_prev_biz_full_dt
, y.fed_business_day_soy
, y.fed_business_day_eoy
from (
select
x.full_dt
, x.year
, x.day_of_year_num
, x.day_of_week_name
, x.fed_business_day_fl
, x.fed_business_day_num
, x.prev_fed_business_day_num
, row_number() over (partition by x.fed_biz_day_set_num order by x.full_dt desc) as fed_next_biz_day_set_row_num
, row_number() over (partition by x.fed_biz_day_set_num order by x.full_dt) as fed_prev_biz_day_set_row_num
, first_value(x.fed_business_day_num) over (partition by x.year order by x.full_dt RANGE BETWEEN
           UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as fed_business_day_soy
, last_value(x.fed_business_day_num) over (partition by x.year order by x.full_dt RANGE BETWEEN
           UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as fed_business_day_eoy
from (
select d.full_dt
, d.year
, to_char(d.full_dt,'DDD')::int2 as day_of_year_num
, d.day_of_week_name
, d.fed_business_day_fl
, (<VARIABLE> + (sum(case when fed_business_day_fl = 'Y' then 1::int4 else 0::int4 end) over (order by full_dt)))::int4 as fed_business_day_num
, (<VARIABLE> + (sum(case when fed_business_day_fl = 'Y' then 1::int4 else 0::int4 end) over (order by full_dt))-1)::int4 as prev_fed_business_day_num
, case when d.fed_business_day_fl = 'Y' then
  'Y'||((sum(case when fed_business_day_fl = 'N' then 1::int4 else 0::int4 end) over (order by full_dt)))
   else 'N'||((sum(case when fed_business_day_fl = 'Y' then 1::int4 else 0::int4 end) over (order by full_dt)))
   end as fed_biz_day_set_num
from date_dim_additions d
) x
order by x.full_dt
) y;

create table public.date_dim
as
select 
a.date_key
, a.full_dt
, a.prev_full_dt
, a.prev_7_full_dt
, a.prev_30_full_dt
, a.prev_60_full_dt
, a.prev_90_full_dt
, a.prev_120_full_dt
, a.day_of_week_name
, a.day_of_week_mo_su_num
, a.day_of_week_su_sa_num
, a.day_of_month_num
, a.day_of_year_num
, a.days_left_in_week
, a.days_left_in_month
, a.days_left_in_year
, a.fed_business_day_fl
, a.fed_holiday_fl
, b.fed_business_day_num
, b.prev_fed_business_day_num
, a.last_day_of_month_fl
, b.fed_next_biz_full_dt
, b.fed_prev_biz_full_dt
, a.unix_days
, a.unix_start_secs
, a.unix_end_secs
, a.weekday_fl
, a.week_su_sa_id
, a.week_in_year_su_sa_num
, a.prev_week_in_year_su_sa_num
, a.week_su_sa_start_dt
, a.week_su_sa_end_dt
, a.week_mo_su_id
, a.week_in_month_mo_su_num
, a.prev_week_in_month_mo_su_num
, a.week_in_year_mo_su_num
, a.prev_week_in_year_mo_su_num
, a.week_mo_su_start_dt
, a.week_mo_su_end_dt
, a.month_id
, a.prev_month_id
, a.prev_three_month_id
, a.prev_six_month_id
, a.prev_nine_month_id
, a.prev_twelve_month_id
, a.month_dt
, a.month_end_dt
, a.ldom_01_back_dt
, a.ldom_03_back_dt
, a.ldom_06_back_dt
, a.ldom_12_back_dt
, a.month_name
, a.month_full_short_name
, a.month_full_long_name
, a.month_num
, a.prev_month_num
, a.number_of_days_in_month
, a.quarter_id
, a.quarter_num
, a.prev_quarter_num
, a.quarter_full_name
, a.number_of_days_in_quarter
, a.year
, a.prev_year
, b.fed_business_day_soy
, b.fed_business_day_eoy
, a.year_start_dt
, a.year_end_dt
, a.number_of_days_in_year
from date_dim_additions a
left join date_dim_windows b
on a.full_dt = b.full_dt;