use PortfolioProject

/*

DATA CLEANING PROJECT

*/

Select * 
From NashvilleHousing

---------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format -- 

Select SaleDate, Convert(Date, SaleDate) as FinalFormat
From NashvilleHousing

--Update NashvilleHousing				-- Doesn't Work -- 
--Set SaleDate = Convert(Date, SaleDate) 

Alter Table NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing 
Set SaleDateConverted = Convert(Date, SaleDate) 

Select SaleDateConverted, Convert(Date, SaleDate) as FinalFormat
From NashvilleHousing

---------------------------------------------------------------------------------------------------------------------

-- Populating Property Address data --

Select *
From NashvilleHousing
--Where PropertyAddress is Null
Order By ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] != b.[UniqueID ]
--Where a.PropertyAddress is Null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is Null

---------------------------------------------------------------------------------------------------------------------

-- Breaking out PropertyAddress into individual columns (Address, City, State) --

Select SubString(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) as Address,
		SubString(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1 , LEN(PropertyAddress)) as City
From NashvilleHousing


Alter Table NashvilleHousing
Add PropAddress Nvarchar(255)

Update NashvilleHousing 
Set PropAddress = SubString(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropCity Nvarchar(255)

Update NashvilleHousing 
Set PropCity = SubString(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1 , LEN(PropertyAddress))


--ALTER TABLE NashvilleHousing
--DROP COLUMN City;
---------------------------------------------------------------------------------------------------------------------

-- Breaking out OwnerAddress into individual columns (Address, City, State) --

Select
ParseName(Replace(OwnerAddress, ',', '.'), 3),
ParseName(Replace(OwnerAddress, ',', '.'), 2),
ParseName(Replace(OwnerAddress, ',', '.'), 1)
From NashvilleHousing

Alter Table NashvilleHousing
Add OwnerAdd Nvarchar(255)

Update NashvilleHousing 
Set OwnerAdd = ParseName(Replace(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerCity Nvarchar(255)

Update NashvilleHousing 
Set OwnerCity = ParseName(Replace(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerState Nvarchar(255)

Update NashvilleHousing 
Set OwnerState = ParseName(Replace(OwnerAddress, ',', '.'), 1)


---------------------------------------------------------------------------------------------------------------------

-- Change Y or N to Yes and No in "Sold as Vacant" field -- 

Select Distinct SoldAsVacant, Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2 

Select 
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
					When SoldAsVacant = 'N' Then 'No'
					Else SoldAsVacant
					End
---------------------------------------------------------------------------------------------------------------------

-- Removing Duplicates --

With RowNumCTE As (
Select *,
		ROW_NUMBER() Over(
		Partition By ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 Order By
						UniqueID
					 ) row_num
From NashvilleHousing
--Order By ParcelID
)
Delete
From RowNumCTE
Where row_num > 1 
--Order By PropertyAddress


---------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns -- 

Alter Table NashvilleHousing
Drop Column PropertyAddress, OwnerAddress, TaxDistrict

---------------------------------------------------------------------------------------------------------------------