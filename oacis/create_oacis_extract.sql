/*	Create data to support extract of records for OACIS (Yale union catalog of middle eastern materials)
	Requires previous run of Create_041_043_parsed.sql, to get extra language/place info.
	UCLA Library contact: David Hirsch
*/

DROP TABLE vger_report.oacis_extract;

CREATE TABLE vger_report.oacis_extract AS
SELECT /*+ ORDERED */
	bt.bib_id
,	bt.language
,	mm.mfhd_id
,	mm.suppress_in_opac
FROM ucladb.bib_text bt
INNER JOIN ucladb.bib_master bms ON bt.bib_id = bms.bib_id
INNER JOIN ucladb.bib_mfhd bm ON bt.bib_id = bm.bib_id
INNER JOIN ucladb.mfhd_master mm ON bm.mfhd_id = mm.mfhd_id
WHERE bt.bib_format LIKE '%s'
AND bms.suppress_in_opac = 'N'
AND	(
	bt.language IN
	(	'abk', 'ara', 'arm', 'ava', 'ave', 'aze', 'bak', 'ber', 'bua', 'cau'
	,	'che', 'chg', 'chm', 'chv', 'fiu', 'geo', 'ira', 'kaa', 'kab', 'kaz'
	,	'kir', 'kom', 'kum', 'kur', 'lez', 'oss', 'ota', 'pal', 'peo', 'per'
	,	'pus', 'sah', 'sel', 'sog', 'tat', 'tgk', 'tuk', 'tur', 'tut', 'tyv'
	,	'uig', 'uzb'
	)
	OR
	bt.place_code IN
	(	'ae', 'af', 'ai', 'air', 'aj', 'ajr', 'ba', 'cq', 'cy', 'ft'
	,	'gs', 'gsr', 'gz', 'iq', 'ir', 'iy', 'jo', 'kg', 'kgr', 'ku'
	,	'kz', 'kzr', 'le', 'ly', 'mk', 'mr', 'mu', 'pk', 'qa', 'sj'
	,	'so', 'su', 'sy', 'ta', 'tar', 'ti', 'tk', 'tkr', 'ts', 'tu'
	,	'ua', 'uz', 'uzr', 'wj', 'ye', 'ys'
	)
	OR
	EXISTS
	(	SELECT *
		FROM vger_subfields.f041a_parsed
		WHERE bib_id = bt.bib_id
		AND lang_code IN
		(	'abk', 'ara', 'arm', 'ava', 'ave', 'aze', 'bak', 'ber', 'bua', 'cau'
		,	'che', 'chg', 'chm', 'chv', 'fiu', 'geo', 'ira', 'kaa', 'kab', 'kaz'
		,	'kir', 'kom', 'kum', 'kur', 'lez', 'oss', 'ota', 'pal', 'peo', 'per'
		,	'pus', 'sah', 'sel', 'sog', 'tat', 'tgk', 'tuk', 'tur', 'tut', 'tyv'
		,	'uig', 'uzb'
		) -- same set as bt.language
	)
	OR
	EXISTS
	(	SELECT *
		FROM vger_subfields.f043a_parsed
		WHERE bib_id = bt.bib_id
		AND gac_code IN
		(	'a-af', 'a-ai', 'a-aj', 'a-ba', 'a-cy', 'a-gs', 'a-iq', 'a-ir', 'a-jo', 'a-kg'
		,	'a-ku', 'a-kz', 'a-le', 'a-mk', 'a-pk', 'a-qa', 'a-su', 'a-sy', 'a-ta', 'a-tk'
		,	'a-ts', 'a-tu', 'a-uz', 'a-ye', 'a-ys', 'ap', 'ar', 'au', 'aw', 'awba', 'awgz'
		,	'awiu', 'awiw', 'awiy', 'e-ur-gs', 'e-ur-kg', 'e-ur-kz', 'e-ur-ta', 'e-ur-tk'
		,	'e-ur-uz', 'f-ae', 'f-cd', 'f-ft', 'f-ly', 'f-mr', 'f-mu', 'f-sh', 'f-sj', 'f-so'
		,	'f-ss', 'f-ti', 'f-ua', 'fd', 'ff', 'fl', 'fn', 'fq', 'fu', 'i-cq', 'ma'
		)
	)
)
;

GRANT SELECT ON vger_report.oacis_extract TO ucla_preaddb;

