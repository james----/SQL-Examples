/* 

Example of dynamical SQL appending pattern to output row count of more than one table in a table

*/
set nocount on

-- value @sql must be initalized or appending will not work

declare @sql varchar(max) = ''
;

drop table if exists #RowCounts

select
	name	= convert (varchar(max), '')
	,Count	= 0
into
	#RowCounts

delete from
#RowCounts
;

with objectName
as
	(select
		concat (schema_name (v.schema_id), '.', name) name
	from
		sys.all_views v
	where
		schema_name (v.schema_id) = 'sys')

-- Valid line endings are carriage return, semicolon or both
select	top 10
		@sql	= @sql + concat ('insert into #RowCounts (name,count) select ', quotename (o.name, ''''), ',count(1)', ' from ', name, ';', char (10))
from
		objectName o
order by
		o.name

--print @sql

exec (@sql)

select
	*
from
	#RowCounts