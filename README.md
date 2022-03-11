# LINAC-MLC-AnalysisApplication
A complete user friendly application for analysis of radiation dose delivery of LINAC machines for medical physics quality assurance.

MotherProgram.py is a script to initiate and handle all processes required to analyze LINAC radiation dose data with ion chambers. This script ties together three separate multi-language processes into a user friendly and accessible instance. A user must have the location of 1) a folder containing all the .dlg files raw data files and 2) of dynAnalysisOctToPy.m + all dynalog supporting files. These will be the first prompts from MotherProgram.

To run from command line only:

  python /directory/MotherProgram.py



**Processes handled by MotherProgram:**

_DynAnalysisOctToPy.m_

This script originally written by Michael Hughes, analyzes .dlg files and exports figures on MCL movement and fluence. Edits were performed by Toby Conner and Dalton Hanaway to run prior to DataBaseFiling.py. I performed alterations so that the process may be called by as a single function which enabled it to be called through Oct2Py by MotherProgram. I added two arguments to the octave function which accepts directories from MotherProgram instead of the previously hard coded locations. 


_DataBase_NewSort.py_

This script co-authored by Toby Conner and Dalton Hanaway, sorts test files into organized directories based on week and test number. I updated the original work to python 3 as well as changed the sorting method to a more efficient list zip method instead of the previous bubble sort algorithm in multiple places. I also updated the code to include functions to streamline the file moving process. Finally, I added a small section at the end to call AnalyzerV3.py


_AnalyzerV3.py_

The final script called, co-authored by Helen and Dalton Hanaway, analyzes ion chamber data. I updated the program to use lists which enabled it to accept a variable number of open channels. Additionally, I added a function to calculate the beam on time dynamically instead of the hard-coded value previously used. Finally, I  organized the code into a single function that accepts locations of files to analyze (from DataBaseAnalyzer). Once called it analyzes the .csv and saves the results into the test folders created by DataBaseAnalyzer. 

