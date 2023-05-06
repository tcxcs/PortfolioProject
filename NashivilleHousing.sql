use PortfoilioProject;

select * from  NashvilleHousing

--Add a new column with the desired type of SaleDate 
alter table NashvilleHousing
add SaleDate1 date
Update NashvilleHousing
set SaleDate1 = convert(date,SaleDate)


--Populate Property Address 
select * from NashvilleHousing
order by ParcelID

select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ],b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b 
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is not null

Update a
set a.PropertyAddress=ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b 
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]

--Breaking out property address into individual columns(Address, City, State) 
select PropertyAddress from NashvilleHousing

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)as PropertyStreetAddres,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as City
from NashvilleHousing
 
Alter table NashvilleHousing
add PropertyStreetAddress nvarchar(255)

Update NashvilleHousing
set PropertyStreetAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter table NashvilleHousing
add City nvarchar(255)

Update NashvilleHousing
set City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

--Breaking out owner address into individual columns(Address, City, State) 
select OwnerAddress from NashvilleHousing

select PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from NashvilleHousing

Alter table NashvilleHousing
add OwnerStreetAddress nvarchar(255)

Update NashvilleHousing
set OwnerStreetAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

Alter table NashvilleHousing
add OwnerCity nvarchar(255)

Update NashvilleHousing
set OwnerCity = PARSENAME(replace(OwnerAddress,',','.'),2)

Alter table NashvilleHousing
add OwnerState nvarchar(255)

Update NashvilleHousing
set OwnerState = PARSENAME(replace(OwnerAddress,',','.'),1)


--Change Y,N to Yes,No in "sold as Vacant" field
select Distinct(SoldAsVacant), Count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 1

select SoldAsVacant, 
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant ='N' then 'N'
	 else SoldAsVacant
	 end
from NashvilleHousing

Update NashvilleHousing
set SoldAsVacant = case 
     when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant ='N' then 'No'
	 else SoldAsVacant
	 end

--Delete duplicate rows
with DupRowsCTE as(
select *, ROW_NUMBER()over(
partition by ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			Order by UniqueID
			) RowNum 
from NashvilleHousing)

Delete from DupRowsCTE
where RowNum > 1


--Delete unusable columns 
Alter table NashvilleHousing 
Drop column PropertyAddress,OwnerAddress,SaleDate

