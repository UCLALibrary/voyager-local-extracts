create table vger_report.tmp_hathi_base as
select
  bt.bib_id
, substr(bib_format, 2, 1) as bib_lvl
, ( select replace(normal_heading, 'UCOCLC', '')
    from ucladb.bib_index
    where bib_id = bt.bib_id
    and index_code = '0350'
    and normal_heading like 'UCOCLC%'
    and rownum < 2
) as oclc
from ucladb.bib_text bt
inner join ucladb.bib_master bm on bt.bib_id = bm.bib_id
where bm.suppress_in_opac = 'N'
-- Combination of LDR/06 and 008/23 or 008/29, depending on format
and ( (substr(bt.bib_format, 1, 1) in ('a', 'c') and substr(bt.field_008, 24, 1) in (' ', 'd', 'r'))
  or  (substr(bt.bib_format, 1, 1) in ('e') and substr(bt.field_008, 30, 1) in (' ', 'd', 'r'))
)
and exists (
  select *
  from ucladb.bib_index
  where bib_id = bt.bib_id
  and index_code = '0350'
  and normal_heading like 'UCOCLC%'
)
;

create index vger_report.ix_tmp_hathi_base on vger_report.tmp_hathi_base (bib_id, bib_lvl);

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

