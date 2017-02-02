source("loader/all_loads.R")

loads = load_all_loads(reload=T)
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

readers = loads[,
	list(
		total_loads = max(event_loadIndex)
	),
	event_experimentId
]

quantile(readers$total_loads, c(.50, .90, .95, .99))
#50% 90% 95% 99% 
#  2   10  18  57 

readers$quantile = "00% (1)"
readers[total_loads >= 2  & total_loads < 10,]$quantile = "50% (2-10)"
readers[total_loads >= 10 & total_loads < 18,]$quantile = "90% (10-18)"
readers[total_loads >= 18 & total_loads < 57,]$quantile = "95% (18-57)"
readers[total_loads >= 57,]$quantile = "99% (57-)"
readers$quantile = as.factor(readers$quantile)

reader_loads = merge(
	loads,
	readers,
	by="event_experimentId"
)


svg("all_loads/plots/exploration/load_time.geo_mean.by_quantile.svg",
	height=5,
	width=7)
ggplot(
	reader_loads[
		event_loadIndex < 20,
		list(
			load_time.geo_mean = geo.mean.plus.one(pmax(0, event_moduleLoadingTime)),
			load_time.geo_se.lower = geo.se.lower.plus.one(pmax(0, event_moduleLoadingTime)),
			load_time.geo_se.upper = geo.se.upper.plus.one(pmax(0, event_moduleLoadingTime))
		),
		list(event_loadIndex, quantile)
	],
	aes(
		x=event_loadIndex,
		y=load_time.geo_mean/1000,
		group=quantile,
		linetype=quantile
	)
) + 
geom_line() + 
geom_errorbar(
	aes(
		ymax=load_time.geo_se.upper/1000,
		ymin=load_time.geo_se.lower/1000
	),
	width=0.25,
	color="#555555",
	linetype=1
) + 
geom_point(
	size=.5
) + 
theme_bw() + 
theme(
	legend.direction = "horizontal", 
	legend.position = "top"
) + 
scale_y_continuous("Geometric mean load time (seconds)") + 
scale_x_continuous("Load index") + 
scale_linetype_discrete("Loads quantile")
dev.off()

merge(
	merge(
		reader_loads[
			event_loadIndex < 20 & quantile== "00% (1)",
			list(
				"00% (1)" = geo.mean.plus.one(pmax(0, event_moduleLoadingTime))
			),
			list(event_loadIndex)
		],
		reader_loads[
			event_loadIndex < 20 & quantile== "50% (2-10)",
			list(
				"50% (2-10)" = geo.mean.plus.one(pmax(0, event_moduleLoadingTime))
			),
			list(event_loadIndex)
		],
		by="event_loadIndex",
		all=T
	),
	merge(
		reader_loads[
			event_loadIndex < 20 & quantile== "90% (10-18)",
			list(
				"90% (10-18)" = geo.mean.plus.one(pmax(0, event_moduleLoadingTime))
			),
			list(event_loadIndex)
		],
		merge(
			reader_loads[
				event_loadIndex < 20 & quantile== "95% (18-57)",
				list(
					"95% (18-57)" = geo.mean.plus.one(pmax(0, event_moduleLoadingTime))
				),
				list(event_loadIndex)
			],
			reader_loads[
				event_loadIndex < 20 & quantile== "99% (57-)",
				list(
					"99% (57-)" = geo.mean.plus.one(pmax(0, event_moduleLoadingTime))
				),
				list(event_loadIndex)
			],
			by="event_loadIndex",
			all=T
		),
		by="event_loadIndex",
		all=T
	),
	by="event_loadIndex",
	all=T
)


svg("all_loads/plots/exploration/load_time.density.non-mobile.by_browser.svg",
	height=7,
	width=15)
