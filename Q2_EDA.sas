/*
2.Conduct an Exploratory Data Analysis for the given dataset. 
	i.Descriptive statistics for each attribute 
		(e.g., value ranges of the attributes, frequency of values, distributions, medians, means, variances, and percentiles).
	ii.Suitable visualizations for the corresponding statistics.
*/



/* Import Data*/
FILENAME REFFILE '/home/u49527144/Airbnb/Data/NewYork_Airbnb.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.AIRBNB;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.AIRBNB; RUN;



/*
------------------------------
#1: Exploratory Data Analysis
------------------------------
*/

* count total rows;
PROC SUMMARY data=airbnb MAXDEC=2 FW=10 PRINT;  
	TITLE "Total Number of Observations in Dataset";
RUN;

* display statistics analysis of each NUMERIC variable;
PROC UNIVARIATE data=airbnb;
RUN;

* display frequency count & missing value of categorical variable;
PROC FREQ DATA=WORK.AIRBNB; 
	TITLE "Frequency Count of Categorical Variables";
	TABLES neighbourhood_group room_type name host_name neighbourhood / NOCUM NOPERCENT missing;
RUN;



/*
------------------------------
#2: Data Visualization
------------------------------
*/

ods graphics / reset width=6.4in height=4.8in imagemap;

* create a histogram to show distribution of price;
proc sgplot data=WORK.AIRBNB;
	title height=14pt "Distribution of price";
	histogram price /;
	yaxis grid;
run;


* create a histogram to show distribution of minimum_nights;
proc sgplot data=WORK.AIRBNB;
	title height=14pt "Distribution of minimum_nights";
	histogram minimum_nights /;
	yaxis grid;
run;


* create a histogram to show distribution of number_of_reviews;
proc sgplot data=WORK.AIRBNB;
	title height=14pt "Distribution of number_of_reviews";
	histogram number_of_reviews /;
	yaxis grid;
run;


* create a bar chart to show the count of each neighbourhood_group;
proc sgplot data=WORK.AIRBNB;
	title height=14pt "Count of Neighbourhood Group";
	vbar neighbourhood_group /;
	yaxis grid;
run;


/* Define Pie template */
proc template;
	define statgraph SASStudio.Pie;
		begingraph;
		layout region;
		piechart category=room_type / stat=pct;
		endlayout;
		endgraph;
	end;
run;

* create a pie chart to show the percentage of each room_type;
proc sgrender template=SASStudio.Pie data=WORK.AIRBNB;
	title height=14pt "Percentage of Each Room Type";
run;


* create a scatter plot to display the location of Airbnb listings;
proc sgplot data=WORK.AIRBNB;
	title height=14pt "Location of Airbnb Listings";
	scatter x=latitude y=longitude /;
	xaxis grid;
	yaxis grid;
run;


* create a scatter plot to display the Distribution of Room Type across New York;
proc sgplot data=WORK.AIRBNB;
	title height=14pt "Distribution of Room Type across New York";
	scatter x=latitude y=longitude / group=room_type;
	xaxis grid;
	yaxis grid;
run;


* create a side-by-side bar chart to show the count of each room type grouped by neighbourhood_group;
proc sgplot data=WORK.AIRBNB;
	title height=14pt "Count of Room Type in Each Neighbourhood Group";
	vbar room_type / group=neighbourhood_group groupdisplay=cluster datalabel 
		dataskin=matte;
	xaxis display=(nolabel);
	yaxis grid display=(nolabel);
run;


* create a line chart to show the calculated_host_listings_count grouped by neighbourhood_group;
proc sort data=WORK.AIRBNB out=_LineChartTaskData;
	by neighbourhood_group;
run;

proc sgplot data=_LineChartTaskData;
	title height=14pt "Listings Count of Host based on Neighbourhood Group";
	by neighbourhood_group;
	vline calculated_host_listings_count /;
	yaxis grid;
run;


* create a boxplot to show the pricing of each room type;
proc sgplot data=WORK.AIRBNB;
	title height=14pt "Pricing of Each Room Type";
	vbox price / category=room_type;
	yaxis grid;
run;


* create a boxplot to show the pricing of each room type grouped by neighbourhood_group;
proc sgplot data=WORK.AIRBNB;
	title height=14pt "Pricing of Room Type based on Neighbourhood Group";
	hbox price / category=room_type group=neighbourhood_group;
	xaxis grid;
run;


* create a boxplot to show reviews per month of each room type;
proc sgplot data=WORK.AIRBNB;
	title height=14pt "Reviews per Month based on Room Type";
	vbox reviews_per_month / category=room_type;
	yaxis grid;
run;


* create a boxplot to show Listings Availability of each Neighborhood Group;
proc sgplot data=WORK.AIRBNB;
	title height=14pt "Listings Availability of Each Neighborhood Group";
	vbox availability_365 / category=neighbourhood_group;
	yaxis grid;
run;

ods graphics / reset;




