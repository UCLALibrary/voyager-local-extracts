LOAD DATA
CHARACTERSET UTF8
TRUNCATE
INTO TABLE vger_report.tmp_gbs_import
FIELDS TERMINATED BY x'09'
TRAILING NULLCOLS
(
  bib_id 
, bib_level
, date_type
, date1
, date2
, pub_place
, gov_doc
, gpo_item_no
, sudoc_no
, f099a
-- Truncate these 6 fields on input
, author char(9999) "substr(:author, 1, 100)"
, f245a char(9999) "substr(:f245a, 1, 100)"
, f245b char(9999) "substr(:f245b, 1, 100)"
, f26xa char(9999) "substr(:f26xa, 1, 100)"
, f26xb char(9999) "substr(:f26xb, 1, 100)"
, f26xc char(9999) "substr(:f26xc, 1, 100)"
, loc_code
, call_number
, item_enum
, item_barcode
)
