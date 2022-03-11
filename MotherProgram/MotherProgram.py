"""
Created on Mon July 02 2019

@author: Dalton Hanaway
"""

from oct2py import octave
import numpy as np
import os
import pprint
import DataBase_NewSort

#README:
#This script runs all other scripts to analyze LINAC ion
#chamber data

#must be run from command prompt with following command:
'''
python \path\to\this\file

'''

def octaveFunc():
    #Runs octave-cli through Oct2Py module
    
    GotIt = False
    #Gets the two directories required
    while GotIt == False:
        #'C:\\Users\\admin\\Desktop\\RH_Summer2019\\New2019\\Database\\DLG\\' 
        DLGDirect = input('Please enter the DLG directory containing A & B .dlg files followed by a directory seperator (/ or \\')
        if os.path.exists(DLGDirect) == True:
            GotIt = True
        else:
            print('Directory not recognized, try again')

    GotIt = False
    while GotIt == False:
        #'C:\\Users\\admin\\Desktop\\RH_Summer2019\\New2019\\Scripts\\MotherProgram\\DynamicLibraryAyzl\\' 
        Dynalog = input('Please enter the dynalog supporting files directory with the dynAnalysisOctToPy.m file')
        if os.path.exists(Dynalog) == True:
            GotIt = True
        else:
            print('Directory not recognized, try again')
   
    #Changes directory to dynalog and adds it to octaves path
    os.chdir(Dynalog)
    octave.addpath(Dynalog)
    
    #Runs octave program with oct2py passing the directories
    octave.dynAnalysisOctToPy(DLGDirect, Dynalog)

    #Closes octave instance so that python can manipulate the files it made
    octave.exit()
    return DLGDirect

def cleanUP(DirectoryOfDLG):
    
    #Cleanup of junk files
    print("All .dlg analyzed, cleaning up...")
    octaveWrk = DirectoryOfDLG + 'octave-workspace'
    dsStoreOne = DirectoryOfDLG + '._.DS_Store'
    dsStoreTwo = DirectoryOfDLG + '.DS_Store'

    #If found, removes file
    if os.path.isfile(dsStoreOne):
        print('DSOne')
        os.remove(dsStoreOne)

    if os.path.isfile(dsStoreTwo):
        print('DSTwo')
        os.remove(dsStoreTwo)
    
    if os.path.isfile(octaveWrk):  
        os.remove(octaveWrk)
        print("workspace removed")

def dataBaseFunc():
    #Sorts and analyzs the test files and the processed DLG files
    DataBase_NewSort.main()

def main():
    #Calls all the functions - for timing it worked better to have funcs
    print('We are running')
    DirectoryOfDLG = octaveFunc()
    cleanUP(DirectoryOfDLG)
    dataBaseFunc()

main()














