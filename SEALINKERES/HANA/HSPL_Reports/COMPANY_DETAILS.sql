CREATE VIEW COMPANY_DETAILS as
select isnull(block+' ','')+isnull(Building+' ','')+isnull(street+' ','')+isnull(City+' -','')+
isnull(zipcode+' ','')+isnull((select Name from ocst where code=State)+',','')+isnull(ocry.Name+'.','') 'Address' from adm1
left outer join OCRY on ocry.Code=ADM1.Country