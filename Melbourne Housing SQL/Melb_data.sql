---------------------------------------------------------------------------------------------------------

select * from MyDNNDatabase..Melb_data

---------------------------------------------------------------------------------------------------------

-- Convert Date Format

select date, convert(date, date) 
	from Melb_data

alter table Melb_data
	add Dateconverted Date

update Melb_data
	set Dateconverted = CONVERT(date, date)

---------------------------------------------------------------------------------------------------------

-- Seperating street name and address number

select Address, SUBSTRING(address, 0, CHARINDEX(' ',Address,0)) As StreetNumber, SUBSTRING(address, CHARINDEX(' ', address, 1)+1, 100) As StreetName
	from Melb_data

alter table Melb_data
	add StreetNumber nvarchar(255), StreetName nvarchar(255)

update Melb_data
	set StreetNumber =SUBSTRING(address, 0, CHARINDEX(' ',Address,0))

update Melb_data
	set StreetName = SUBSTRING(address, CHARINDEX(' ', address, 1)+1, 100)

---------------------------------------------------------------------------------------------------------

-- Reomving Methods' Acronyms

Select distinct (Method) 
	from Melb_data

select distinct (Method),
	Case
		When Method = 'SS' Then 'Sold after auction price not disclosed'
		When Method = 'W' Then 'Withdrawn prior to auction'
		When Method = 'SP' Then 'Property sold prior'
		When Method = 'S' Then 'Property sold'
		When Method = 'SA' Then 'Sold after auction'
		When Method = 'PN' Then 'Sold prior not disclosed'
		When Method = 'VB' Then 'Vendor bid'
		When Method = 'SN' Then 'Sold not disclosed'
		When Method = 'PI' Then 'Property passed in'	
	End As MethodUpdated
From Melb_data

Alter table Melb_data
	Add MethodUpdated nvarchar(255)

Update Melb_data
	Set MethodUpdated = Case
		When Method = 'SS' Then 'Sold after auction price not disclosed'
		When Method = 'W' Then 'Withdrawn prior to auction'
		When Method = 'SP' Then 'Property sold prior'
		When Method = 'S' Then 'Property sold'
		When Method = 'SA' Then 'Sold after auction'
		When Method = 'PN' Then 'Sold prior not disclosed'
		When Method = 'VB' Then 'Vendor bid'
		When Method = 'SN' Then 'Sold not disclosed'
		When Method = 'PI' Then 'Property passed in'	
	End
 
select distinct(methodupdated) from Melb_data

---------------------------------------------------------------------------------------------------------

-- Changing t,h,u in Type to 'townhouse'; 'house, cottage, villa, semi, terrace'; 'unit,duplex'

Select distinct (type) from Melb_data

Alter table Melb_data
	Add TypeUpdated nvarchar(255)

Update Melb_data
	Set TypeUpdated = Case
		When Type = 't' Then 'townhouse'
		When Type = 'h' Then 'house, cottage, villa, semi, terrace'
		When Type = 'u' Then 'unit,duplex'
	End

---------------------------------------------------------------------------------------------------------

-- Number of houses with respect to types

select typeupdated, COUNT(type) #House
---into myDNNDatabase..Melb_data_type
	from Melb_data
	group by TypeUpdated

---------------------------------------------------------------------------------------------------------

-- Streets with highest number of house sold

select streetname, count(price) As #HouseSold
---into myDNNDatabase..Melb_data_pop_str
	from Melb_data
	group by streetname
		having COUNT(price) > 50
		order by COUNT(price) desc

---------------------------------------------------------------------------------------------------------

-- Create procedure to find Average House Prices(AHP) with respect to types, suburb

Create Procedure AverageHousePrice
	@Suburb nvarchar (50),
	@Type nvarchar(50)

As
	select distinct (suburb), Type, TypeUpdated, avg(price) over(
			partition by suburb, type
			order by suburb
				)
	from Melb_data
	where Price is not null And suburb = @Suburb And Type = @Type

Go

-- Use Procedure to find AVH for unit, duplex in Coburg

Execute AverageHousePrice 'coburg', 'u'

---------------------------------------------------------------------------------------------------------

-- AHP in each suburb

select distinct (suburb), avg(price) over(
			partition by suburb
			order by suburb
				) As avgPrice
---into myDNNDatabase..Melb_data_suburb_avh
	from Melb_data
	where Price is not null

---------------------------------------------------------------------------------------------------------
