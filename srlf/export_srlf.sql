set linesize 32767
set trimspool on
set trimout on

select
    bib_id || chr(9)
||  bib_format || chr(9)
||  field_008 || chr(9)
||  isbn_or_issn || chr(9)
||  oclc || chr(9)
||  author || chr(9)
||  title || chr(9)
||  edition || chr(9)
||  imprint || chr(9)
||  f300a || chr(9)
||  language || chr(9)
||  location_code || chr(9)
||  location_name || chr(9)
||  mfhd_id || chr(9)
||  item_id || chr(9)
||  item_barcode || chr(9)
||  item_enum || chr(9)
||  item_type_name || chr(9)
||  freetext || chr(9)
||  item_status_desc || chr(9)
||  item_status_date 
from vger_report.tmp_srlf_rr136
order by bib_format, lpad(oclc, 9, '0'), bib_id, mfhd_id, item_enum
;

