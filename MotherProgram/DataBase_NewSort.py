# -*- coding: utf-8 -*-
"""
Created on Tue Jun 06 17:23:21 2017
Edits 2019

@author: Toby Conner and Dalton Hanaway
"""
import graphics
import csv
import os
import shutil 
import numpy as np
import re
from os import walk
import AnalyzerV3
from zipfile import ZipFile
import time
import random

def moveFunc(NewPath,SortedArray,i):
    for b in range(len(SortedArray)):
        shutil.move(SortedArray[b][i], NewPath)
    
def sort_list(list1, list2): 
    zipped_pairs = zip(list2, list1) 
    z = [x for _, x in sorted(zipped_pairs)] 
      
    return z 
      
def main():

    print() 
    print("This program sorts an analyzes runs exported from LINAC ion chamber tests")
    print("A Database folder containing a .csv with test infomration as well as a I400 folder with .csv runs is required")
    
    #important to catch any errors in directory/file names otherwise program will crash 
    TF = False
    
    while TF == False:
        #"\\" 
        UW =  input("What is your default filepath seperation charachter? \\ or /? (Note windows uses \\ wheras unix/mac uses /) -->")
        if UW == "\\" or UW == "/":
            TF = True 
        else:
            print("Please ensure to only input either a / or a \\.")
        
    TF = False
    #'2019' 
    year = input("What year's data are you inputting? -->")
    while TF == False:
        #"C:\\Users\\admin\\Desktop\\RH_Summer2019\\New2019\\Database"
        SEPnetFilePath =  input('Please input Database file path -->')
        
        if os.path.exists(SEPnetFilePath) == True:
            TF = True
        else:
            print('Directory Not recognised, try again')
            
    TF = False
    TF1 = False
    #always set (TF=True false) back to false so that next while loop can utilise it being false, other
    #than having to alternate and confuse everyone between true and false. TF1 used later easier to declare it here

    #STAGE 0 AND 1
    while True:
        try:
            #1 
            Weekno = int(input('What week number are you saving to -->'))
            break
            EarlierData = input("If week number is not available (e.g. 2016) then write 'n'")
        except ValueError:
            print() 
            print('Please enter an integer, try again')
    #'n'                
    YN = input("Does Directory for Week {0} exist? Y for yes and N for no --> ".format(Weekno))
    while TF == False:
        if YN == 'Y' or YN == 'y':
            #Take the file directory location from the user to use to put 
            #I400 files into 
            while TF1 == False:
                WeekPath= input('please write file directory e.g. C:\\Users\BRMC\Desktop\SEPnet Project 2017\Week 1 or C:/Users/BRMC/Desktop/SEPnet Project 2017/Week 1 if you are a unix user --> ')
                if os.path.exists(WeekPath) == True:
                    TF1 = True
                else:
                    print('Directory Not recognised, try again')
            TF = True
        elif YN == 'N' or YN == 'n':
            WeekPath = SEPnetFilePath + UW + 'Week{0}'.format(Weekno)
            os.mkdir(WeekPath)
            #create file directory dependant on Weekno
            TF = True
        else:
            print('Please Clarify Input')
            YN=input('-->')
    TF = False
    TF1 = False

    #STAGE2+3
    #READ FROM CSV FILE SHIFT I400 FILES
    #'n' 
    MetaDataExist = input('Does MetaData file exist? (Y/N) -->')
    while TF == False:
        if MetaDataExist == 'Y' or MetaDataExist == 'y':
            print('please input location of MetaData file')
            while TF1 == False:
                MetaDataFile= input()
                if str(MetaDataFile).endswith(".txt"):
                    if os.path.isfile(MetaDataFile) == True:
                        TF1 = True
                    else:
                        print('File not recognised, please try again')
                elif os.path.isfile((str(MetaDataFile) + '.txt')):
                    TF1 = True
                    MetaDataFile = MetaDataFile + '.txt'
                else:
                    print('File not recognised, please try again')
            TF = True
        elif MetaDataExist == 'N' or MetaDataExist == 'n':
            print('MetaData.txt will be created and put in Database folder')
            MetaDataFile = SEPnetFilePath + UW + 'MetaData.txt'
            open(MetaDataFile, 'a+')
            #This is done later upon opening the file if it does not exist 
            TF = True 
        else:
            print('Please clarify input')
            MetaDataExist = input('-->')
            
    TF = False
    TF1 = False
        
    while TF == False:
        #"C:\\Users\\admin\\Desktop\\RH_Summer2019\\New2019\\Database\\I400"
        I400Dir=  input('Please input 1400 File Directory -->') 
        if os.path.exists(I400Dir) == True:
            DirArray = []
            #first check if the path to the directory exists, then see if the directory is empty
            #if it is we prompt user to put files into it or write the proper directory
            for filename in os.listdir(I400Dir):
                if str(filename).endswith(".csv"):
                    DirArray.append(filename)
            if DirArray == []:
                print('Directory contains no csv files, please put files in directory and try again')
            else:
                print('File locations saved')
                TF = True 
        else:
            print('Directory is not recognised, please try again')


    Init = int(eval(input("What test number does the .csv start from? --> ")))
    #OLD
    #SDirArray is the sorted DirArray
    #Sorting algorithm, takes string values testX and converts X to integer
    #Creates an empty array and inputs testX at location X in the array, sorting the
    #list. Loosley an insertion sort algorithm
    
    # EDITED:
    #to use re string search to pull the value between "test" and "_"
    # Using array zipping to sort Dir array by an array of test numbers with sort list func

    tempArray = list(range(len(DirArray)))
    for i in range(len(DirArray)):
        tempArray[i] = eval(re.search('test(.*)_',DirArray[i]).group(1))

    SDirArray = sort_list(DirArray, tempArray)
    FileNameArray = [SDirArray[i] for i in range(len(SDirArray))]
    
    for i in range(0,len(SDirArray)):
        SDirArray[i]= I400Dir + UW + SDirArray[i]

    tempArray.sort()

    #now list is sorted, we can concatenate the correct path to the beggining

    #Put all I400 files in the directory into an array to sequentially move them
    #from the file. Kiled 2 birds with one stone, error checking for empty directory and
    #saved all the csv file locations to an array which we will use to move them sequentially into new directories within 
    #SEPnet folder. 
    #only puts it in the array if it's a csv fille, for example screenshots (.jpg) are ignored        

    while TF1 == False:
        #'C:\\Users\\admin\\Desktop\\RH_Summer2019\\New2019\\Database\\June23Information.csv'
        CSVTestFile= input('Please input the location of the CSVTestfile (within directory) -->')
        if os.path.isfile(CSVTestFile) == True:
            TF1 = True
        elif os.path.isfile(CSVTestFile+'.csv') == True:
            CSVTestFile = CSVTestFile + '.csv'
            TF1 = True
        else:
            print('File not recognised, please try again')
        
    TF = False
    TF1 = False

    #VERSION 1.2 ADDING SOME PROCESSING OF DLG FILES

    #we have obtained 2 arrays of dlg files, below we will sort them using a similar
    #method to the i400 files above (bubble sort this time)

    #the NODLG boolean variable used below signals to the rest of the code whether
    #we need to bother with the .dlg files.

    TF = False
    TestDLGArray = []
    xarray = []
    while TF == False:
        DLGExist = input("Are there any .dlg files with the tests? If there are, please make sure to first analyse them with dynAnalysis.m  (Y/N)  -->")
        if DLGExist == 'Y' or DLGExist == 'y':
            DLGComplete = input("Complete set of .dlg files? (Y/N) -->")
            if DLGComplete == 'N' or DLGComplete == 'n':
                CompleteSet = False
                print("Please specify which tests have associated .dlg files, input 'done' when all tests are input")
                while TF == False:
                    x=input()
                    if x != 'done':
                        TestDLGArray.append(x)
                    else:
                        print ("Test numbers recorded")
                        TF = True
                        NoDLG = False
            elif DLGComplete == 'Y' or DLGComplete == 'y':
                TF = True
                NoDLG = False
                CompleteSet = True 
            else:
                print("Please clarify input, only y,Y,N,n please")
        elif DLGExist == 'N' or DLGExist == 'n':
            TF = True
            NoDLG = True
            CompleteSet = False
        else:
            print("Please clarify input, only y,Y,N,n please")
        
    #If there is a complete set, then the dlg files will be sorted into test directories
    #in a chronological time order. 
    #If there is no complete set, the test numbers are gathered then when the files are sorted
    #the test number is checked against the holding array for test numbers with .dlg files
    #if TRUE, then file is put into file 


    #Holds the file path for everything
    NamesArray = [ [] for i in range(8)]
    #NamesArray = [SDLGArrayA, SDLGArrayB, DLGJPGgamma, DLGJPGafluence, DLGJPGpfluence, DLGJPGA, DLGJPGRoC,AreaCSV]

    dlgSize = 0 
    TF = False
    while NoDLG == False and TF == False:
        #"C:\\Users\\admin\\Desktop\\RH_Summer2019\\New2019\\Database\\DLG" 
        DLGDir= input("Please input Dynalog File Directory. -->") 
        if os.path.exists(DLGDir) == True:
            DLGArray=[]
            for filename in os.listdir(DLGDir):
                if str(filename).endswith(".dlg"):
                    DLGArray.append(filename)
                    dlgSize = dlgSize + 0.5 #0.5 for bank A and B respectively, useful later
                    #need to flip the strings for .jpg as the test number is at the end 
                elif str(filename).endswith(".jpg"):
                    if str(filename).startswith("gamma"):
                        NamesArray[2].append(filename)
                    elif str(filename).startswith("planned"):
                        NamesArray[4].append(filename)
                    elif str(filename).startswith("actual"):
                        NamesArray[3].append(filename)
                    elif str(filename).startswith("RoCoA"):
                        NamesArray[6].append(filename)
                    elif str(filename).startswith("Area"):
                        NamesArray[5].append(filename)
                elif str(filename.endswith(".csv")):
                    if str(filename.startswith("resultArea")):
                        NamesArray[7].append(filename)
                    else:
                        #(hopefully) there is only one other .csv file which is the
                        #one with all the result data of the .dlg pairs. Put this
                        #in it's own directory 
                        resultCSVPath =  WeekPath + UW + 'DLG results CSV'
                        os.mkdir(resultCSVPath)
                        filepath = DLGDir + UW + filename
                        shutil.move(filepath, resultCSVPath)
         
            if DLGArray == []:
                print('Directory contains no .dlg files, please put files in directory and try again')
            else:
                print('File locations saved')
                TF = True 
        else:
            print('Directory,  is not recognised, please try again')
            
    #Removes the random hidden files if they are created and shown in our array

    if '._.DS_Store' in NamesArray[7]:
        NamesArray[7].remove('._.DS_Store')
    if '.DS_Store' in NamesArray[7]:
        NamesArray[7].remove('.DS_Store')
    if 'octave-workspace' in NamesArray[7]:
        NamesArray[7].remove('octave-workspace')

    #We have now obtained from the user all information we need, so can now process CSV file into 
    #metadata file, and shunt all I400 files to new directories within the SEPnet Folder. 
    if NoDLG == False:
        for i in range(len(DLGArray)):
            if DLGArray[i][0]=='A':
                NamesArray[0].append(DLGArray[i])
            else:
                NamesArray[1].append(DLGArray[i])
    
    #we have obtained 2 arrays of dlg files, below we will sort them using a similar
    #method to the i400 files above (bubble sort this time)
                
    #EDIT: No longer bubble sort
    #New much more efficent sorting mechanism using a zip function between two arrays instead of
    #Older bubble sort method 

        #Numbers of the test files to sort the names by with zip sort function    
        NumsArray = [list(range(len(NamesArray[0]))) for i in range(len(NamesArray))]

        #Grabs the numbers from the file names 
        for i in list(range(len(NumsArray[0]))):
            
            holdarrayA = []
            holdarrayB = []
        
            for letter in str(NamesArray[0][i]):
                if letter == 'A':
                    continue
                if letter != '_':
                    holdarrayA.append(letter)
                else:
                    break

            for letter in str(NamesArray[1][i]):
                if letter == 'B':
                    continue
                if letter != '_':
                    holdarrayB.append(letter)
                else:
                    break
                            
            NumsArray[0][i] = int(''.join(holdarrayA))
            NumsArray[1][i] = int(''.join(holdarrayB))
            NumsArray[2][i] = int(NamesArray[2][i][10:-4])
            NumsArray[3][i] = int(NamesArray[3][i][15:-4])
            NumsArray[4][i] = int(NamesArray[4][i][16:-4])
            NumsArray[5][i] = int(NamesArray[5][i][11:-4])
            NumsArray[6][i] = int(NamesArray[6][i][16:-4])

            NumsArray[7][i] = int(NamesArray[7][i][10:-4])

        SortedArray = [list(range(len(NumsArray[0]))) for i in range(len(NamesArray))]
        
        #Sorts
        for i in range(len(NumsArray)):
            SortedArray[i] = sort_list(NamesArray[i], NumsArray[i])
            
        #adds directory path 
        for i in range(len(SortedArray[0])):
            for b in range(len(SortedArray)):
                SortedArray[b][i] = DLGDir + UW + SortedArray[b][i]



    #Now need to add the gamma/fluence/actual fluence maps to the directories
      
    print('Moving files...')
    
    #Access Denied for writing to files in python need to write to a new one and save it
    #So changing the name of the newCSV file to just add a 'withPath' on the end as we are
    #only concatenating the CSVfilepath onto the end of the spreadsheet. 
    NewCSVFile = CSVTestFile[:-4]
    NewCSVFile = NewCSVFile + '_withPath' + '.csv'

    #add the filename in a new column for the metadata
    i=0
    ToPass = []

    with open(CSVTestFile, 'r') as csvfile, open(NewCSVFile, 'w') as csvoutput, open(MetaDataFile, 'a+') as f:
        writer = csv.writer(csvoutput, lineterminator = '\n')
        reader = csv.reader(csvfile)
        f.write("Path meta data for Week" + str(Weekno) + '\n')

        data = []
        i=0
        for row in reader:
            if i==0:
                data.append([str(tempArray[0]),row[1]])
                i += 1
            else:
                data.append(row)

        #omitting the fieldnames parameter as CSV file will have fieldnames in the first row
        for i in range(len(DirArray)): #row in reader:

            #saves meta information
            NewPath = WeekPath + UW + 'Test{0}'.format(tempArray[i])
            data[i].append('Week{weekN}/Test{testN}'.format(weekN=Weekno,testN=tempArray[i]))
            ToPass.append([FileNameArray[i], NewPath, tempArray[i]])
            temp = str(data[i]) + ' ' + str(FileNameArray[i])
            temp = temp.replace("'","")
            temp = temp.replace("[","")
            temp = temp.replace("]","")
            f.write(temp+'\n')
            
            #Moves files             
            if os.path.exists(NewPath) == False:
                os.mkdir(NewPath)
                '''
                shutil.move(SDirArray[i],NewPath)
                if CompleteSet == True:
                    moveFunc(NewPath,SortedArray,i)

                elif NoDLG == False:
                    for j in range(0,len(TestDLGArray)-1):
                        if i == int(TestDLGArray[j])-Init:
                            moveFunc(NewPath,SortedArray,j)
                            
            else:
                
                '''
            #Makes directory to put files in 
            shutil.move(SDirArray[i],NewPath)
            if CompleteSet == True:
                moveFunc(NewPath,SortedArray,i)
                
            elif NoDLG == False:
                for j in range(0,len(TestDLGArray-1)):
                    if i == int(TestDLGArray[j])-Init:
                        moveFunc(NewPath,SortedArray,j)

        #Writes the csv to hold test dir info
        writer.writerows(ToPass)
        #Writes csv test infomration in the metadata.txt file
        f.write('CSV Test file location: ' + WeekPath + '\n' + '\n')

    #Makes misselaneous folder to hold extra files like screenshots and test csv
    MissFolder = WeekPath+UW+'ExtraFiles'
    os.mkdir(MissFolder)
    #Puts the extra files in there 
    shutil.move(NewCSVFile,MissFolder)
    shutil.move(CSVTestFile,MissFolder)

    fileListDLGExtra = []
    for (dirpath, dirnames, filenames) in walk(DLGDir):
        fileListDLGExtra.extend(filenames)
        break
    if '.DS_Store' in fileListDLGExtra:
        fileListDLGExtra.remove('.DS_Store')
        
    for i in range(len(fileListDLGExtra)):
        shutil.move(DLGDir+UW+str(fileListDLGExtra[i]),MissFolder)

    #Takes all extra files from I400 dir and then deletes the empty folder
    fileList = []
    for (dirpath, dirnames, filenames) in walk(I400Dir):
        fileList.extend(filenames)
        break
    #Puts other files in missalaneous folder
    for i in range(len(filenames)):
        shutil.move(I400Dir+UW+str(filenames[i]),MissFolder)
        
    os.rmdir(I400Dir)
    os.rmdir(DLGDir)
    
    print(("{0} tests successfully transferred and MetaData File updated.".format(len(DirArray))))
    print ("Dynalog .jpg, .csv, .dlg files successsfully transferred")
    print("")
        
    AnLiz = input("Do you want to analyze the sorted directory for beam dose? --> (y/n)")

    #Calls the CallableProcessing script for each file that the program just moved and puts results
    #in the respective folder
    
    if AnLiz == 'Y' or AnLiz == 'y':
        #times the analysis code (to test different anylysis processes)
        start_time = time.time()

        chanStr = input('Please enter 1 2 3 and/or 4 seperated by a space representing the open channel numbers. For example "1 2 4"')

        res = chanStr.split(' ')
        chanArray = [0,0,0,0]

        for i in range(len(res)):
            res[i] = eval(res[i])
            chanArray[res[i]-1] = 1

        
        ConversionFactors = [29.07,226.7,235.5]
        
        print("")
        for i in range(len(DirArray)):
                #Vars to pass to callprocessV2
                channelsOpen = chanArray
                actualFilename =  ToPass[i][0] 
                metadata_path = ToPass[i][1] + '/' + actualFilename
                output_path =  ToPass[i][1]
                
                #Error catching in case it returns a recursion error from finding beam on
                try:
                    #Calls the analysis file on each .csv in the test directories 
                    AnalyzerV3.main(channelsOpen,  ConversionFactors, actualFilename, metadata_path, output_path, UW)
                    print("Data analyzed and saved for "+ actualFilename + '\n')
          
                except:
                    print("Unable to analyze" + actualFilename + "\n")
                    continue
                
        print('Finished analyzing the Database')
        print('Processing Time: {}s'.format(str(round(time.time()- start_time,5))))
               
    else:
        print("Finished sorting directory")
    
