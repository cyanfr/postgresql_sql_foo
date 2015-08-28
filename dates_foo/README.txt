These scripts will generate a table public.date_dim that contains the fields below.
All expressions are relative to the date found in the full_dt field.
So for example, prev_full_dt is the date 1 day prior to the date found in the full_dt field.

date_key                      -- integer representation of date in form YYYYMMDD
full_dt                       -- just the date
prev_full_dt                  -- previous day's date
prev_7_full_dt                -- date 7 days ago
prev_30_full_dt               -- date 30 days ago
prev_60_full_dt               -- date 60 days ago
prev_90_full_dt               -- date 90 days ago
prev_120_full_dt              -- date 120 days ago
day_of_week_name              -- name of day. e.g. Monday, Tuesday, etc.
day_of_week_mo_su_num         -- number of the day of week (1 to 7) where Monday is 1.
day_of_week_su_sa_num         -- number of the day of week (1 to 7) where Sunday is 1.
day_of_month_num              -- number of the day of the month 1 to 3[0,1]
day_of_year_num               -- number of the day of the year 1 to 36[5,6]
days_left_in_week             -- number of days left in week if week starts on Sunday
days_left_in_month            -- number of days left in month
days_left_in_year             -- number of days left in year
fed_business_day_fl           -- flag (Y/N) for Federal business day
fed_holiday_fl                -- flag (Y/N) for Federal holiday
fed_business_day_num          -- number of Federal business days starting from an arbitrary point.  See notes at top of date_dim_update.sql.
prev_fed_business_day_num     -- number of previous Federal business days starting from an arbitrary point.  See notes at top of date_dim_update.sql.
last_day_of_month_fl          -- flag (Y/N) for last day of month
fed_next_biz_full_dt          -- date of next federal business day
fed_prev_biz_full_dt          -- date of next federal business day
unix_days                     -- integer for unix day
unix_start_secs               -- Int8 of first unix sec of day
unix_end_secs                 -- Int8 of last unix sec of day
weekday_fl                    -- flag (Y/N) indicating Monday to Friday
week_su_sa_id                 -- number id indicating the week of the year if week starts Sunday in format YYYYWW
week_in_year_su_sa_num        -- number of the week (1 to 54) in year if week starts Sunday
prev_week_in_year_su_sa_num   -- same as previous column but prior week
week_su_sa_start_dt           -- date of first day of week if week starts Sunday
week_su_sa_end_dt             -- date of last day of week if week starts Sunday
week_mo_su_id                 -- number id indicating the week of the year if week starts Monday in format YYYYWW
week_in_month_mo_su_num       -- number for week in month if week starts Monday
prev_week_in_month_mo_su_num  -- number for previous week in month if week starts Monday
week_in_year_mo_su_num        -- number for week in year if week starts Monday
prev_week_in_year_mo_su_num   -- number of previous week in year if week starts Monday
week_mo_su_start_dt           -- date of first day of week if week starts Monday
week_mo_su_end_dt             -- date of last day of week if week starts Monday
month_id                      -- number of id for month in format YYYYMM
prev_month_id                 -- number of id for previous month in format YYYYMM
prev_three_month_id           -- number of id for month 3 months ago in format YYYYMM
prev_six_month_id             -- number of id for month 6 months ago in format YYYYMM
prev_nine_month_id            -- number of id for month 9 months ago in format YYYYMM
prev_twelve_month_id          -- number of id for month 12 months ago in format YYYYMM
month_dt                      -- date of first day of month
month_end_dt                  -- date of last day of month
ldom_01_back_dt               -- date of last day of previous month
ldom_03_back_dt               -- date of last day 3 months ago
ldom_06_back_dt               -- date of last day 6 months ago
ldom_12_back_dt               -- date of last day 12 months ago
month_name                    -- name of month. e.g. January, February, etc.
month_full_short_name         -- label for month in format Mmm-YY.  e.g. Jan-16
month_full_long_name          -- label for month in format YYYY Month.  e.g. 2016 January
month_num                     -- number of month 1 to 12
prev_month_num                -- number of previous month 1 to 12
number_of_days_in_month       -- number of days in month
quarter_id                    -- number id for quarter in format YYYYQ.  e.g. 20161, 20162, 20163, 20164
quarter_num                   -- number of quarter 1 to 4
prev_quarter_num              -- number of previous quarter 1 to 4
quarter_full_name             -- label of quarter in format YYYY Q#. e.g. 2016 Q1
number_of_days_in_quarter     -- number of days in quarter
year                          -- number of year in format YYYY
prev_year                     -- number of previous year in format YYYY
fed_business_day_soy          -- number of Federal business day for first day of year starting from an arbitrary point.  See notes at top of date_dim_update.sql.
fed_business_day_eoy          -- number of Federal business day for last day of year starting from an arbitrary point.  See notes at top of date_dim_update.sql.
year_start_dt                 -- date for first day of year
year_end_dt                   -- date for last day of year
number_of_days_in_year        -- number of days in year