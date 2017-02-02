
datasets/indexed_loads.table: sql/indexed_loads.table.sql
	cat sql/indexed_loads.table.sql | \
	mysql -h db1047.eqiad.wmnet halfak > \
	datasets/indexed_loads.table

datasets/extracted_user_agents.create: sql/extracted_user_agents.create.sql
	cat sql/extracted_user_agents.create.sql | \
	mysql -h db1047.eqiad.wmnet halfak > \
	datasets/extracted_user_agents.create

datasets/extracted_user_agents.no_header.tsv: datasets/indexed_loads.table \
                                              datasets/extracted_user_agents.create \
                                              ms/extract_ua.py
	mysql -h db1047.eqiad.wmnet halfak -e "SELECT id, event_userAgent FROM halfak.ms_indexed_load" | \
	./extract_ua > datasets/extracted_user_agents.no_header.tsv
	
datasets/extracted_user_agents.table: datasets/extracted_user_agents.no_header.tsv
	ln -sf extracted_user_agents.no_header.tsv datasets/ms_extracted_user_agent && \
	mysql -h db1047.eqiad.wmnet halfak -e "TRUNCATE TABLE ms_extracted_user_agent;" && \
	mysqlimport --local -h db1047.eqiad.wmnet halfak datasets/ms_extracted_user_agent && \
	rm -f datasets/ms_extracted_user_agent && \
	mysql -h db1047.eqiad.wmnet halfak -e "SELECT COUNT(*), NOW() FROM ms_extracted_user_agent;" > \
	datasets/extracted_user_agents.table

datasets/user_max_index.table: sql/user_max_index.table.sql \
                               datasets/indexed_loads.table
	cat sql/user_max_index.table.sql | \
	mysql -h db1047.eqiad.wmnet halfak > \
	datasets/user_max_index.table

datasets/load_simple_ua.table: sql/load_simple_ua.table.sql \
                               datasets/extracted_user_agents.table
	cat sql/load_simple_ua.table.sql | \
	mysql -h db1047.eqiad.wmnet halfak > \
	datasets/load_simple_ua.table

datasets/all_loads.tsv: datasets/indexed_loads.table \
                            datasets/load_simple_ua.table \
                            datasets/user_max_index.table \
                            sql/all_loads.sql
	cat sql/all_loads.sql | \
	mysql -h db1047.eqiad.wmnet > \
	datasets/all_loads.tsv
