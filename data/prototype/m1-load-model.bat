@echo off
call %~dp0../../admin/config.bat

%PGBIN%\psql -x -c "SELECT m1_model.gen_load_model(admin.loadfile('%~dp0m1-model.xml'));"
%PGBIN%\psql -x -c "SELECT m1_model.gen_copy_model_to_data();"

%PGBIN%\psql -x -c "VACUUM FULL ANALYZE m1_data.element_types;"
%PGBIN%\psql -x -c "VACUUM FULL ANALYZE m1_data.element_types_relations;"

