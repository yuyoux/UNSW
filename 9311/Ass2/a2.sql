-- Q1: use not like to filter the result
create or replace view Q1(Name, Country) as
select name, Country from Company
where Country NOT liKE 'Australia';

-- Q2: use count()function to get the amount
create or replace view Q2(Code) as
select code from Executive
group by code
having count(person) >= 6;

-- Q3: searching by using two tables by join
create or replace view Q3(Name) as
select c.Name from company c join Category a on(c.Code = a.Code)
where a.sector = 'Technology'
order by a.sector;

-- Q4: use count() and distinct() to avoid the useless results
create or replace view Q4(Sector, Number) as 
select sector, count(distinct(industry)) as "Number"
from Category
group by sector;

-- Q5
create or replace view Q5(Name) as             
select e.Person as Name from Executive e join Category a on(e.Code = a.Code)
where a.sector = 'Technology'
group by e.Person
order by e.Person;

-- Q6: Fuzzy searching by using % and like
create or replace view Q6(Name) as 
select c.Name from Company c join Category a on(c.Code = a.Code)
where a.sector = 'Services' and c.Country = 'Australia' and c.zip like '2%'
group by c.name
order by c.name;

-- Q7: Finding the change and gains by invoking the ASX table twice as a1,a2
-- thus we can easily filter the results by selecting the minimal Date that is
-- bigger than the PrevDate, finishing the task
create or replace view Q7("Date", Code, Volume, PrevPrice, Price, Change, Gain) as
select distinct a2."Date", a1.Code, a2.Volume, a1.Price as PrevPrice, a2.Price as Price, (a2.Price - a1.Price) as Change, (a2.Price - a1.Price)/a1.Price*100 as Gain
from ASX a1, ASX a2
where a2."Date" = (select min("Date") from ASX where "Date" > a1."Date" and Code = a1.Code) and a1.Code = a2.Code
order by "Date";

-- Q8: Finding the maximum trading volume by max()and order by Date and Code
create or replace view Q8("Date", Code, Volume) as
select "Date", Code, Volume
from ASX
where Volume in (select max(Volume) from ASX group by "Date")
order by "Date", Code;

-- Q9: Order by Sector and then Industry
create or replace view Q9(Sector, Industry, Number) as 
select Sector, Industry, count(industry) as "Number"
from Category
group by Sector,Industry
order by Sector,Industry;

-- Q10: Showing companies with no competitors
create or replace view Q10(Code, Industry) as 
select Code, Industry 
from Category
where Industry in (select Industry from Category group by Industry having count(code) = 1);

-- Q11: Invoking the avg() function to rank the results
create or replace view Q11(Sector, AvgRating) as  
select a.Sector, avg(r.Star) as "AvgRating" from Category a join Rating r on(a.Code = r.Code)
group by sector
order by sector;

-- Q12: ie Finding persons whom showed up more than once in this table
create or replace view Q12(Name) as
select person as name
from executive
group by person
having count(person) > 1;

-- Q13: Firstly to create a view QQ13 to list all the companies not in
--Australia and then create the other view Q13 to find the companies in
--sectors that only contains Australian-based companies
create or replace view QQ13(Code, Name, Address, Zip, Sector) as 
select c.Code, c.Name, c.Address, c.Zip, a.Sector from Company c join Category a on(c.Code = a.Code)
where sector in (select a.sector from category a group by sector having country != 'Australia');

create or replace view Q13(Code, Name, Address, Zip, Sector) as 
select c.Code, c.Name, c.Address, c.Zip, a.Sector from Company c join Category a on(c.Code = a.Code)
where sector not in (select sector from QQ13);

-- Q14: Using the similar functions as in Q7 such as max and min  to find the
-- first and last trading day, thus we can get those required results
create or replace view Q14(Code, BeginPrice, EndPrice, Change, Gain) as 
select a1.Code, a1.Price as BeginPrice, a2.Price as EndPrice, (a2.Price - a1.Price)as Change, (a2.Price - a1.Price)/a1.Price*100 as Gain
from ASX a1, ASX a2
where a1."Date" = (select min("Date") from ASX where Code = a2.Code) and a2."Date" = (select max("Date") from ASX where Code = a1.Code) and a1.Code = a2.Code
order by Gain desc, Code asc;

-- Q15: Reaching by creating two tables gaingain and priceprice and join them 
-- together, showing relevant figures about price and gain
create or replace view Q15(Code, MinPrice, AvgPrice,
	MaxPrice, MinDayGain, AvgDayGain, MaxDayGain)
as
with ggain as (
	select Code, min(gain), avg(gain) , max(gain)
	from Q7
	group by Code
),
pprice as (
	select Code, min(price), avg(price), max(price)
	from ASX
	group by Code
)
select ggain.Code, pprice.min, pprice.avg, pprice.max,
	ggain.min, ggain.avg, ggain.max
from pprice,ggain
where ggain.Code = pprice.Code
order by Code;

-- Q16: if this person is in more than 1 company, it may fail because count is 
-- used to check if it is duplicated
create or replace function trigger16() returns trigger as $$
declare
	nb_of_count integer;
begin
	nb_of_count := count(code) from Executive where Person = new.Person;
	if nb_of_count > 1
	then raise exception 'Sorry, this person is already an executive.';
	end if;
	return new;
end;
$$ language plpgsql;

-- create trigger Q16
CREATE TRIGGER Q16
AFTER INSERT OR UPDATE ON Executive
FOR EACH ROW
EXECUTE PROCEDURE trigger16();

-- Q17: AFK


-- Q18: To log any updates on Price and Voume in the ASX table and log them
-- (only for update, not inserts) into the ASXLog table, a trigger is created
create or replace function trigger18() returns trigger as $$
begin
	insert into ASXLog
	values(now(),new."Date", new.Code, old.Volume, old.Price);
	return new;
end;
$$ language plpgsql;

-- create trigger Q18
CREATE TRIGGER Q18
AFTER UPDATE ON ASX
FOR EACH ROW
EXECUTE PROCEDURE trigger18();


