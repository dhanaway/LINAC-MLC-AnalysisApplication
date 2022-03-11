"""
Created 2017
Edits 2019

@author: Helen and Dalton Hanaway
"""
import argparse
import csv
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
from numpy import trapz
import pdb
import glob
from graphics import *
import re
from statistics import *
import sys
import os

def moving_average(beam):
    # width of moving average
    width = 21
    beam_min = int(width / 2)
    beam_max = len(beam) - beam_min - 1
    # create list to hold new beam data
    newBeam = []

    #loop to smooth the data by averaging and appending the result
    for count in range(0, len(beam)):
        if count < beam_min:
            newBeam.append(mean(beam[count: width+count]))
            #newBeam.append(beam[count])
        elif count > beam_max:
            newBeam.append(mean(beam[count-width: count]))
            #newBeam.append(beam[count])
        else:
            newBeam.append(mean(beam[count - beam_min: count + beam_min + 1]))
    # return the new beam data
    return newBeam


def finding_outliers(beam):
    # set the number of nearest neighbours (+1) to calculate the mean
    width = 11
    beam_min = int(width / 2)
    beam_max = len(beam) - beam_min - 1
    # create list to hold new beam data
    new_beam = []
    
    # Very similar to average except looks for values outside 1.5 STD
    for count in range(0, len(beam)):
        if count < beam_min:
            new_beam.append(beam[count])
        elif count > beam_max:
            new_beam.append(beam[count])
        else:
            beamSD = np.std(beam[count - beam_min: count + beam_min + 1])*1.5
            beamMean = mean(beam[count - beam_min: count + beam_min + 1])
            
            if beam[count] < beamMean - beamSD:
                new_beam.append(beamMean)
            elif beam[count] > beamMean + beamSD:
                new_beam.append(beamMean)
            else:
                new_beam.append(beam[count])
    # return the new beam data
    return new_beam

def SaturationCheck(data, length, numChan, chanToUse):
    #Gets list of over range points
    values = np.array(data[0])
    ii = np.where(values == 1)[0]
    whereOver = list(ii)
    #If there are too many data is not worth analyzing
    if len(whereOver) > 1000:
        print("SENSOR OVERLOAD")
        name_of_file = "WARNING_overloadedData.txt"
        completeName = output_path + UW + name_of_file        

        Overfile = open(completeName, "w")
        Overfile.write('Warning, the data for this file overloaded the sensor and the file analyses was unable to proceed as normal. \n')
        Overfile.write('The results are most likly unusable.')
        Overfile.close()
        raise SystemExit
    
    #If only a few, can make them zero and deal with it in outliers
    else:
        for num in range(len(whereOver)):
            for i in range(2,numChan+2):
                data[i][whereOver[num]] = 0
        return data

def saveFunc(Raw,output_path,actualFilename,numChan, UW, saveUnits):
    #Saves the area results in a csv file using pandas data frame save
    FullSavePath = output_path + UW + 'DoseArea_' + actualFilename
    d = {'Channels': ['Area [(u)]'.format(u=saveUnits)]}

    for i in range(numChan):
        name = 'Chan'+str(i+1)
        d[name] = [Raw[i]]      
        
    df = pd.DataFrame(data=d)
    df.to_csv(FullSavePath)

def plotIt(nameID, numChan,data,actualFilename,output_path,UW, uit):
    #Plots all the dose lines on the same plot and saves it in test directory
    x = data[1]
    y = data[2]
    colorList = ['slateblue', 'forestgreen', 'lightcoral', 'deepskyblue']
    fig, ax = plt.subplots(figsize=(10, 6))
    
    for i in range(2,numChan+2):
        ax.plot(data[1],data[i], color=colorList[i-2], label='channel '+str(i-1))

    TotalCharge = [sum(x) for x in zip(*data[2:numChan+2])]
    ax.plot(data[1],TotalCharge, color="red", label='Total Charge')
    
    plt.xlabel("Time [s]")
    plt.ylabel("Current {u}".format(u=uit))
    plt.legend(loc="best")
    plt.title('Channel Plots')
    nameSave = actualFilename.split('.')
    FileNamePg = nameID + nameSave[0]
    FullSavePathPg = output_path + UW + FileNamePg
    plt.savefig(FullSavePathPg+ '.png')
    plt.close()
    
