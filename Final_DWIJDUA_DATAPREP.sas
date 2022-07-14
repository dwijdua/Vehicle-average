Libname Vehicle 'D:/SAS_Miner_Data_Set/project';
Filename CSV 'D:/SAS_Miner_Data_Set/project/vehicles.csv';

proc import datafile=CSV Out=Vehicle.CSV Replace DBMS=CSV;
	Getnames=yes;
run;

/*Dropping the data records with the Atvtype electric (E) and also dropping the records for hybrid cars
Sticking to the convential fuel cars */
data Vehicle.CSV;
	set Vehicle.CSV;
	where Fueltype2~='E' && Atvtype~="E" and Atvtype~="H" and Fueltype2~='N' and 
		Fueltype2~='P';
run;

/*cleaning of data and converting categorical data to Numerical data before sending to SAS MINER
Importing only the variables selected that is (Barrels08 Ucity Uhighway Vclass city08 comb08 cylinders displ drive fueltype highway08 mpgData fuelcost08 Trany year yousavespend)
*/
data Vehicle.CSV;
	set Vehicle.CSV(Keep=Barrels08 Ucity Uhighway Vclass city08 comb08 cylinders 
		displ drive fueltype highway08 mpgData fuelcost08 Trany year yousavespend);
	Ucity=round(Ucity, 0.25);

	/*changing the Ucity to nearest .25 to make it normal*/
	Barrels08=round(Barrels08, 0.25);

	/*changing the Barrels to nearest .25 to make it normal */
	Uhighway=round(Uhighway, 0.25);

	/*changing the Uhighway to nearest .25 to make it normal */
	if MpgData='Y' then

		/*Assigning MPGdata (Categroical to Binary variable 1 & 2)*/
		MPGdNum=1;
	else
		MPGdNum=2;

	if FuelType="CNG" then

		/*Assigning FuelType (Categroical to Numeric)*/
		FuelNum=1;
	else if FuelType="Diesel" then
		FuelNum=2;
	else if FuelType="Midgrad" then
		FuelNum=3;
	else if FuelType="Premium" then
		FuelNum=4;
	else
		FuelNum=5;

	if drive="Rear-Wheel Drive" then

		/*Assigning Drive (Categroical to Numeric)*/
		DriveNum=1;
	else if drive="Front-Wheel Drive" or drive="2-Wheel Drive" or 
		drive="Part-time 4-Wheel Drive" then
			DriveNum=2;
	else if drive="4-Wheel or All-Wheel Drive" or drive="All-Wheel Drive" or 
		drive="4-Wheel Drive" then
			DriveNum=3;
	where MpGData~=" " and Fueltype ~=" " and drive~=" " and trany~=" ";

	if findw(Trany, "Manual") then

		/*Assigning Trany (Categroical to Binary variable 1 & 2)*/
		Transmission=1;
	else
		transmission=2;

	if find(Vclass, "Mini") then

		/*Assigning Vclass (Categroical to Numeric)*/
		Vtype=1;
	else if find(Vclass, "Vans")then
		Vtype=2;
	else if find(Vclass, "Mid")then
		Vtype=3;
	else if find(Vclass, "small") or find(Vclass, "Compact")or find(Vclass, "two") 
		then
			Vtype=4;
	else if find(Vclass, "Standard") then
		Vtype=5;
	else if find(Vclass, "Sport") then
		Vtype=6;
	else if find(Vclass, "Special") then
		Vtype=7;
	else
		Vtype=8;
	drop Vclass trany drive fueltype MpgData drive;
run;

/*Performing Proc Means to find out missing values and Stastical analysis*/
proc means data=Vehicle.CSV chartype mean std min max n vardef=df;
	var barrels08 city08 comb08 cylinders displ fuelCost08 highway08 UCity 
		UHighway year youSaveSpend MPGdNum FuelNum DriveNum Transmission Vtype;
run;

/*Removing Data with Values of 0 for the Ucity Uhigway and Barrels and not removing outliers as they are more realestic based on the depending fuel variables etc.
From the above output Barrels Mean=17.35 STD=4.3
Uhighway Mean=34 STD=8.6
Ucity Mean=25. STD=6.1
Cylinder Mean=5.7(rounded to 5)
Displ Mean=3.2
Removing the missing values for Cylinder and displ from the data*/


data Vehicle.CSV;
	set Vehicle.CSV;

	if Ucity=0 then
		Ucity=25.5;

	if UHighway=0 then
		UHighway=34;

	if barrels08=0 then
		Barrels08=17.5;

	if missing(cylinders) then
		cylinders=5;

	if missing(displ) then
		displ=3.2;
 run;


/*Evaluating the data for final to move the data to SAS MINER*/

proc means data=Vehicle.CSV chartype mean std min max n vardef=df;
	var barrels08 city08 comb08 cylinders displ fuelCost08 highway08 UCity 
		UHighway year youSaveSpend MPGdNum FuelNum DriveNum Transmission Vtype;
run;