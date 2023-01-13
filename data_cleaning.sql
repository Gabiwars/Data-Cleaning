-- Cleaning data in SQL Queries
-- Populate Property Address data

SELECT 
    *
FROM
    housing
ORDER BY ParcelID;


-- The COALESCE will have to move to the PropertyAddress column where we have null rows
SELECT 
    a.ParcelID,
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress,
    COALESCE(a.PropertyAddress, b.PropertyAddress) AS coa
FROM
    housing a
        JOIN
    housing b ON a.ParcelID = b.ParcelID
        AND a.UniqueID <> b.UniqueID
WHERE
    a.PropertyAddress IS NULL;

-- We update the PropertyAddress column so we don't have null rows anymore
UPDATE housing a,
    housing b 
SET 
    b.PropertyAddress = a.PropertyAddress
WHERE
    b.PropertyAddress IS NULL
        AND b.parcelid = a.parcelid
        AND a.propertyaddress IS NOT NULL;
         
         
         
-- Breaking out PropertyAddress into individual columns (Address and City)
         
SELECT 
    PropertyAddress
FROM
    housing;

SELECT 
    SUBSTRING_INDEX(PropertyAddress, ';', 1) AS Address,
    SUBSTRING_INDEX(PropertyAddress, ';', - 1) AS City
FROM
    housing;

SELECT 
    SUBSTRING_INDEX(PropertyAddress, ';', 1) AS Address,
    SUBSTRING_INDEX(PropertyAddress, ';', - 1) AS City
FROM
    housing;

alter table housing
add Address nvarchar(255);

UPDATE housing 
SET 
    Address = SUBSTRING_INDEX(PropertyAddress, ';', 1);

alter table housing
add City nvarchar(255);

UPDATE housing 
SET 
    City = SUBSTRING_INDEX(PropertyAddress, ';', - 1);


-- Breaking out OwnerAddress into individual columns (Address, City, State)

SELECT 
    OwnerAddress
FROM
    housing;

SELECT 
    SUBSTRING_INDEX(OwnerAddress, ';', 1) AS OwnerAddressOnly,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ';', 2),
            ';',
            - 1) AS OwnerCity,
    SUBSTRING_INDEX(OwnerAddress, ';', - 1) AS OwnerState
FROM
    housing;

alter table housing
add OwnerAddressOnly nvarchar(255);

UPDATE housing 
SET 
    OwnerAddressOnly = SUBSTRING_INDEX(OwnerAddress, ';', 1);

alter table housing
add OwnerCity nvarchar(255);

UPDATE housing 
SET 
    OwnerCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ';', 2),
            ';',
            - 1);

alter table housing
add OwnerState nvarchar(255);

UPDATE housing 
SET 
    OwnerState = SUBSTRING_INDEX(OwnerAddress, ';', - 1);


-- Chane Y and N to Yes and No in SoldAsVacant column

SELECT 
    *
FROM
    housing;

SELECT DISTINCT
    (SoldAsVacant), COUNT(SoldAsVacant)
FROM
    housing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT 
    SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END
FROM
    housing;

UPDATE housing 
SET 
    SoldAsVacant = CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;


-- Remove duplicates

SELECT 
    *
FROM
    housing;

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

SELECT 
    *
FROM
    housing;

alter table housing
drop column TaxDistrict;

alter table housing
drop column PropertyAddress;

alter table housing
drop column OwnerAddress;






















