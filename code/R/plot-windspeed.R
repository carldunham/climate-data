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


# params
#
fn.dir = '../../data/raw/'

fn.in = paste0(fn.dir, '2013-09-27-1612.csv')
fn.stations = paste0(fn.dir, 'ish-history.csv')


# read data
#
cat('reading...')

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
coordinates(data.us.cont) = c('LON', 'LAT')

# render
#
cat('plotting...')


plot(data.us.cont)
plot(data.us.cont[data.us.cont$tornado,], col='red', add=T)

# clean up
#
rm(fn.dir, fn.in, fn.stations, data.raw, data.stations)

cat('done.\n')
