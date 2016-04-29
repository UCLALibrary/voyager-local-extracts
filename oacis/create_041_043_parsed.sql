
/*	Many MARC records store multiple language codes concatenated in 041 $a,
	instead of one code per $a as current MARC21 specs require.
	This script reads through all 041 $a in ucladb_bib_subfield,
	chops the multi-code values into single ones and stores all in a separate table.
	Since all language codes are defined as 3 characters,
	any 041 $a with a length not a multiple of 3 probably has invalid data (often just
	a space at the end, but sometimes just bad data).
	Any data beyond the final multiple of 3 is not captured by this process.

	Takes about 5 minutes to run; creates about 630,000 rows (as of 2006-12-14).

	Created: 2006-12-14 akohler
*/

DROP TABLE vger_subfields.f041a_parsed;

CREATE TABLE vger_subfields.f041a_parsed
(	bib_id INT NOT NULL
,	lang_code CHAR(3) NOT NULL
)
/

DECLARE
	subfield vger_subfields.ucladb_bib_subfield.subfield%TYPE;
	len INT;
	pos INT;

	CURSOR c IS
		SELECT record_id, subfield
		FROM vger_subfields.ucladb_bib_subfield
		WHERE tag = '041a'
		;

BEGIN
	FOR row_data IN c LOOP
		-- clean up some bad data by removing spaces
		subfield := REPLACE(row_data.subfield, ' ', '');
		len := Length(subfield);
		pos := 1;
		WHILE pos <= (len - 2) LOOP
			INSERT INTO vger_subfields.f041a_parsed (bib_id, lang_code) VALUES (row_data.record_id, Lower(SubStr(row_data.subfield, pos, 3)));
			pos := pos + 3;
		END LOOP;
	END LOOP;
END;
/

CREATE INDEX vger_subfields.ix_f041a_parsed ON vger_subfields.f041a_parsed (bib_id, lang_code);
GRANT SELECT ON vger_subfields.f041a_parsed TO PUBLIC;

/*
SELECT lang_code, Count(*) FROM f041_parsed GROUP BY lang_code ORDER BY lang_code;
*/

DROP TABLE vger_subfields.f043a_parsed;

CREATE TABLE vger_subfields.f043a_parsed AS
SELECT
	record_id AS bib_id
,	SubStr(subfield, 1, 7) AS gac_code
FROM vger_subfields.ucladb_bib_subfield
WHERE tag = '043a';

CREATE INDEX vger_subfields.ix_f043a_parsed ON vger_subfields.f043a_parsed (bib_id, gac_code);
GRANT SELECT ON vger_subfields.f043a_parsed TO PUBLIC;

