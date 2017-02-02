library(ggplot2)
library(doBy)
library(data.table)


data_loader = function(load, ident, cleanup=function(x){x}){
	function(verbose=T, reload=F){
		if(!exists(ident, envir=.GlobalEnv) | reload){
			if(verbose){cat("Could not find cached", ident, "\n")}
			assign(ident, NULL, envir=.GlobalEnv)
		}
		if(is.null(get(ident, envir=.GlobalEnv))){
			if(verbose){cat("Loading", ident, "\n")}
			assign(ident, load(verbose, reload), envir=.GlobalEnv)
		}
		cleanup(get(ident, envir=.GlobalEnv))
	}
}

tsv_loader = function(filename, ident, cleanup=function(x){x}){
	data_loader(
		function(verbose=T, reload=F){
			if(verbose){cat("Loading ", filename, "...")} 
			d = read.table(
				filename, 
				header=T, sep="\t", 
				quote="", comment.char="", 
				na.strings="NULL"
			)
			d = data.table(d)
			if(verbose){cat("DONE!\n")}
			d
		},
		ident,
		cleanup
	)
}

geo.mean = function(x, ...){
	exp(mean(log(x), ...))
}

geo.se.upper = function(x, ...){
	log_mean = mean(log(x), ...)
	log_sd = sd(log(x), ...)
	log_se = log_sd/sqrt(length(x))
	exp(log_mean + log_se)
}
geo.se.lower = function(x, ...){
	log_mean = mean(log(x), ...)
	log_sd = sd(log(x), ...)
	log_se = log_sd/sqrt(length(x))
	exp(log_mean - log_se)
}

geo.mean.plus.one = function(x, ...){
	geo.mean(x+1, ...)-1
}
geo.se.lower.plus.one = function(x){
	geo.se.lower(x+1)-1
}
geo.se.upper.plus.one = function(x){
	geo.se.upper(x+1)-1
}

survival = function(deaths, censoreds=F, unit.size=1){
	data = data.table(
		deaths=deaths,
		censoreds=censoreds
	)
	
	counts = with(
		summaryBy(
			censoreds ~ deaths,
			data=data,
			FUN=c(sum, length)
		),
		data.table(
			time_unit = deaths,
			deaths = censoreds.length - censoreds.sum,
			censored = censoreds.sum,
			population = 0
		)
	)
	setkey(counts, time_unit)
	
	population = sum(counts$deaths + counts$censored)
	for(curr_time in sort(counts$time_unit)){
		counts[time_unit==curr_time,]$population = population
		population = with(
			counts[time_unit==curr_time,],
			population - (deaths + censored)
		)
	}
	
	counts$hazard = with(
		counts,
		deaths/population
	)
	counts$hazard.beta.se.upper = with(
		counts,
		mapply(
			function(deaths, population){
				if(population > 100){
					qbeta(.159, pmax(1,deaths), pmax(1,population-deaths), lower.tail=F)
				}else{
					pmin(1, deaths/population + 0.05)
				}
			},
			deaths, population
		)
	)
	counts$hazard.beta.se.lower = with(
		counts,
		mapply(
			function(deaths, population){
				if(population > 100){
					qbeta(.159, pmax(1,deaths), pmax(1,population-deaths))
				}else{
					pmax(0, deaths/population - 0.05)
				}
			},
			deaths, population
		)
	)
	
	counts
}