g=ggplot(
	loads[
		simple_platform != "Android" & 
		simple_platform != "iOS" & 
		simple_platform != "Blackberry" & 
		event_loadIndex <= 2 & 
		!is.na(simple_browser),
	],
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
scale_x_log10(
	"Load time in seconds",
	limits=c(.1, 10^2),
	breaks=c(10^(-1:2))
) + 
scale_fill_discrete("Load index") +
theme_bw() + 
facet_wrap(~ group + simple_browser, nrow=2)
print(g)
dev.off()

svg("all_loads/plots/exploration/load_time.density.mobile.by_browser.svg",
	height=7,
	width=9.96)
g=ggplot(
	loads[
		(
			simple_platform == "Android" |
			simple_platform == "iOS" |
			simple_platform == "Blackberry"
		) & 
		event_loadIndex <= 2 & 
		simple_browser != "Maxthon" & 
		simple_browser != "Safari" & 
		simple_browser != "Silk" & 
		!is.na(simple_browser),
	],
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
scale_x_log10(
	"Load time in seconds",
	limits=c(.1, 10^2),
	breaks=c(10^(-1:2))
) + 
scale_fill_discrete("Load index") +
theme_bw() + 
facet_wrap(~ group + simple_browser, nrow=2)
print(g)
dev.off()

loads$platform_type = "Unknown"
loads[
	simple_platform == "Android" |
	simple_platform == "iOS" |
	simple_platform == "Blackberry",
]$platform_type = "Mobile"
loads[
	is.na(simple_platform) | 
	(
		simple_platform != "Android" &
		simple_platform != "iOS" &
		simple_platform != "Blackberry"
	),
]$platform_type = "Non-mobile"
loads$platform_type = as.factor(loads$platform_type)

loads$platform_type_group = paste(loads$platform_type, loads$group)

svg("all_loads/plots/exploration/load_time.geo_mean.by_platform_type_group.svg",
	height=5,
	width=7)
ggplot(
	loads[
		event_loadIndex < 20,
		list(
			load_time.geo_mean = geo.mean.plus.one(pmax(0, event_moduleLoadingTime)),
			load_time.geo_se.lower = geo.se.lower.plus.one(pmax(0, event_moduleLoadingTime)),
			load_time.geo_se.upper = geo.se.upper.plus.one(pmax(0, event_moduleLoadingTime))
		),
		list(event_loadIndex, platform_type, group)
	],
	aes(
		x=event_loadIndex,
		y=load_time.geo_mean/1000,
		linetype=platform_type,
		shape=group
	)
) + 
geom_line() + 
geom_errorbar(
	aes(
		ymax=load_time.geo_se.upper/1000,
		ymin=load_time.geo_se.lower/1000
	),
	width=0.25,
	color="#555555",
	linetype=1
) + 
geom_point(
) + 
theme_bw() + 
scale_y_continuous("Geometric mean load time (seconds)",breaks=1:7) + 
scale_x_continuous("Load index", limits=c(0, 19)) + 
scale_linetype_discrete("Platform type")
dev.off()

ifor = function(x, ifval, orval){
	sapply(
		x,
		function(x){
			if(x){
				ifval
			}else{
				orval
			}
		}
	)
}


svg("all_loads/plots/exploration/load_time.geo_mean.cached_vs_not.svg",
	height=3,
	width=4)
ggplot(
	loads[
		event_loadIndex < 20,
		list(
			load_time.geo_mean = geo.mean.plus.one(pmax(0, event_moduleLoadingTime)),
			load_time.geo_se.lower = geo.se.lower.plus.one(pmax(0, event_moduleLoadingTime)),
			load_time.geo_se.upper = geo.se.upper.plus.one(pmax(0, event_moduleLoadingTime))
		),
		list(
			cached = factor(ifor(event_loadIndex > 1, "cached", "not cached"), levels=c("not cached", "cached")), group
		)
	],
	aes(
		x=cached,
		y=load_time.geo_mean/1000,
		group=cached + group,
		shape=group
	)
) + 
geom_errorbar(
	aes(
		ymax=load_time.geo_se.upper/1000,
		ymin=load_time.geo_se.lower/1000
	),
	width=0.2,
	color="#555555"
) + 
geom_point(
	size=3
) + 
theme_bw() + 
scale_y_continuous("Geo mean load time (seconds)") + 
scale_x_discrete("") + 
scale_linetype_discrete("Condition")
dev.off()

gmean.loads = rbind(
	loads[
		event_loadIndex <= 2,
		list(
			load_time = geo.mean.plus.one(pmax(0, event_moduleLoadingTime)),
			n = length(event_moduleLoadingTime),
			platform_type = "Overall"
		),
		list(
			cached = event_loadIndex > 1, 
			group
		)
	],
	loads[
		event_loadIndex <= 2,
		list(
			load_time = geo.mean.plus.one(pmax(0, event_moduleLoadingTime)),
			n = length(event_moduleLoadingTime)
		),
		list(
			cached = event_loadIndex > 1, 
			group,
			platform_type = as.character(platform_type)
		)
	]
)

merge(
	gmean.loads[group == "test", list(platform_type, cached, "test"=load_time),],
	gmean.loads[group == "control", list(platform_type, cached, "control"=load_time),],
	by=c("cached", "platform_type")
)[,
	list(
		platform_type,
		cached,
		control=round(control),
		test=round(test),
		diff=round((test-control))
	),
][order(platform_type, cached),]





chrome.gmean.loads = loads[
	event_loadIndex <= 6 & simple_browser == "Chrome",
	list(
		load_time = geo.mean.plus.one(pmax(0, event_moduleLoadingTime)),
		n = length(event_moduleLoadingTime)
	),
	list(
		event_loadIndex, 
		group,
		platform_type = as.character(platform_type)
	)
]

merge(
	chrome.gmean.loads[group == "test", list(platform_type, event_loadIndex, "test"=load_time),],
	chrome.gmean.loads[group == "control", list(platform_type, event_loadIndex, "control"=load_time),],
	by=c("event_loadIndex", "platform_type")
)[,
	list(
		platform_type,
		event_loadIndex,
		control=round(control),
		test=round(test),
		diff=round((test-control))
	),
][order(platform_type, event_loadIndex),]