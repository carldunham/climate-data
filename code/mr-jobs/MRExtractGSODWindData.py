#!/usr/bin/python

##----------------------------------------------------------------------
## Copyright (c) 2013 Carl A. Dunham, All Rights Reserved
##----------------------------------------------------------------------
##
## MRExtractGSODWindData.py
##
## Created: 2013-MMM-dd by carl
##
##----------------------------------------------------------------------

"""
Map-Reduce job to extract wind data from the GSOD data set
"""

from mrjob.job import MRJob
import numpy as np


class MRExtractGSODWindData(MRJob):

    def mapper(self, aKey, aLine):

        station = aLine[:6]

        # skip header line and non-US
        #
        if (station != 'STN---') and (690000 <= int(station) <= 749999):
            date = aLine[14:22]
            month = date[:6]
            temp = float(aLine[24:30])
            windspeed = float(aLine[78:83])
            gust = float(aLine[95:100])
            tornado = (aLine[137:138] == '1')

            if temp == 9999.9: temp = None
            if windspeed == 999.9: windspeed = None
            if gust == 999.9: gust = None

            yield [station, month], {"date": date, "temp": temp, "windspeed": windspeed, "gust": gust, "tornado": tornado}

    
    #def combiner(self, word, counts):
    #    yield word, sum(counts)

    
    def reducer(self, aKey, aValueSet):

        station, month = aKey

        values = list(aValueSet)

        stats = {}

        for k in ("temp", "windspeed", "gust"):
            L = [ e[k] for e in values if e[k] is not None ]

            if len(L) > 0:
                stats[k] = { "mean": np.mean(L), "sd": np.std(L), "N": len(L), "min": min(L), "max": max(L) }
            else:
                stats[k] = None

        k = "tornado"
        stats[k] = any([ e[k] for e in values ])
        stats["N"] = len(values)
        
        yield aKey, stats


if __name__ == "__main__":
    MRExtractGSODWindData.run()
