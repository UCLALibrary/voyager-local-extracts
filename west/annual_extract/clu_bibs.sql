set linesize 10;

select distinct
  bib_id
from vger_report.tmp_west_serials
where location_code not in ('sr', 'srucl', 'srucl2', 'srucl3', 'srucl4')
-- 2013 ONLY; confirm for future years
and location_code not like 'mg%'
order by bib_id
;