def CutEnds(data, numChan, chanToUse):
    #Loop to do both sides of the data list (cuts the ends)
    for i in range(2):
        position = 0
        meanList = []
        #Loop to del data points until outside of 9 STD
        while True:
            if position < 5:
                meanList.append(data[chanToUse][position])
                position += 1
                continue
            elif data[chanToUse][position] > mean(meanList) + 9*(np.std(meanList)):
                break
            else:
                meanList.append(data[chanToUse][position])
                position += 1
                
        #Actaully delets the data and reverses the data list for the other side
        for i in range(len(data)):
            del data[i][0:position]
            data[i].reverse()
        
    return data


#Callable main with parameters from DataBaseAnalyzer.py      
def main(channelsOpen, conFact, actualFilename, metadata_path, output_path, UW):

    #Number of open channels
    numChan = sum(channelsOpen)

    #Gets a workable file name
    fileName = actualFilename.split('.')[0]

    #Pulls raw data
    rawData = pd.read_csv(metadata_path, sep=',', skiprows=1, names = ["timestamp",'triggercount','overrange','channel1','channel2','channel3','channel4', 'X'],dtype=float)
    rawDataDict = rawData.to_dict('list')
    
    #data Variable: 0: over_range, 1: time, 2-5: open channels
    data = [[],[]] 
    data[0] = rawDataDict['overrange']
    data[1] = rawDataDict['timestamp']
    for i in range(4):
        if channelsOpen[i] == 1:
            cName = "channel" + str(i+1)
            data.append(rawDataDict[cName])
            
    #Plot raw data before processing
    plotIt('Raw_', numChan,data,actualFilename,output_path, UW, 'Coloumb')

    #Get strongest channel to find end points for 
    averg = [mean(data[i]) for i in range(2,numChan+2)]
    chanToUse = averg.index(max(averg)) + 2

    # check for saturated data i.e. where overrange = 1
    length = len(data[chanToUse])
    data = SaturationCheck(data, length,numChan,chanToUse)
    
    # Cuts data where beam is on (Hopefully - this proved very difficult to do)
    data = CutEnds(data,numChan,chanToUse)
    
    results = []
    for i in range(2,numChan+2):
            #Find outliers and set to mean
            data[i] = finding_outliers(data[i])
            #Smooth the data
            data[i] = moving_average(data[i])
            #Sets first and last value to zero on all channels (for integration)
            for i in range(2,numChan+2):      
                data[i][0] = 0
                data[i][len(data[i])-1] = 0
            #Integrate and save to results
            results.append(trapz(data[i], data[1]))
            
    #Save and Plot
    saveFunc(results,output_path,actualFilename,numChan, UW, 'C')
    units = 'Coulomb'
    plotIt('PROCESSED_', numChan,data,actualFilename,output_path, UW, units)
    '''
    FullSavePath = output_path + UW + 'BeamData_' + actualFilename
    pd.DataFrame(np.transpose(data)).to_csv(FullSavePath)
    '''

    #Convert Data
    ConvertedResults = []
    for chans in range(2,numChan+2):
        #Now can in nC
        data[chans] = [item*10**9 for item in data[chans]]    
        #Convert to nGy
        data[chans] = [x*conFact[chans-2] for x in data[chans]]
        ConvertedResults.append(trapz(data[chans], data[1]))
        units2 = 'nGy'
    plotIt('Converted_', numChan,data,actualFilename,output_path, UW, units2)

    saveFunc(ConvertedResults,output_path,'ConvertedUnits.csv',numChan, UW, 'nGy')

    


#Fix the channel conversion factors to be dynanic not hard coded
'''
#Testing the function from within
channelsOpen = [1,1,0,1]
ConversionFactors = [29.07,226.7,235.5]
actualFilename = "test10_dyn-arc1-548mu.csv"
UW = '\\'
metadata_path = 'C:\\Users\\admin\\Desktop\\RH_Summer2019\\New2019\\Database\\Temp' + UW + actualFilename
output_path =  'C:\\Users\\admin\\Desktop\\RH_Summer2019\\New2019\\Database\\Temp'
main(channelsOpen, ConversionFactors, actualFilename, metadata_path, output_path, UW)

'''
'''
file = open("testfile.txt","w") 
file.write(str(data))
file.close() 
'''



