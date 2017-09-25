create table vger_report.tmp_west_serials as
with west_mfhds as (
  select record_id as mfhd_id
  from vger_subfields.ucladb_mfhd_subfield
  where tag = '583f'
  and subfield = 'WEST'
)
, west_bibs as (
  select bib_id
  from ucladb.bib_mfhd
  where mfhd_id in (
    select mfhd_id from west_mfhds
  )
)
select
  bm.bib_id
, bm.mfhd_id
, l.location_code
from ucladb.bib_text bt
inner join ucladb.bib_mfhd bm on bt.bib_id = bm.bib_id
inner join ucladb.bib_master br on bt.bib_id = br.bib_id
inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
where bt.bib_format = 'as'
and substr(bt.field_008, 24, 1) = ' ' -- form of item is not non-print
and substr(bt.field_008, 29, 1) in (' ', 'u', '|') -- not gov doc, or can't tell
and not exists (
  select *
  from vger_subfields.ucladb_bib_subfield
  where record_id = bt.bib_id
  and (tag like '074%' or tag like '086%')
) -- filter out other gov docs not caught via 008
and l.location_code != 'in' -- no internet holdings
and upper(l.location_display_name) not like '%MICRO%' -- no microforms
and br.suppress_in_opac = 'N'
and mm.suppress_in_opac = 'N'
and l.suppress_in_opac = 'N'
and not exists (
  select *
  from west_bibs
  where bib_id = bm.bib_id
)
;
create index vger_report.ix_tmp_west_loc on vger_report.tmp_west_serials (location_code);

