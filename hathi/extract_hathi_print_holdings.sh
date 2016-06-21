#!/bin/sh

DATE=`date "+%Y%m%d"` #YYYYMMDD
SCHEMA=vger_report
BIN=/opt/local/bin

echo Creating supporting tables: create_tmp_clu_export_tables.sql...
$BIN/vger_sqlplus_run $SCHEMA create_tmp_clu_export_tables.sql

echo Creating supporting tables: create_tmp_hathi_base_table.sql...
$BIN/vger_sqlplus_run $SCHEMA create_tmp_hathi_base_table.sql

for FILE in srlf*.sql ucla*.sql; do
  echo Running $FILE...
  $BIN/vger_sqlplus_run vger_report $FILE
  mv $FILE.out `basename $FILE.out .sql.out`_$DATE.tsv
done

echo Counting records in files...
wc -l *.tsv

echo Creating archives...
zip -9 srlf_hathi_$DATE.zip srlf*.tsv
zip -9 ucla_hathi_$DATE.zip ucla*.tsv

echo If all OK, upload zip files to box.com
echo and notify Hathi and CDL.
echo See https://docs.library.ucla.edu/x/SJmqBw

echo Dropping supporting tables...
$BIN/vger_sqlplus_run $SCHEMA drop_tmp_hathi_tables.sql
