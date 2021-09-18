
/* SQL DATA CLEANING using Nashville housing prices database */

Select * from datum

--Converting sale date format

select SaleDate, CONVERT(Date,SaleDate) from datum;

alter table datum
add SaleDateConv Date;

Update datum
set SaleDateConv=CONVERT(Date,SaleDate);

--Removing null from property address

select * from datum

select * from datum
where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From datum a
JOIN datum b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From datum a
JOIN datum b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From datum a
JOIN datum b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Select * from datum
where PropertyAddress is null

--Breaking property address into address, city, state

Select PropertyAddress from datum

Select PropertyAddress,
substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as PropAddress,
substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as PropCity
from datum

alter table datum
add PropAddress nvarchar(255);

Update datum
set PropAddress=substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table datum
add PropCity nvarchar(255);

Update datum
set PropCity=substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

Select PropertyAddress,PropAddress,PropCity from datum

--Breaking down Owner address

Select OwnerAddress from datum 

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From datum

alter table datum
add OwnerAdd nvarchar(255);

Update datum
set OwnerAdd=PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

alter table datum
add OwnerCity nvarchar(255);

Update datum
set OwnerCity=PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

alter table datum
add OwnerState nvarchar(255);

Update datum
set OwnerState=PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select * from datum


--Convert 'SoldAsVacant' column to Yes/No 

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From datum
Group by SoldAsVacant
order by 2

Select SoldAsVacant, 
CASE	
When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
From datum

Update datum
SET SoldAsVacant = 
CASE 
When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

Select distinct(SoldAsVacant),count(SoldAsVacant) from datum
group by SoldAsVacant

--Removing duplicate records

Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) as row_num
From datum
order by row_num desc;

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) as row_num
From datum)
Select *
From RowNumCTE
Where row_num > 1

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) as row_num
From datum)
Delete 
From RowNumCTE
Where row_num > 1

Select count(*)
from datum


--Deleting unnecessary columns

Select *
from datum

alter table datum
drop column PropertyAddress,OwnerAddress,TaxDistrict

alter table datum
drop column SaleDate

Select *
from datum