/* Cleaning data using SQL */

SELECT * 
FROM NashvilleHousing

--Total Records

SELECT count(*) AS TotalNumofRecords
FROM NashvilleHousing 

-- Lets chceck the number of NULL values

SELECT PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress IS NULL

--Doing Self JOINS (If a parcel ID are same then NULL will be replace with same ParcelID)
SELECT PID.PropertyAddress,PID.ParcelID, PID1.PropertyAddress, PID1.ParcelID, ISNULL(PID.PropertyAddress, PID1.PropertyAddress)
FROM NashvilleHousing PID
JOIN NashvilleHousing PID1
	ON PID.ParcelID = PID1.ParcelID
	AND PID.[UniqueID ] <> PID1.[UniqueID ] --will never repeat

UPDATE PID
SET PropertyAddress = ISNULL(PID.PropertyAddress, PID1.PropertyAddress)
FROM NashvilleHousing PID
JOIN NashvilleHousing PID1
	ON PID.ParcelID = PID1.ParcelID
	AND PID.[UniqueID ] <> PID1.[UniqueID ]

-- Changing the address format

SELECT PropertyAddress
FROM NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as AddressPO --CHARINDEX(',', PropertyAddress) : it is indicated as Index number
, SUbSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS AddressPlace
FROM NashvilleHousing



ALTER TABLE NashvilleHousing
ADD SplitAddress NVarchar(255);

UPDATE NashvilleHousing
SET SplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD SplitCity NVarchar(255);

UPDATE NashvilleHousing
SET SplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT * 
FROM NashvilleHousing

-- Modifying the Owner address

SELECT OwnerAddress
FROM NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3), --PARSENAME connect things backwards
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NAshvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT * 
FROM NashvilleHousing

-- Check the Sold as Vacant column
Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
END
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant =
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
END

-- Remove Duplicates

			-- To check see the duplicate rows
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UNIqueID
					 ) row_num

FROM NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress

			--- DELETE the Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UNIqueID
					 ) row_num

FROM NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num >1

--Change the date format

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE

SELECT SaleDate
FROM NashvilleHousing


-----Get rid of unused columns
SELECT * 
FROM NashvilleHousing

ALTER TABLE  NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

-- View creation

CREATE OR ALTER VIEW [Information] AS
SELECT SplitAddress, SplitCity, OwnerName, LandUse,YearBuilt, Bedrooms, SaleDate, SalePrice
FROM NashvilleHousing

SELECT * FROM Information

-- Useful insights from the data

SELECT TOP 10 SplitCity, Count(SplitCity) AS Total 
FROM Information
GROUP BY SplitCity 
ORDER BY Total Desc

SELECT SaleDate, count(SaleDate) as Total 
FROM Information
GROUP BY SaleDate
ORDER BY Total DESC

SELECT MIN(Bedrooms) AS MIN_Bedrooms, MAX(Bedrooms) AS MAX_Bedrooms, round(AVG(Bedrooms), 0) AS AVG_Bedrooms
From Information

SELECT MIN(SalePrice) AS MIN_SalePrice, MAX(SalePrice) AS Max_SalePrice, round(AVG(SalePrice), 3) AS AVG_SalePrice
FROM Information


