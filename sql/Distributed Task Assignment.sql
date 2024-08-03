
/*
Two tables one with staff and one with tasks related by staffID. 
Update the tasks table distribute the staff evenly by the create 
date so that each staff person has their assigned tasks spread 
evenly across the entire date range from oldest to newest task.
*/

drop table if exists eTasks
drop table if exists eStaff

create table [dbo].[eStaff]
(
	[StaffID] [int] identity(1, 1) not null
	,[Name] [varchar](256) null
	,constraint [PK_eStaff]
		primary key clustered ([StaffID] asc)
		with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY]
) on [PRIMARY]
go

create table [dbo].[eTasks]
(
	[TaskID] [int] identity(1, 1) not null
	,[StaffID] [int] not null
	,[Title] [varchar](256) not null
	,[Description] [varchar](max) null
	,[createdate] [datetime] not null
	,constraint [PK_eTasks]
		primary key clustered ([TaskID] asc)
		with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY]
) on [PRIMARY] textimage_on [PRIMARY]
go

set ansi_padding off
go

alter table [dbo].[eTasks] with check
add
constraint	[FK_eTasks_eStaff]
	foreign key ([StaffID])
	references [dbo].[eStaff] ([StaffID])
go

alter table [dbo].[eTasks] check constraint [FK_eTasks_eStaff]

-- Populate Test Data

insert into eStaff
	(
		Name
	)
values
	(
		'Abigail'
	)
	,(
		'Beatrice'
	)
	,(
		'Cindy'
	)
	,(
		'Doris'
	)
go

-- Generate N tasks for testing

declare @TotalTask int = 503

insert into eTasks
	(
		StaffID
		,Title
		,createdate
	)
			select
				(
					select top 1 StaffID from eStaff
				)
				,concat_ws (' ', 'Task ', n)
				,getdate () - n
			from
				(
					select	top (@TotalTask)
							row_number () over (order by [object_id]) n
					from
							sys.all_columns
					order by
							[object_id]
				) rows
;

select
	concat_ws (' '
			,'Total'
			,':'
			,(
					select count (1) from dbo.eStaff
				)
			) Staff

select
	*
from
	eStaff

select
	concat_ws (' '
			,'Total'
			,':'
			,(
					select count (1) from dbo.eTasks
				)
			) Tasks

select
	*
from
	eTasks

declare @totalStaff int

select
	@totalStaff = count (1)
from
	eStaff

-- Allocate staff to tasks...

update
	t
set
StaffID = s.StaffID
from
	(
		select	(row_number () over (order by t.createdate) % @totalStaff) + 1 StaffKey
				,*
		from
				eTasks t
	)	t
	cross apply
	(
		select
			*
		from
			(
				select
					row_number () over (order by s.StaffID) StaffKey
					,*
				from
					eStaff s
			) s
		where
			t.StaffKey = s.StaffKey
	)	s

-- Show aggregate results

select
	'' [Tasks spread evenly across the entire date range from oldest to newest task ]

select
			s.Name
			,count (1)	[Number of Tasks]
			,min (createdate) Oldest
			,max (createdate) Newest
from
			eTasks	t
	join	eStaff	s on s.StaffID = t.StaffID
group by
			s.Name