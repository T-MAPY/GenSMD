set PATH=%PATH%;"c:\Program Files (x86)\PostgreSQL\9.4\bin"

psql gensmd < src/utils/functions/glob.sql
psql gensmd < src/utils/functions/loadfile.sql
psql gensmd < src/utils/functions/restoreobjects.sql