SELECT * FROM [Portfolio Project ].dbo.NashvilleHousing




--Sales Date Format 
SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM [Portfolio Project ].dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)


ALTER TABLE NashvilleHousing 
Add SaleDateConverted Date; 

Update NashvilleHousing
SET  SaleDateConverted = CONVERT(Date, SaleDate)


--Populate Property Address data 
SELECT *
FROM [Portfolio Project ].dbo.NashvilleHousing
--WHERE PropertyAddress is null
order by ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project ].dbo.NashvilleHousing a 
JOIN [Portfolio Project ].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project ].dbo.NashvilleHousing a 
JOIN [Portfolio Project ].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 


--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM [Portfolio Project ].dbo.NashvilleHousing
--WHERE PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address

FROM [Portfolio Project ].dbo.NashvilleHousing




ALTER TABLE NashvilleHousing
Add PropertySlitAddress NVARCHAR(255); 

Update NashvilleHousing
SET PropertySlitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)



ALTER TABLE NashvilleHousing 
Add PropertySplitCity Nvarchar(255); 

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
FROM [Portfolio Project ].dbo.NashvilleHousing


--Another ways and more easy 

SELECT OwnerAddress
FROM [Portfolio Project ].dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
FROM [Portfolio Project ].dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255); 

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255); 

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)



SELECT *
FROM [Portfolio Project ].dbo.NashvilleHousing


--Change Y and N to Yes and No "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project ].dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END 
FROM [Portfolio Project ].dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END 


--Remove Duplicates 
WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num

FROM [Portfolio Project ].dbo.NashvilleHousing
--order by ParcelID
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress






--Delete Unused Columns 

SELECT *
FROM [Portfolio Project ].dbo.NashvilleHousing

ALTER TABLE [Portfolio Project ].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE [Portfolio Project ].dbo.NashvilleHousing
DROP COLUMN SaleDate
