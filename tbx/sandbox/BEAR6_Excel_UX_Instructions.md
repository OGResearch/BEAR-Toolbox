
# Using BEAR6 Excel User Interface


## Preparation


* Make sure the BEAR6 toolbox is on the Matlab path

```
>> bear6.ping
```

* Make a local copy of the Excel UX file in your current working directory; feel free
  to rename the XLSX file to anything you like.


## Fill in meta information

* Fill in all information for estimating the reduced-form model on sheet `Reduced-form meta information` 

* Fill in all information for indentifying the structural model on sheet `Structural meta information` 

* Save the Excel UX file, and close it. Closing the file is (unfortunately)
  critical for Matlab/BEAR6 to be able to finalize the file.

The meta information sheets are used to generate the meta-dependent templates on
some of the estimation and identification sheets.


## Automatically generate meta-dependent templates

* After making sure the Excel UX file is closed, run the following command to 

```
bear5.finalizeExcelUX("BEAR6_UX_???.xlsx")
```

where `BEAR6_UX_???.xlsx` stands for the name of your local copy of the Excel UX file.


## Fill in the remaining information

* Open the Excel UX file again, and fill in the remaining information on the
  estimation and identification sheets.


## Run the model

* Run the model by running the following command

```
bear6.runExcelUX("BEAR6_UX_???.xlsx")
```

where `BEAR6_UX_???.xlsx` stands for the name of your local copy of the Excel UX file.

* The command will run the reduced-form estimation, the structural identification,
  and all the tasks specified on the "Tasks" sheet in the Excel UX
  file.

* The results will be saved in the files specified on the "Tasks"
  sheet in the Excel UX file.


## Design considerations

* Standardized way of handling 3-dimensional restriction tables (e.g. shock sign
  restrictions, narrative shock contributions, etc.)

* Size of restriction tables in panel models

* Saving output/results as percentiles

* Selection mechanism for multiple-choice situations 

* Row vs column orientation

