LOAD DATA
CHARACTERSET UTF8
TRUNCATE
INTO TABLE vger_report.gbs_candidates
FIELDS TERMINATED BY x'09'
TRAILING NULLCOLS
( bib_id
, pub_date
, author char(1500)
, title char(1500)
, subtitle char(1500)
, call_number
, enum_chron
, barcode
, priority
, location_code FILLER
)

