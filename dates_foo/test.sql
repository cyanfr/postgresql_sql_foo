select	aaa.*,
	PERIOD_OF_YEAR =
		case
		when WEEK_OF_YEAR < 5	then 1
		when WEEK_OF_YEAR < 9	then 2
		when WEEK_OF_YEAR < 14	then 3
		when WEEK_OF_YEAR < 18	then 4
		when WEEK_OF_YEAR < 22	then 5
		when WEEK_OF_YEAR < 27	then 6
		when WEEK_OF_YEAR < 31	then 7
		when WEEK_OF_YEAR < 35	then 8
		when WEEK_OF_YEAR < 40	then 9
		when WEEK_OF_YEAR < 44	then 10
		when WEEK_OF_YEAR < 48	then 11
		else 12 end,
	FY_PERIOD_START =
		dateadd(dd,
		case
		when WEEK_OF_YEAR < 5	then 0
		when WEEK_OF_YEAR < 9	then 4
		when WEEK_OF_YEAR < 14	then 8
		when WEEK_OF_YEAR < 18	then 13
		when WEEK_OF_YEAR < 22	then 17
		when WEEK_OF_YEAR < 27	then 21
		when WEEK_OF_YEAR < 31	then 26
		when WEEK_OF_YEAR < 35	then 30
		when WEEK_OF_YEAR < 40	then 34
		when WEEK_OF_YEAR < 44	then 39
		when WEEK_OF_YEAR < 48	then 43
		else 47 end*7,FY_START),
	FY_PERIOD_END =
		case
		when WEEK_OF_YEAR >= 48 then FY_END
		else
			dateadd(dd,(
			case
			when WEEK_OF_YEAR < 5	then 4
			when WEEK_OF_YEAR < 9	then 8
			when WEEK_OF_YEAR < 14	then 13
			when WEEK_OF_YEAR < 18	then 17
			when WEEK_OF_YEAR < 22	then 21
			when WEEK_OF_YEAR < 27	then 26
			when WEEK_OF_YEAR < 31	then 30
			when WEEK_OF_YEAR < 35	then 34
			when WEEK_OF_YEAR < 40	then 39
			when WEEK_OF_YEAR < 44	then 43
			else 48 end*7)-1,FY_START)
		end,
	FY_WEEK_START	= dateadd(dd,(WEEK_OF_YEAR-1)*7,FY_START),
	FY_WEEK_END	= 
		case
		when dateadd(dd,((WEEK_OF_YEAR-1)*7)+6,FY_START) > FY_END
		then FY_END
		else dateadd(dd,((WEEK_OF_YEAR-1)*7)+6,FY_START)
		end
from
(
Select	aaaa.*,
	WEEK_OF_YEAR = ((DAY_OF_FY-1)/7)+1
from
(
select	aaaaa.*,
	DAY_OF_FY = datediff(dd,FY_START,DATE)+1 
from
(
select	DATE = dateadd(dd,datediff(dd,0,b.date),0),
	FY_START = dateadd(yy,datediff(yy,0,b.date),0),
	FY_END = dateadd(yy,datediff(yy,-1,b.date),-1)
from
	(
	select
		-- Generate test data to give one year of output
		DATE =dateadd(dd,number,'20070101')
	from
		-- Function available on this link
		-- http://www.sqlteam.com/forums/topic.asp?TOPIC_ID=47685
		F_TABLE_NUMBER_RANGE(0,366) ) b
) aaaaa ) aaaa ) aaa