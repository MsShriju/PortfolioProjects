/*

Cleaning Data in SQL Queries

*/

------------------------------------------------------------------------------

SELECT * FROM SQLProject.dbo.NashvilleHousing;

-------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM SQLProject.dbo.NashvilleHousing;

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted= CONVERT(Date, SaleDate)


------------------------------------------------------------------------

-- Populate Property Address Data

Select *
FROM SQLProject.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM SQLProject.dbo.NashvilleHousing a
JOIN SQLProject.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM SQLProject.dbo.NashvilleHousing a
JOIN SQLProject.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID

-------------------------------------------------------------------------
---- Breaking out Address into Individual Columns

-- Using SUBSTRING: Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM SQLProject.dbo.NashvilleHousing
ORDER BY ParcelID

SELECT 
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM SQLProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


--------------------------------------------------------------------------

--USING PARSENAME: Breaking out Address into Individual Columns (Address, City, State)

SELECT OwnerAddress
FROM SQLProject.dbo.NashvilleHousing

SELECT
    PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
    PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
    PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM SQLProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

SELECT *
FROM SQLProject.dbo.NashvilleHousing


-------------------------------------------------------------------------

-- Change Y and N to yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM SQLProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER by 2

SELECT SoldAsVacant,
        CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
             WHEN SoldAsVacant = 'N' THEN 'No'
             ELSE SoldAsVacant
        END
FROM SQLProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
                        ELSE SoldAsVacant
                        END
                        

-------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER(
        PARTITION BY ParcelID,
                     PropertyAddress,
                     SalePrice,
                     SaleDate,
                     LegalReference
                     ORDER BY
                     UniqueID
    ) row_num
FROM SQLProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)

SELECT * 
FROM RowNumCTE
where row_num > 1
ORDER BY PropertyAddress

WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER(
        PARTITION BY ParcelID,
                     PropertyAddress,
                     SalePrice,
                     SaleDate,
                     LegalReference
                     ORDER BY
                     UniqueID
    ) row_num
FROM SQLProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
where row_num > 1

------------------------------------------------------------------------

-- Delete Unused Column

SELECT *
FROM SQLProject.dbo.NashvilleHousing

ALTER TABLE SQLProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

------------------------------------------------------------------------

