/*
3.Apply pre-processing techniques to handle:
	i.Incomplete data
	ii.Noisy data
	iii.Inconsistent data
*/


/* Import Data*/
FILENAME REFFILE '/home/u49527144/Airbnb/Data/NewYork_Airbnb.xlsx';

PROC IMPORT DATAFILE=REFFILE DBMS=XLSX OUT=WORK.AIRBNB;
	GETNAMES=YES;
RUN;

PROC PRINT DATA=WORK.AIRBNB_noisy_replaced;
RUN;


/*
------------------------------
#1: HANDLE INCOMPLETE DATA (MISSING VALUES)
------------------------------
*/

/*
---------
#1.1: Check rows with missing values
---------
*/

/* check missing and non-missing values of each variable
https://sascrunch.com/dealing-with-missing-values/?msclkid=d8b69801cf4d11ecb58683692a193261
*/

/* create a format to categorize missing vs. non-missing values & show the proportion */
proc format;
	value $missing_char ' '='Missing' other='Present';
	value missing_num
    .='Missing' other='Present';
run;

proc freq data=AIRBNB;
	title "Categorization of Missing and Non-Missing Values for Each Attribute";
	tables _all_ /missing;
	format _character_ $missing_char. _numeric_ missing_num.;
run;


/* retrieve all rows WITH missing values*/
DATA AIRBNB_mv;
	SET AIRBNB;

	IF cmiss(of _ALL_)=0 THEN
		DELETE;
	*delete row that has no missing value;
RUN;

PROC PRINT data=AIRBNB_mv;
	title "Data Rows with Missing Value";
RUN;



/*
---------
#1.2: Replace missing values
---------
*/

/*
For name and host_name, as the fetaures are not important, replace with value NA (Not Available)
*/
DATA AIRBNB_mv_replaced;
	SET AIRBNB;
	title "Data with Replaced Missing Value";

	if missing(name) then
		name="NA";
	*replace missing value with value NA (Not Available);

	if missing(host_name) then
		host_name="NA";
	*replace missing value with value NA (Not Available);
RUN;


/*
For reviews_per_month, check frequency percentage (of missing value) first
*/
proc freq data=AIRBNB_mv_replaced;
	title "Frequency Count of Variable reviews_per_month";
	tables reviews_per_month /missing nocum;
run;

* replace missing value with group mean using PROC STDIZE function;
PROC STDIZE data=AIRBNB_mv_replaced
			out=AIRBNB_mv_replaced
			reponly missing=mean;   *replace with mean;
	var reviews_per_month;

* display statistics analysis of reviews_per_month;
PROC UNIVARIATE data=AIRBNB_mv_replaced;  
	TITLE "Statistics Analysis After Replacement";
	var reviews_per_month;
RUN;


/* 
For last_review, DROP the column as the value is too specific and cannot be replaced with mean, median etc
	and the feature is not significant for analysis

https://sasexamplecode.com/how-to-select-variables-with-the-keep-drop-option/#:~:text=In%20SAS%2C%20you%20remove%20variables%20from%20a%20dataset,use%20the%20DROP%3D-option%20to%20remove%20the%20SaleDate%20column.
*/
data work.AIRBNB_mv_replaced;
	set AIRBNB_mv_replaced (drop=last_review);
run;


/* check whether last_review is dropped */
PROC CONTENTS DATA=AIRBNB_mv_replaced; RUN;


/* check whether all missing values is replaced */
proc format;
	value $missing_char ' '='Missing' other='Present';
	value missing_num
    .='Missing' other='Present';
run;

proc freq data=AIRBNB_mv_replaced;
	title "Categorization of Missing and Non-Missing Values for name, host_name and reviews_per_month";
	tables name host_name reviews_per_month/missing;
	format _character_ $missing_char. _numeric_ missing_num.;
run;


/*
------------------------------
#2: HANDLE NOISY DATA
------------------------------
*/

/*
---------
#2.1: Filter values to remove outliers
---------
*/

* create a format for acceptable range of values;
PROC FORMAT;
	VALUE price_CK 15-335 = "OK";
	VALUE minNight_CK 1-54 = "OK";
RUN;


* delete values that are OUT of the range;
DATA AIRBNB_noisy_replaced;
	SET AIRBNB_mv_replaced;
	FILE PRINT;
	IF PUT(price,price_CK.) NE "OK"
		THEN DELETE;
	IF PUT(minimum_nights,minNight_CK.) NE "OK"
		THEN DELETE;
RUN;


/*
---------
#2.2: Create visualization to show distribution after removing outliers
---------
*/

* create a histogram to show distribution of price (after removing outliers);
proc sgplot data=WORK.AIRBNB_noisy_replaced;
	title height=14pt "Distribution of Price (Without Outliers)";
	histogram price /;
	yaxis grid;
run;

* create a histogram to show distribution of minimum_nights (after removing outliers);
proc sgplot data=WORK.AIRBNB_noisy_replaced;
	title height=14pt "Distribution of minimum_nights (Without Outliers)";
	histogram minimum_nights /;
	yaxis grid;
run;


/*
---------
#2.3: Check noisy data in host_name
---------
*/

PROC FREQ DATA=AIRBNB;
	TITLE "Frequency Counts of host_name";
	TABLE host_name;
RUN;

/*
---------
#2.4: Replace noisy data
---------
*/

DATA AIRBNB_noisy_replaced;
	SET AIRBNB_noisy_replaced;
	FILE PRINT; *Send output to output window;
	TITLE "Replace Noisy Data (host_name)";
	
	IF host_name = "(Email hidden by Airbnb)"
		THEN host_name = NA;  *replace noisy data with value NA (Not Available);
RUN;

* check if noisy data is replaced;
PROC FREQ DATA=AIRBNB_noisy_replaced;
	TITLE "Check if Noisy Data is Replaced";
	TABLE host_name;
RUN;


/*
------------------------------
#3: HANDLE INCONSISTENT DATA
------------------------------
*/


/*
---------
#3.1: Check for Inconsistent Data
---------
*/

* frequency count of neighbourhood for each neighbourhood_group;
proc sort data=WORK.AIRBNB out=AIRBNB_sorted;
	by neighbourhood_group;
run;

PROC FREQ DATA=AIRBNB_sorted;
	TITLE "Frequency Counts";
	TABLE neighbourhood;
	by neighbourhood_group;
RUN;


* compare the coordinates to ensure the data is of same meaning #1;
DATA _NULL_;
	SET AIRBNB;
	FILE PRINT; *Send output to output window;
	TITLE "Comparison of Coordinates";
	
	IF neighbourhood = "Concourse" or neighbourhood = "Concourse Village"
		THEN PUT neighbourhood= longitude= latitude=;
RUN;


/*
---------
#3.2: Modify Inconsistent Data
---------
*/

DATA AIRBNB_inconsistent_replaced;
	SET AIRBNB_noisy_replaced;
	FILE PRINT; *Send output to output window;
	TITLE "Replace Inconsistent Data";
	
	IF neighbourhood = "Concourse Village"
		THEN neighbourhood = "Concourse";
RUN;

DATA _NULL_;
	SET AIRBNB_inconsistent_replaced;
	FILE PRINT; *Send output to output window;
	TITLE "Check Coordinates after Replacing Inconsistent Data";
	
	IF neighbourhood = "Concourse" or neighbourhood = "Concourse Village"
		THEN PUT neighbourhood= longitude= latitude=;
RUN;
