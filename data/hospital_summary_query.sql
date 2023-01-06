

--4254, expected output

select
	base_cpt.CPT,
	bm.BM_GROSS_CHARGE,
	bm.BM_CASH_PRICE,
	ut.UT_GROSS_CHARGE,
	ut.UT_CASH_PRICE,
	pw.PW_GROSS_CHARGE,
	pw.PW_CASH_PRICE,
	tc.TC_GROSS_CHARGE,
	tc.TC_CASH_PRICE
from 
	(select CPT_OR_HCPCS_CODE AS CPT
	from [dbo].[BM_HOSPITAL_DATA]
	where ISNUMERIC(LEFT(CPT_OR_HCPCS_CODE, 1)) = 1 AND LEN(CPT_OR_HCPCS_CODE) = 5

	union

	select CPT
	from [dbo].[TC_HOSPITAL_DATA]
	where ISNUMERIC(LEFT(CPT, 1)) = 1 AND LEN(CPT) = 5

	union

	select CODE as CPT
	from [dbo].[PW_HOSPITAL_DATA]
	where ISNUMERIC(LEFT(CODE, 1)) = 1 AND LEN(CODE) = 5

	union

	select CPT
	from [dbo].[UT_HOSPITAL_DATA]
	where ISNUMERIC(LEFT(CPT, 1)) = 1 AND LEN(CPT) = 5) base_cpt

left join (
	select CPT_OR_HCPCS_CODE, 
		AVG(GROSS_CHARGE) as BM_GROSS_CHARGE, 
		AVG(CASH_PRICE) as BM_CASH_PRICE
	from [dbo].[BM_HOSPITAL_DATA]
	group by CPT_OR_HCPCS_CODE) bm
on base_cpt.CPT = bm.CPT_OR_HCPCS_CODE

left join (
	select CPT,
		AVG(GROSS_CHARGE_PER_UNIT) as UT_GROSS_CHARGE,
		AVG(CASH_PRICE) as UT_CASH_PRICE
	from [dbo].[UT_HOSPITAL_DATA]
	group by CPT ) ut 
on base_cpt.CPT = ut.CPT

left join (
	select CODE,
		AVG(GROSS_CHARGE) as PW_GROSS_CHARGE,
		AVG(DISCOUNTED_CASH_PRICE) as PW_CASH_PRICE
	from [dbo].[PW_HOSPITAL_DATA]
	group by CODE ) pw 
on base_cpt.CPT = pw.CODE

left join (
	select CPT,
		AVG(GROSS_CHARGE) as TC_GROSS_CHARGE,
		AVG(DISCOUNTED_CASH_PRICE_INPATIENT) as TC_CASH_PRICE
	from [dbo].[TC_HOSPITAL_DATA]
	group by CPT ) tc 
on base_cpt.CPT = tc.CPT
