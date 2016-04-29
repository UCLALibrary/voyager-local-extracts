/********************************
  Report 2: SRLF multi-part monos
********************************/

set trim on;

with bibs as (
  select distinct
    b.oclc
  , b.bib_id
  from vger_report.tmp_hathi_base b
  inner join ucladb.bib_mfhd bm on b.bib_id = bm.bib_id
  where b.bib_lvl in ('m', 'i')
  -- At least 1 mfhd has LDR/06 = 'v'
  and exists (select * from ucladb.mfhd_master where mfhd_id = bm.mfhd_id and record_type = 'v')
)
, data as (
  select
    b.oclc
  , b.bib_id
  , case 
      when regexp_like(vger_support.get_all_item_status(mi.item_id), '(Lost--Library|Missing)')
        then 'LM'
      when regexp_like(vger_support.get_all_item_status(mi.item_id), 'Withdrawn') then 'WD'
      when vger_support.get_all_item_status(mi.item_id) is null then null
      else 'CH'
    end as item_status
  , null as condition
  , mi.item_enum
  from bibs b
  inner join ucladb.bib_mfhd bm on b.bib_id = bm.bib_id
  inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join ucladb.location l on mm.location_id = l.location_id
  inner join ucladb.mfhd_item mi on mm.mfhd_id = mi.mfhd_id
  where l.location_code like 'sr%'
  -- mfhd has no 007, or 007/00 is certain values
  and ( mm.field_007 is null
    or  substr(mm.field_007, 1, 1) in (' ', 'a', 'q', 'r', 't')
  )
)
-- tab delimited with no extra sqlplus padding
select
  oclc || chr(9) ||
  bib_id || chr(9) ||
  item_status || chr(9) ||
  condition || chr(9) ||
  item_enum
from data
;
