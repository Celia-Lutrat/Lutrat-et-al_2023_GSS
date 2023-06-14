# Paper: 

Lutrat et al. 2023: Combining two Genetic Sexing Strains allows sorting of non-transgenic males for Aedes genetic control

# Description

All scripts used to handle the datasets, build the models and plot the figures of this paper.

DOI: 10.1038/s42003-023-05030-7

# Files:

> COPAS analysis: Script built to analyze raw COPAS outputs 

	> COPAS_function.R: function to analyse raw COPAS outputs (from txt files)	

	> dummy.txt: example of initial dataset from the COPAS (only EXT, TOF, and two colors columns will be used by the function)

	> dummy.csv, dummy-clustering.png, dummy-clustering-clean.png, dummy-COPAS-data-filtered.csv, dummy-filtering.png: function outputs after analysis of dummy.txt

> Supplementary Data 2: "Supplementary Data 2: Detailed statistical outputs" scripts and datasets

	> Supplementary_material_R.Rmd: R Markdown script

	> Supplementary_material_R.pdf: PDF output	

	> data: analysed datasets
	
	> plot: figures outputs

> Mass rearing cost simulations: Mass rearing cost simulations scripts for comparing different sex sorting methods 

	> "1-1-Simulation_cost_spreadsheet-Aedes-GSS-GSS-CS-manual.R": 
	cost simulation R function adapted directly from the AIEA spreedsheet 
	(https://www.iaea.org/resources/manual/spreadsheet-for-designing-aedes-mosquito-mass-rearing-and-release-facilities-version-10). 
	It follows the structure of the IAEA spreadsheet with a simulation section at the end allowing simulation of several situations at once. 
	To be used with the "2-Simulation_outputs_spreadsheet.R" code for producing a csv output and plots.
	
	> "1-2-Simulation_cost_spreadsheet-Aedes-user-friendly.R": a more user-friendly version of the above code. 
	Fields to be modified are detailed at the beginning of the code. The csv output is produced in the same script.

	> "2-Simulation_outputs_spreadsheet.R": analysis of the simulation outputs from 1-1 or 1-2.
	
