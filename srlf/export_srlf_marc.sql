set linesize 10
set trimspool on
set trimout on

select distinct
    bm.bib_id
from bib_mfhd bm 
inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
inner join mfhd_item mi on mm.mfhd_id = mi.mfhd_id
where (l.location_code in ('sr', 'srbuo') or l.location_code like 'srucl%')
order by bm.bib_id
;
