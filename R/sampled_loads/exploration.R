source("loader/sampled_loads.R")

loads = load_sampled_loads(reload=T)

loads$event_loadIndex.factor = as.factor(loads$event_loadIndex)
loads$group = as.factor(
	sapply(
		loads$event_experimentGroup,
		function(group){
			if(group == 1){
				"control"
			}else if(group == 2){
				"test"
			}
		}
	)
)

svg("sampled_loads/plots/exploration/load_time.density.by_group.svg",
	height=6,
	width=7)
ggplot(
	loads,
	aes(
		x=log2(event_moduleLoadingTime), 
		group=event_loadIndex.factor, 
		fill=event_loadIndex.factor
	)
) + 
geom_density(
	alpha=0.2,
	color="#000000"
) + 
facet_wrap(~ group, ncol=1) + 
theme_bw() + 
scale_x_continuous(
	"Loading time (log scaled)",
	breaks=log2(c(1000, 5000, 10000, 30000)),
	labels=c("1", "5", "10", "30")
)
dev.off()


svg("sampled_loads/plots/exploration/load_time.geo_mean.by_group.svg",
	height=6,
	width=7)
ggplot(
	loads[,
		list(
			load_time.geo_mean = geo.mean.plus.one(pmax(0, event_moduleLoadingTime)),
			load_time.geo_se.lower = geo.se.lower.plus.one(pmax(0, event_moduleLoadingTime)),
			load_time.geo_se.upper = geo.se.upper.plus.one(pmax(0, event_moduleLoadingTime))
		),
		list(group, event_loadIndex=event_loadIndex.factor)
	],
	aes(
		x=event_loadIndex,
		y=load_time.geo_mean/1000,
		group=group,
		linetype=group
	)
) + 
geom_line() + 
geom_errorbar(
	aes(
		ymax=load_time.geo_se.upper/1000,
		ymin=load_time.geo_se.lower/1000
	),
	width=0.5,
	color="black",
	linetype=1
) + 
geom_point(
) + 
theme_bw() + 
scale_y_continuous("Geometric mean load time (seconds)") + 
scale_x_discrete("Load index")
dev.off()

merge(
	loads[
		group == "test",
		list(
			load_time = geo.mean.plus.one(pmax(0, event_moduleLoadingTime))
		),
		list(event_loadIndex=event_loadIndex.factor)
	],
	loads[
		group == "control",
		list(
			load_time = geo.mean.plus.one(pmax(0, event_moduleLoadingTime))
		),
		list(event_loadIndex=event_loadIndex.factor)
	],
	by="event_loadIndex",
	suffixes=c(".test", ".control")
)[,
	list(
		event_loadIndex, 
		test=load_time.test/1000, 
		control=load_time.control/1000, 
		diff = (load_time.test-load_time.control)/1000
	),
]

svg("sampled_loads/plots/exploration/load_time.desnity.by_browser_and_event_loadIndex.svg",
	height=15,
	width=7)
g=ggplot(
	loads[event_loadIndex <= 2 & !is.na(simple_browser),],
	aes(
		x=pmax(0, event_moduleLoadingTime)/1000, 
		group=as.factor(event_loadIndex), 
		fill=as.factor(event_loadIndex)
	)
) +  
geom_density(
	alpha=0.2,
	color="black"
) + 
geom_vline(stat="mean", aes(x=mean(pmax(0, event_moduleLoadingTime)/1000)) + 
scale_x_log10(
	"Load time in seconds",
	limits=c(.1, 10^2),
	breaks=c(10^(-1:2))
) + 
scale_fill_discrete("Load index") +
theme_bw() + 
facet_wrap(~ simple_browser + group, ncol=2)
print(g)
dev.off()

median.load_times = loads[
	event_loadIndex <= 1 & !is.na(simple_browser) & is.finite(event_moduleLoadingTime),
	list(
		median = as.double(median(event_moduleLoadingTime)),
		n = length(id)
	),
	by=list(platform=simple_platform, browser=simple_browser, group, event_loadIndex)
]
load_times = merge(
	median.load_times[event_loadIndex==0,list(platform, browser, group, median_0=median, n_0=n),],
	median.load_times[event_loadIndex==1,list(platform, browser, group, median_1=median, n_1=n),],
	by=c("platform", "browser", "group")
)
load_times$diff = load_times$median_1 - load_times$median_0
load_times[n_0>100,order(load_times$platform, load_times$browser, load_times$group),]



svg("sampled_loads/plots/exploration/load_time.geo_mean.by_group.gt_10.svg",
	height=6,
	width=7)
ggplot(
	loads[
		max_event_loadIndex >= 9,
		list(
			load_time.geo_mean = geo.mean.plus.one(pmax(0, event_moduleLoadingTime)),
			load_time.geo_se.lower = geo.se.lower.plus.one(pmax(0, event_moduleLoadingTime)),
			load_time.geo_se.upper = geo.se.upper.plus.one(pmax(0, event_moduleLoadingTime))
		),
		list(group, event_loadIndex=event_loadIndex.factor)
	],
	aes(
		x=event_loadIndex,
		y=load_time.geo_mean/1000,
		group=group,
		linetype=group
	)
) + 
geom_line() + 
geom_errorbar(
	aes(
		ymax=load_time.geo_se.upper/1000,
		ymin=load_time.geo_se.lower/1000
	),
	width=0.5,
	color="black",
	linetype=1
) + 
geom_point(
) + 
theme_bw() + 
scale_y_continuous("Geometric mean load time (seconds)") + 
scale_x_discrete("Load index")
dev.off()


svg("sampled_loads/plots/exploration/load_time.geo_mean.by_chrome.svg",
	height=6,
	width=7)
ggplot(
	loads[
		event_loadIndex <= 19,
		list(
			load_time.geo_mean = geo.mean.plus.one(pmax(0, event_moduleLoadingTime)),
			load_time.geo_se.lower = geo.se.lower.plus.one(pmax(0, event_moduleLoadingTime)),
			load_time.geo_se.upper = geo.se.upper.plus.one(pmax(0, event_moduleLoadingTime))
		),
		list(event_loadIndex=event_loadIndex.factor, chrome=!is.na(simple_browser) & simple_browser=="Chrome")
	],
	aes(
		x=event_loadIndex,
		y=load_time.geo_mean/1000,
		group=chrome,
		linetype=chrome
	)
) + 
geom_line() + 
geom_errorbar(
	aes(
		ymax=load_time.geo_se.upper/1000,
		ymin=load_time.geo_se.lower/1000
	),
	width=0.5,
	color="black",
	linetype=1
) + 
geom_point(
) + 
theme_bw() + 
scale_y_continuous("Geometric mean load time (seconds)") + 
scale_x_discrete("Load index")
dev.off()