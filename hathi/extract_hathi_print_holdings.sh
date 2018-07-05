#!/bin/sh

# Get voyager environment, for vars and for cron
. `echo $HOME | sed "s/$LOGNAME/voyager/"`/.profile.local

DATE=`date "+%Y%m%d"` #YYYYMMDD
SCHEMA=vger_report

echo Creating supporting tables: create_tmp_clu_export_tables.sql...
${VGER_SCRIPT}/vger_sqlplus_run ${SCHEMA} create_tmp_clu_export_tables.sql

echo Creating supporting tables: create_tmp_hathi_base_table.sql...
${VGER_SCRIPT}/vger_sqlplus_run ${SCHEMA} create_tmp_hathi_base_table.sql

for FILE in srlf*.sql ucla*.sql; do
  echo Running ${FILE}...
  ${VGER_SCRIPT}/vger_sqlplus_run vger_report ${FILE}
  mv ${FILE}.out `basename ${FILE}.out .sql.out`_${DATE}.tsv
done

echo Counting records in files...
wc -l *.tsv

echo Combining files...
cat [su]*_serials*.tsv >> combined_serials_${DATE}.tsv
cat [su]*_multi-part*.tsv >> combined_multi-part_${DATE}.tsv
cat [su]*_single-part*.tsv >> combined_single-part_${DATE}.tsv
rm [su]*.tsv

echo Creating archive...
zip -9 ucla_hathi_${DATE}.zip combined*.tsv

echo If all OK, upload zip file to box.com
echo and notify Hathi and CDL.
echo See https://docs.library.ucla.edu/x/SJmqBw

echo Dropping supporting tables...
${VGER_SCRIPT}/vger_sqlplus_run ${SCHEMA} drop_tmp_hathi_tables.sql
