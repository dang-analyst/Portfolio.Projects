--- adding constraints & changing column datatypes
alter table myDNNDatabase..SGListings
	alter column name nvarchar(100) null;

alter table myDNNDatabase..SGListings
	alter column minimum_nights int;

alter table myDNNDatabase..SGListings
	alter column number_of_reviews int;

alter table myDNNDatabase..SGListings
	alter column last_review date;

alter table myDNNDatabase..SGListings
	alter column reviews_per_month decimal (18,3);

alter table myDNNDatabase..SGListings
	alter column calculated_host_listings_count int;

alter table myDNNDatabase..SGListings
	alter column availability_365 int; 



--- combine neighbourhood_group & neighbourhood columns
Select (concat(neighbourhood_group,' ' ,neighbourhood)) As Location, room_type
into myDNNDatabase..SGListingsv2
	from MyDNNDatabase..SGlistings 



---- Total number of reviews & listings per host
select HOST_ID, HOST_NAME, SUM(number_of_reviews) As Total_reviews, COUNT(number_of_reviews) As Listings
from MyDNNDatabase..SGlistings
	group by host_id, host_name
	order by SUM(number_of_reviews) desc;



-- Room types per location
select Location, COUNT(room_type)  As No_private_room
	into myDNNDatabase..SGListings_p
from myDNNDatabase..SGListingsv2
		where room_type like 'p%'
		group by Location
		order by COUNT(room_type) desc;

select Location, COUNT(room_type)  As No_entire_place
	into myDNNDatabase..SGListings_e
from myDNNDatabase..SGListingsv2
		where room_type like 'e%'
		group by Location
		order by COUNT(room_type) desc;

select E.location, e.No_entire_place, P.no_private_room
from MyDNNDatabase..SGListings_p p
	join MyDNNDatabase..SGListings_e e
	on p.Location=e.Location
		order by Location



-- Add minimum cost column
Alter table MyDNNDatabase..SGListings
	Add minimum_cost As (price*minimum_nights)

select name, price, minimum_nights, minimum_cost
from MyDNNDatabase..SGlistings
	order by minimum_cost desc


