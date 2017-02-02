source("util.R")
source("env.R")

load_all_loads = tsv_loader(
	paste(DATA_DIR, "all_loads.tsv", sep="/"),
	"ALL_LOADS"
)
