set linesize 10;

select distinct
  bib_id
from vger_report.tmp_west_serials
where location_code in ('sr', 'srucl', 'srucl2', 'srucl3', 'srucl4')
order by bib_id
;

