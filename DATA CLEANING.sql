-- CLEANING DATA IN SQL QUERIES

SELECT *
FROM PortfolioProject..NashvilleHousing

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)


ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate property Address Data

SELECT *
FROM PortfolioProject..NashvilleHousing
order by ParcelID


SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
   ON a.ParcelID = b.ParcelID
   AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
   ON a.ParcelID = b.ParcelID
   AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking out Address into Individual Columns(Address,City,State)

select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NashvilleHousing





Select OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing


select 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)


Select * 
from PortfolioProject.dbo.NashvilleHousing


-- change Y and N to Yes and No in 'sold as vacant' feild

Select Distinct(SoldAsVacant),Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

select SoldAsVacant,
CASE when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
From PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END


-- Remove Duplicates

with RowNumCTE AS(
Select *,
ROW_NUMBER() OVER(PARTITION BY ParcelID,
				               PropertyAddress,
							   SalePrice,
							   SaleDate,
							   LegalReference
							   order by
							           UniqueID
									   ) row_num
from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
DELETE
from RowNumCTE
where row_num >1
--order by PropertyAddress



-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate