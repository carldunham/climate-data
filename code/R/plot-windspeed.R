#!/usr/bin/R64

#--------------------------------------------------------------------------------
#
# plot-windspeed.R
#
# 2013-09-30
#
# Plot variations of windspeed in the continental US over time
#
#--------------------------------------------------------------------------------

# libraries
#
library(sp)
library(maptools)
gpclibPermit()
library(gstat)


# params
#
fn.dir.raw = '../../data/raw/'
fn.dir.geo = '../../data/geo/'
    
fn.in = paste0(fn.dir.raw, '2013-09-27-1612.csv')
fn.stations = paste0(fn.dir.raw, 'ish-history.csv')
fn.contus = paste0(fn.dir.geo, 'contus/contus')

# read data
#
cat('reading...')

if (!exists("geo.contus")) {
    geo.contus = readShapePoly(fn.contus)
}

if (!exists("data.us.cont")) {
    data.raw = read.csv(fn.in, header=T)
    data.stations = read.csv(fn.stations, header=T)

    # join
    cat('joining...')

    data.all = merge(x=data.raw, y=data.stations, by.x='station', by.y='USAF', all.x=T)

    # clean and extract
    #
    cat('cleaning...')

    data.clean = data.all[!is.na(data.all$LAT) & !is.na(data.all$LON) & (data.all$LAT > -99999) & (data.all$LON > -999999),]
    #data.us = data.clean[data.clean$CTRY == 'US',]
    data.us.cont = data.clean[data.clean$CTRY == 'US' & data.clean$STATE != 'AK' & data.clean$STATE != 'HI' & data.clean$LON < 0,]

    # convert to spatial object
    #
    data.us.cont$LAT = data.us.cont$LAT / 1000.0
    data.us.cont$LON = data.us.cont$LON / 1000.0

    coordinates(data.us.cont) = c('LON', 'LAT')

    rm(data.raw, data.stations)
}

# loop over each month
#
months = sort(unique(data.us.cont$month))[1]

lat.range = c(24.5, 49.5) # range(d.pred.non.zero$lat) # range(map.data$Y) # 
lon.range = c(-125, -66.5) # range(d.pred.non.zero$lon) # range(map.data$X) #

field.to.plot = 'windspeed.sd'
col.length = 12
col.data = topo.colors(col.length, alpha=0.5) # c("black", "blue", "green", "magenta", "yellow", "purple", "red", "pink") # 
breaks.data = c(0, 1.25, 1.5, 1.75, 2.0, 2.25, 2.5, 2.75, 3.0, 3.5, 4.0, 8.0, 100.0)
#breaks.data = seq(from=min(data.us.cont[[field.to.plot]], na.rm=T), to=max(data.us.cont[[field.to.plot]], na.rm=T), length.out=col.length+1)

cat('plotting...')

for (m in months) {
    data.m = data.us.cont[(data.us.cont$month == m) & (!is.na(data.us.cont[[field.to.plot]])),]
    data.grid = spsample(data.m, "regular", n=100000)
    gridded(data.grid) = TRUE
    data.idw = idw(as.formula(paste(field.to.plot, "~1")), data.m, newdata=data.grid, idp=2.0, debug.level=0)

    # render
    #
    cat(paste0(m, '...'))

    image(matrix(0), col="white", axes=F, main=field.to.plot, ylim=lat.range, xlim=lon.range)

    cat('[map]...')

    plot(geo.contus, add=T)

    cat('[data]...')

    #spplot(data.idw$var1.pred, col=col.data, breaks=breaks.data, main=field.to.plot, add=T)
    image(data.idw, "var1.pred", col=col.data, breaks=breaks.data, add=T)
    #contour(data.idw, "var1.pred", add=T)

    cat('[tornadoes]...')

    plot(data.m[data.m$tornado,], col='red', add=T)
}

# clean up
#
rm(fn.dir.raw, fn.dir.geo, fn.in, fn.stations, fn.contus, field.to.plot, col.length, col.data, breaks.data, months, lat.range, lon.range, m, data.m, data.grid, data.idw)

cat('done.\n')
