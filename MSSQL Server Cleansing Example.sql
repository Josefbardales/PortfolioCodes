SELECT * FROM PortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format

SELECT SaleDate, CONVERT(Date,SaleDate) as Date
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted DATE;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted FROM NashvilleHousing

-- Populate Property Address Data

SELECT * FROM PortfolioProject.dbo.NashvilleHousing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a 
JOIN NashvilleHousing b ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a 
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress) as PropertyAddress
FROM NashvilleHousing a 
JOIN NashvilleHousing b ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Breaking out Address into individual Columns through SUBSTRING (Address, City)

SELECT PropertyAddress 
FROM NashvilleHousing 

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
Add AddressSplit Nvarchar(255);

UPDATE NashvilleHousing
SET AddressSplit = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add CitySplit Nvarchar(255);

UPDATE NashvilleHousing
SET CitySplit = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT AddressSplit, CitySplit FROM NashvilleHousing

--- Breaking out Address into individual Columns through PARSENAME (Address, City, State)

SELECT OwnerAddress FROM NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
Add AddressSplitOwner Nvarchar(255);

ALTER TABLE NashvilleHousing
Add CitySplitOwner Nvarchar(255);

ALTER TABLE NashvilleHousing
Add StateSplitOwner Nvarchar(255);

UPDATE NashvilleHousing
SET AddressSplitOwner = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

UPDATE NashvilleHousing
SET CitySplitOwner = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

UPDATE NashvilleHousing
SET StateSplitOwner = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--- Change Y and N to Yes and No in a field thorough a CASE Statement

SELECT SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes' 
	WHEN SoldAsVacant = 'N' THEN 'No' 
	ELSE SoldAsVacant
	END FROM NashvilleHousing

UPDATE NashvilleHousing 
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes' 
	WHEN SoldAsVacant = 'N' THEN 'No' 
	ELSE SoldAsVacant
	END

SELECT DISTINCT SoldAsVacant FROM NashvilleHousing

--- Remove Duplicates

SELECT ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference, UniqueID, rn
FROM (
    SELECT *, 
    ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference ORDER BY UniqueID) rn
    FROM NashvilleHousing
) AS subquery
WHERE rn = 1;

--- Delete Unused Columns

ALTER TABLE portfolioproject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
