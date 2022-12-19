/*
Cleaning Data in SQL Queries
*/
select*
from NashvilleHouseing



--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select saleDateconverted, CONVERT(Date,SaleDate)
From NashvilleHouseing


Update NashvilleHouseing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHouseing
Add SaleDateConverted Date;

Update NashvilleHouseing
SET SaleDateConverted = CONVERT(Date,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select*
From NashvilleHouseing
--where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.propertyAddress,b.PropertyAddress)
From NashvilleHouseing a 
join NashvilleHouseing b
on a.ParcelID = b.ParcelID
   and a.[UniqueID ] <> b.[UniqueID ]
   where a.PropertyAddress is null

update a 
SET PropertyAddress = ISNULL(a.propertyAddress,b.PropertyAddress)
From NashvilleHouseing a 
join NashvilleHouseing b
on a.ParcelID = b.ParcelID
   and a.[UniqueID ] <> b.[UniqueID ]
   where a.PropertyAddress is null
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From NashvilleHouseing
--where PropertyAddress is null
order by ParcelID

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
from NashvilleHouseing


ALTER TABLE NashvilleHouseing
Add PropterySpiltAddress Nvarchar(255);

Update NashvilleHouseing
SET PropterySpiltAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHouseing
Add PropterySpiltCity Nvarchar(255);

Update NashvilleHouseing
SET PropterySpiltCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select*
from NashvilleHouseing





--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant),count(SoldAsVacant)
from NashvilleHouseing
group by SoldAsVacant
order by 2


select SoldAsVacant
, CASE when SoldAsVacant = 'Y' then 'YES'
	when SoldAsVacant = 'N' then 'NO'
	else SoldAsVacant
	end
from NashvilleHouseing

update NashvilleHouseing
SET SoldAsVacant =  CASE when SoldAsVacant = 'Y' then 'YES'
	when SoldAsVacant = 'N' then 'NO'
	else SoldAsVacant
	end


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS(
select*,
	ROW_NUMBER() OVER (
	PARTITION by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by 
				UniqueID
				)row_num

from NashvilleHouseing
--order by ParcelID
)
select*
from RowNumCTE
where row_num > 1
order by PropertyAddress





--order by ParcelID




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select*
from NashvilleHouseing


ALTER TABLE NashvilleHouseing
DROP COLUMN ownerAddress,TaxDistrict,PropertyAddress

ALTER TABLE NashvilleHouseing
DROP COLUMN saledate











-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO












