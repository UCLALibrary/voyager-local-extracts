set linesize 32767
set trimspool on
set trimout on

select distinct
    bt.bib_id || chr(9)
||  bt.field_008
from bib_text bt
inner join bib_mfhd bm on bt.bib_id = bm.bib_id
inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
inner join mfhd_item mi on mm.mfhd_id = mi.mfhd_id
where (l.location_code in ('sr', 'srbuo') or l.location_code like 'srucl%')
;
