--Create Tables and insert values

create table booking_table (
 booking_id varchar(10),
 booking_date date,
 user_id varchar(10),
 line_of_business varchar(20)
);

insert into booking_table (booking_id, booking_date, user_id, line_of_business) values
('b1', '2022-03-23', 'u1', 'Flight'),
('b2', '2022-03-27', 'u2', 'Flight'),
('b3', '2022-03-28', 'u1', 'Hotel'),
('b4', '2022-03-31', 'u4', 'Flight'),
('b5', '2022-04-02', 'u1', 'Hotel'),
('b6', '2022-04-02', 'u2', 'Flight'),
('b7', '2022-04-06', 'u5', 'Flight'),
('b8', '2022-04-06', 'u6', 'Hotel'),
('b9', '2022-04-06', 'u2', 'Flight'),
('b10', '2022-04-10', 'u1', 'Flight'),
('b11', '2022-04-12', 'u4', 'Flight'),
('b12', '2022-04-16', 'u1', 'Flight'),
('b13', '2022-04-19', 'u2', 'Flight'),
('b14', '2022-04-20', 'u5', 'Hotel'),
('b15', '2022-04-22', 'u6', 'Flight'),
('b16', '2022-04-26', 'u4', 'Hotel'),
('b17', '2022-04-28', 'u2', 'Hotel'),
('b18', '2022-04-30', 'u1', 'Hotel'),
('b19', '2022-05-04', 'u4', 'Hotel'),
('b20', '2022-05-06', 'u1', 'Flight');

create table user_table (
 user_id varchar(10),
 segment varchar(10)
);

insert into user_table (user_id, segment) values
('u1', 's1'),
('u2', 's1'),
('u3', 's1'),
('u4', 's2'),
('u5', 's2'),
('u6', 's3'),
('u7', 's3'),
('u8', 's3'),
('u9', 's3'),
('u10', 's3');


--Queries
--1. Write an SQL query to show, for each segment, the total number of users and the number of users who booked a flight in April 2022.
select u.segment, count(distinct user_id) as total_users,
	count(distinct case when (b.booking_date between '2022-04-01' and '2022-04-30') and b.line_of_business='Flight' then u.user_id else null end) as total_apr_users
from user_table u
left join booking_table b on u.user_id = b.user_id
group by u.segment


--2. Write a query to identify users whose first booking was a hotel booking.
select user_id
from
(
select user_id, line_of_business,
    row_number() over (partition by user_id order by booking_date) as booking_no
  from booking_table) t
where t.booking_no=1 and t.line_of_business='Hotel'


--3. Write a query to calculate the number of days between the first and last booking of the user with user_id = 1.
select datediff(day, t.min_date, t.max_date)
from
(
select max(booking_date) as max_date,
		min(booking_date) as min_date
from booking_table
where user_id='u1') t


--4. Write a query to count the number of flight and hotel bookings in each user segment for the year 2022.
select u.segment,
count(case when b.line_of_business='Flight' then 1 end) as total_flights,
count(case when b.line_of_business='Hotel' then 1 end) as total_hotels
from user_table u
left join booking_table b
on u.user_id = b.user_id
where b.booking_date between '2022-01-01' and '2022-12-31'
group by u.segment


--5. Find, for each segment, the user who made the earliest booking in April 2022, and also return how many total bookings that user made in April 2022.
with first_users as(
select segment, user_id
from
(
select u.segment, b.user_id,
	row_number() over (partition by u.segment order by b.booking_date) as user_rank
from user_table u
left join booking_table b
on u.user_id = b.user_id
where b.booking_date between '2022-04-01' and '2022-04-30') t
where t.user_rank=1)

select f.segment, f.user_id, count(b.booking_id) as total_bookings
from first_users f
left join booking_table b
on f.user_id = b.user_id
where b.booking_date between '2022-04-01' and '2022-04-30'
group by f.segment, f.user_id