'''
weekDel = '/Users/daltonhanaway/Desktop/RH_Summer2019/New2019/Database/Week1'
metaDel = '/Users/daltonhanaway/Desktop/RH_Summer2019/New2019/Database/MetaData.txt'

file_name = "/Users/daltonhanaway/Desktop/RH_Summer2019/New2019/Database/I400.zip"
file_two = "/Users/daltonhanaway/Desktop/RH_Summer2019/New2019/Database/June19Information.csv.zip"

with ZipFile(file_name, 'r') as zip: 
    zip.extractall("/Users/daltonhanaway/Desktop/RH_Summer2019/New2019/Database")

with ZipFile(file_two, 'r') as zip: 
    zip.extractall("/Users/daltonhanaway/Desktop/RH_Summer2019/New2019/Database")

weekDel = '/Users/daltonhanaway/Desktop/RH_Summer2019/New2019/Database/Week1'
metaDel = '/Users/daltonhanaway/Desktop/RH_Summer2019/New2019/Database/MetaData.txt'


os.remove(metaDel)
shutil.rmtree(weekDel)
'''

#main()

      
#Make new directory so that if we want screenshots of test etc it's all
#in that new directory named Test1 (or Dynalog files)
#move the file from the I400 file to the new directory for the test
#which is nicely sorted from our sorting algorithm earlier
#if there exists a dlg directory then it shifts to the relevant new directory
###DONE                           

#could totally use functions for like 90% of this and make it waaay easier
#SEPnet 2018 lookin at you
###DONE

#In retrospect, could create one function to see whether the file exists and cut the
#code down by like 100 lines
#some of the file procedures were inherantley different though so it's ok 
#

