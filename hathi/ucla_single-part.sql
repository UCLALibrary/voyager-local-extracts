/********************************
  Report 6: UCLA single-part monos
********************************/

set trim on;

with bibs as (
  select distinct
    b.oclc
  , b.bib_id
  from vger_report.tmp_hathi_base b
  inner join ucladb.bib_mfhd bm on b.bib_id = bm.bib_id
  inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  where b.bib_lvl in ('m', 'i')
  and mm.record_type = 'x'
  -- All mfhds for bib must have record_type = 'x'
  and not exists (
    select *
    from ucladb.bib_mfhd bm2
    inner join ucladb.mfhd_master mm2 on bm2.mfhd_id = mm2.mfhd_id
    where bm2.bib_id = b.bib_id
    and mm2.record_type != 'x'
  )
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
  from bibs b
  inner join ucladb.bib_mfhd bm on b.bib_id = bm.bib_id
  inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join ucladb.location l on mm.location_id = l.location_id
  left outer join ucladb.mfhd_item mi on mm.mfhd_id = mi.mfhd_id
  -- Exclude non-UCLA, non-print-centric locs
  where l.location_code not like 'sr%'
  and l.location_code not in (
	'aiscaudi', 'aiscav', 'aiscvide', 'armedia', 'armi'
  ,	'arrfelec', 'bicimm', 'bihimi', 'bimi', 'birfmi'
  ,	'cascaudi', 'cascvide', 'ckmi', 'clmi', 'csmi'
  ,	'idcoll', 'ilacdrom', 'ilaumat', 'ilavhst', 'ilavideo'
  ,	'ili16mm', 'ilidvd', 'ilistrip', 'ilivhst', 'lgvid'
  ,	'lwciaudio', 'lwcidisks', 'lwcivideo', 'lwmi', 'mgmi'
  ,	'mgmigk', 'mgrfcdrom', 'mgrffiche', 'muclsdmm', 'muclsdsdr'
  ,	'mumi', 'muscsdr', 'sgav', 'sgmi', 'sgrfelec'
  ,	'smav', 'smmi', 'yralmi', 'yrmi', 'yrmiclsd'
  ,	'in'
  )
  and (
        exists (select * from vger_report.tmp_clu_export_1 where bib_id = b.bib_id)
    or  exists (select * from vger_report.tmp_clu_export_5 where bib_id = b.bib_id)
  )
)
-- tab delimited with no extra sqlplus padding
select
  oclc || chr(9) ||
  bib_id || chr(9) ||
  item_status || chr(9) ||
  condition
from data
;
