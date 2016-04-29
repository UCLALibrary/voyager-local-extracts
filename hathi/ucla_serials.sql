/********************************
  Report 4: UCLA serials
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
  inner join vger_report.bib_f910a_data f on b.bib_id = f.bib_id
  where b.bib_lvl = 's'
  and l.location_code not like 'sr%'
  -- Either CLU group 1 or CLU group 4 criteria must be met
  and (
        exists (select * from vger_report.tmp_clu_export_1 where bib_id = b.bib_id)
    or  exists (select * from vger_report.tmp_clu_export_4 where bib_id = b.bib_id)
  )
)
-- tab delimited with no extra sqlplus padding
select
  oclc || chr(9) ||
  bib_id || chr(9) ||
  issn
from data
;
