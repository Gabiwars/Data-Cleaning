-- Cleaning data in SQL Queries
select * from housing
where SoldAsVacant IS null;

-- delete from housing
-- where UniqueID = 0;

-- Populate Property Address data


Select *
From housing
-- Where PropertyAddress is null
order by ParcelID;


-- The COALESCE will have to move to the PropertyAddress column where we have null rows
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress , coalesce(a.PropertyAddress,b.PropertyAddress) as coa
From housing a
JOIN housing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID  <> b.UniqueID 
Where a.PropertyAddress is null;

-- We update the PropertyAddress column so we don't have null rows anymore
Update housing a, housing b
SET b.PropertyAddress = a.PropertyAddress
where  b.PropertyAddress IS NULL
         AND b.parcelid = a.parcelid
         AND a.propertyaddress is not null;
         
         
         
-- Breaking out PropertyAddress into individual columns (Address and City)
         
select PropertyAddress
from housing;

select 
substring_index(PropertyAddress, ';', 1) AS Address,
substring_index(PropertyAddress, ';', -1) AS City
from housing;

select substring_index(PropertyAddress, ';', 1) as Address,
substring_index(PropertyAddress, ';', -1) as City
from housing;

alter table housing
add Address nvarchar(255);

update housing
set Address = substring_index(PropertyAddress, ';', 1);

alter table housing
add City nvarchar(255);

update housing
set City = substring_index(PropertyAddress, ';', -1);


-- Breaking out OwnerAddress into individual columns (Address, City, State)

select OwnerAddress from housing;

select substring_index(OwnerAddress, ';', 1) as OwnerAddressOnly,
substring_index(substring_index(OwnerAddress, ';', 2), ';', -1) AS OwnerCity,
substring_index(OwnerAddress, ';', -1) AS OwnerState
from housing;

alter table housing
add OwnerAddressOnly nvarchar(255);

update housing
set OwnerAddressOnly = substring_index(OwnerAddress, ';', 1);

alter table housing
add OwnerCity nvarchar(255);

update housing
set OwnerCity = substring_index(substring_index(OwnerAddress, ';', 2), ';', -1);

alter table housing
add OwnerState nvarchar(255);

update housing
set OwnerState = substring_index(OwnerAddress, ';', -1);


-- Chane Y and N to Yes and No in SoldAsVacant column

select * from housing;

select distinct(SoldAsVacant), count(SoldAsVacant)
from housing
group by SoldAsVacant
order by 2;

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
End
from housing;

update housing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
End;


-- Remove duplicates

Select * from housing;

with CTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) as row_num

From housing
-- ORDER BY ParcelID
)
delete from housing
using housing
join CTE on housing.ParcelID = CTE.ParcelID
where row_num > 1;



-- Delete unused columns

select * from housing;

alter table housing
drop column TaxDistrict;

alter table housing
drop column PropertyAddress;

alter table housing
drop column OwnerAddress;























