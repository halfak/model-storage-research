source("util.R")
source("env.R")

load_sampled_loads = tsv_loader(
	paste(DATA_DIR, "sampled_loads.tsv", sep="/"),
	"SAMPLED_LOADS"
)