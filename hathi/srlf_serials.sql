/********************************
  Report 1: SRLF Serials 
********************************/

set trim on;

with data as (
  select distinct
    b.oclc
  , b.bib_id
  , bt.issn
  from vger_report.tmp_hathi_base b
  inner join ucladb.bib_text bt on b.bib_id = bt.bib_id
  inner join ucladb.bib_mfhd bm on bt.bib_id = bm.bib_id
  inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join ucladb.location l on mm.location_id = l.location_id
  inner join ucladb.mfhd_item mi on mm.mfhd_id = mi.mfhd_id
  where b.bib_lvl = 's'
  and l.location_code like 'sr%'
)
-- tab delimited with no extra sqlplus padding
select 
  oclc || chr(9) ||
  bib_id || chr(9) || 
  issn
from data
;
