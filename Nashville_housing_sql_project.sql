SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [Nashville_housing_sql_project].[dbo].[Nashville_Housing]

  ------------------ CLEANING DATA IN SQL QUARIES -------------------------- CLEANING DATA IN SQL QUERIES -------------
  SELECT * 
  FROM Nashville_Housing

  ----------------------- STANDARDIZE DATE FORMAT ---------------------STANDARDIZE DATE FORMAT -------------------------

  SELECT SaleDate
  FROM Nashville_Housing

  ------ SO I DONT WANT THIS TIME IN MY DATE COLUMN SO THATS WHY I AM ALTERING THE THE TABLE

  ALTER TABLE Nashville_Housing
  ADD SalesDate Date;

  UPDATE Nashville_Housing
  SET SalesDate = CONVERT(date,SaleDate)

  SELECT *
  FROM Nashville_Housing

---------------------------- POPULATE PROPERTY ADDRESS DATA ----------------

SELECT *
FROM Nashville_Housing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM Nashville_Housing A 
JOIN Nashville_Housing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM Nashville_Housing A 
JOIN Nashville_Housing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

---------------------------- BREAKING OUT PROPERTY ADDRESS INTO INDIVIDUAL COLUMN (ADDRESS, CITY ) ----------------------

SELECT PropertyAddress
FROM Nashville_Housing

SELECT 
	SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as Address
FROM Nashville_Housing



ALTER TABLE Nashville_Housing
Add PropertySplitAddress Nvarchar(255);

Update Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE Nashville_Housing
Add PropertySplitCity Nvarchar(255);

Update Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
FROM Nashville_Housing


---------------------------- BREAKING OUT OWNER ADDRESS INTO INDIVIDUAL COLUMN (ADDRESS, CITY AND STATE) ----------------------

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) AS ADDRESS
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) AS CITY
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) AS STATE
FROM Nashville_Housing


ALTER TABLE Nashville_Housing
Add OwnerSplitAddress Nvarchar(255);

Update Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Nashville_Housing
Add OwnerSplitCity Nvarchar(255);

Update Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Nashville_Housing
Add OwnerSplitState Nvarchar(255);

Update Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From Nashville_Housing

---------------------------- Change Y and N to Yes and No in "Sold as Vacant" field --------------------

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS COUNT
FROM Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY COUNT

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM Nashville_Housing

UPDATE Nashville_Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
				   WHEN SoldAsVacant = 'N' THEN 'No'
				   ELSE SoldAsVacant
				   END;

--------------	REMOVE DUPLICATES ------------------ REMOVE DUPLICATES--------------------------

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

FROM Nashville_Housing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



--------------------------------- NOW I AM DELETING DUPLICAES FROM MY DATA --------------------------

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

FROM Nashville_Housing 
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1



---------------------------------- SO FINALLY DELETED ----------------------------------------
-----------------------------------------------------------------------------------------------

--------------------------------------- DELETE UNUSED COLUMNS ------------------ DELETE UNUSED COLUMNS ---------

ALTER TABLE Nashville_Housing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict


SELECT *
FROM Nashville_Housing


