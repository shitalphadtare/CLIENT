Create View BANK_DETAILS as
select distinct revoffice 'Pan No',dflbnkcode 'bankcode',dsc.bankname,dflbnkacct 'account no',dflbranch 'branch',dc1.swiftnum from oadm ADM
left outer join odsc dsc on adm.dflbnkcode=dsc.bankcode and DflBnkAcct=dflbnkcode
left outer join dsc1 dc1 on adm.dflbnkcode=dc1.bankcode
