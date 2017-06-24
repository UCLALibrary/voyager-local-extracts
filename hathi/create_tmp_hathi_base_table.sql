create table vger_report.tmp_hathi_base as
select
  bt.bib_id
, substr(bib_format, 2, 1) as bib_lvl
, replace(bi.normal_heading, 'UCOCLC', '') as oclc
from ucladb.bib_text bt
inner join ucladb.bib_master bm on bt.bib_id = bm.bib_id
-- 2017-06: Using sub-query is now far too slow - 15+ hours
-- Use inner join to get data, then filter out a few thousand dups later
-- More complex, but takes < 15 minutes....
inner join ucladb.bib_index bi
  on bt.bib_id = bi.bib_id
  and bi.index_code = '0350'
  and bi.normal_heading like 'UCOCLC%'
where bm.suppress_in_opac = 'N'
-- Combination of LDR/06 and 008/23 or 008/29, depending on format
and ( (substr(bt.bib_format, 1, 1) in ('a', 'c') and substr(bt.field_008, 24, 1) in (' ', 'd', 'r'))
  or  (substr(bt.bib_format, 1, 1) in ('e') and substr(bt.field_008, 30, 1) in (' ', 'd', 'r'))
)
;

create index vger_report.ix_tmp_hathi_base on vger_report.tmp_hathi_base (bib_id, bib_lvl);

-- Remove rows where bib has multiple OCLC numbers, keeping just the "lowest"
-- per string comparison.
delete from vger_report.tmp_hathi_base
where (bib_id, oclc) in (
  with dups as (
    select bib_id, oclc
    from vger_report.tmp_hathi_base
    where bib_id in (
      select bib_id from vger_report.tmp_hathi_base
      group by bib_id having count(*) > 1
    )
  )
  select bib_id, oclc
  from dups d
  where oclc != (
    select min(oclc) from dups where bib_id = d.bib_id
  )
)
;
commit;

-- Remove records with 245 $h 
-- Much faster this way than to filter out during table creation.
delete from vger_report.tmp_hathi_base b
where exists (
  select *
  from vger_subfields.ucladb_bib_subfield
  where record_id = b.bib_id
  and tag = '245h'
)
;
commit;

