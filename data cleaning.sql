/*

Data cleaning in SQL Queries

*/

Use cleaning;

/*
Select *
From nashvillehouse
*/

-- Standardize Date Format

Update nashvillehouse
SET SaleDate = STR_TO_DATE(SaleDate,'%M %d,%Y');

Select SaleDate
from nashvillehouse;


-- Populate Property Address data

Select *
From nashvillehouse
Where PropertyAddress is NULL
order by ParcelID;

	-- update with self join
UPDATE nashvillehouse a 
inner join nashvillehouse b 
	on a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
Where a.PropertyAddress is null;

/*
Select *
From nashvillehouse
*/

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT
SUBSTRING_INDEX(PropertyAddress,',', -1 ) as Address
,SUBSTRING_INDEX(PropertyAddress,',', 1 ) as Address
,SUBSTRING_INDEX(OwnerAddress,',', -1 ) as a,
SUBSTRING_INDEX(OwnerAddress,',', 1 ) as b
,SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',', 2 ),',', -1 ) as c,
OwnerAddress
From nashvillehouse;

ALTER TABLE nashvillehouse
Add PropertySplitAddress Nvarchar(255),
Add PropertySplitCity Nvarchar(255),
Add OwnerSplitAddress Nvarchar(255),
Add OwnerSplitCity Nvarchar(255),
Add OwnerSplitState Nvarchar(255);


Update nashvillehouse
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress,',', -1 ),
	PropertySplitCity = SUBSTRING_INDEX(PropertyAddress,',', 1 ),
    OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress,',', 1 ),
    OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',', 2 ),',', -1 ),
	OwnerSplitState = SUBSTRING_INDEX(OwnerAddress,',', -1 );
    
/*
Select *
From nashvillehouse
*/


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From nashvillehouse
Group by SoldAsVacant
order by 2;

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From nashvillehouse;

Update nashvillehouse
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;

/*
Select *
From nashvillehouse
*/


-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From nashvillehouse
order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress;

/*
Select *
From nashvillehouse
*/

-- Delete Unused Columns

ALTER TABLE nashvillehouse
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress, 
DROP COLUMN SaleDate;

Select *
From nashvillehouse
