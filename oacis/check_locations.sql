set linesize 10;

prompt Checking locations - create new excel file if highest location_id is more than 715;

select
  max(mm.location_id) as location_id
from ucladb.mfhd_master mm
inner join vger_report.oacis_extract oe on mm.mfhd_id = oe.mfhd_id
;

