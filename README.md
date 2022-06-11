# codeclan_pda_DE13group3project

This is a repository for the Codeclan DE13 Cohort - Group Project

Names of group members
Scott Wright, Cameron Fraser, Alisa Tunonen & Mark Fojas

### Roles & responsibilities of each team member:
<br>
Scott worked on:

* Cleaning & wrangling of Bed Capacity Data;
* Bed Capacity analysis scripts and visualisation (plots).Analysis included inferential statistics - bootstrapping methods;
* Generated data joining script for group and joined datasets ready for analysis.

<br>
Cameron worked on:

* Cleaning & wrangling of Geospatial Data;
* Development of R-Shiny Web App (dashboard) inclusive of R-Shiny global, UI and server scripts;
* Led the process of merging each group members scripts into the above scripts of R-Shiny Web App.

<br>
Alisa worked on:

* Identifying the datasets necessary to answer the questions set by the group as part of satisfying the brief;
* Cleaning and wrangling of Admissions Data (including A&E Admissions);
* Admissions analysis scripts and visualisation (plots). Analysis included use of predictive modelling.

<br>
Mark worked on:

* Cleaning and wrangling of Delayed Discharge Data (inclusive of reviewing demographic influences such as age, reasons for delay and deprivation);
* Delayed discharge analysis scripts and visualisation (plots);
* Researched and considered influence of NHS staff numbers/working hours, for potential future analysis.

<br>
Everyone worked on:

* Reviewing the project brief and determining our approach to satisfying it - posing questions for the collective group to consider, and exploring the areas highlighted;
* Dashboard design & layout (wireframe) - agreeing initial and final concepts both visually and from a functional perspective (with the end user in mind);
* Development of group presentation (including final delivery & rehearsal).


### Brief description of dashboard topic:

The core topic for the dashboard was the impact that winter might have on Scotland’s health care system (NHS), primarily in the hospital (acute care) sector.

Key focus areas and questions to be answered using the information provided by the dashboard, were:

* To what extent is the ‘winter crises’ the media predicts real?;

* How has winter impacted Scotland’s NHS in the past?;

* Potential impact in winter 2022;

* How might the pandemic influence the potential scenario?.

The dashboard outlines our topic in terms of providing insight into Temporal, Demographic & Geographic Aspects of the domain, and was designed such to provide the theoretical front end user (NHS Administration Staff) with user-friendly access to information on key performance indicators (KPI’s).

The theoretical client for the project was Public Health Scotland (PHS).

### Stages of the project:
The stages of this project were as follows:

<br>
22nd April 2022:

* Group review and consideration of project brief;
* Agreement on project management approach - communication & collaboration methods, action tracking & version control methods;
* Setting up of group repository on github.

<br>
23rd to 24th April 2022:

* Development & consolidation of group questions and allocation of focus areas to each team member, for further research and dataset identification.
* Selection of datasets;
* Joining of datasets where applicable.

<br>
25th to 26th April:

* Initial dashboard planning and wireframe;
* Initital data analysis & visualisations.

<br>
27th of April:

* Continuation of dashboard development and analysis;
* Presentation preparation and rehearsal.

<br>
28th of April:

* Delivery of group project presentation inclusive of dashboard, to project client, Public Health Scotland.

### Which tools were used in the project?

* Zoom (predominantly used at weekends when team members were remote working);
* Git/GitHub (collaboration & version control);
* Slack in aid of remote team communication and collaboration;
* R Studio (Integrated Development Environment);
* Morning (9.45am) and afternoon (2.30pm) team stand-ups (Mon-Fri).
* Meeting with Public Health Scotland representative on Monday of project week.


### How did you gather and synthesise requirements for the project?
In the first instance, we needed to create clarity and a mutual understanding within the group of what the project brief was, what outcomes we had to meet, and how we would meet such outcomes.Each person within the group shared their own interpretation of the brief and their thoughts on how best to achieve the project outcomes. We began “with the end user in mind” and as a result, we reached consensus in an efficient and coordinated manner.

As the project evolved, our group prioritised the development of a dashboard which would ultimately, provide enough information, to allow the end user to answer the questions set/asked by the project brief.

Our dashboard focused on the following areas;

* Bed Capacity;
* Admissions;
* Delayed Discharge, and to
* Provide the functionality to observe the above through changing variables such as specialty, time, year, quarter, season, geographical location (health board/hospital), age and social deprivation.


### Motivations for using the data you have chosen?

In the planning stages, we established that bed occupancy, number of admissions, and delayed discharges would be the key performance indicators to gain insights into the Winter Crisis and it’s strain on Scottish NHS Health Boards.

We used a dataset of the NHS Health Boards across Scotland, to give an interactive map that would allow quick glances into the rate of our key performance indicators at a health board area. This was done in our summary tab of the dashboard and was included to allow Public Health Scotland to look at key measures with a geo-spatial aspect.

We used the dataset on bed occupancy to answer how strained hospitals and health boards are and we chose to do this because we wanted to have a measure that could be used to measure current strains on the NHS. This would then be developed to be a live measure, and allow administrators to re-allocate resources based on live figures. We allowed comparisons of this measure to be one hopsital against the total average rate of bed occupancy, and also compare two hospitals against each other.

We used the dataset on number of admissions by health board & by hospital to look at the changes of number of people admitted against time. This answers the question whether there is an increased of admissions during the winter period, and if there is a cyclic trend of admissions - with increased numbers admitted during winter versus other times of the year. This was because we were interested in determining the strain that increased admissions would put on resources, and if there was a cyclic trend, it would help planning the allocation of resources to change when the rate of admission was high. This dataset also allowed us to compare rate of admission before and during the COIVD-19 pandemic - and then we used predictive modelling to model the future rate of admissions based on the current data trend.

We finally used a dataset based on delayed discharge to answer what demographic of patients have an increased time spent in hospitals because we wanted to see which individuals are most effected by strains in the NHS. This was set up to allow filtering based on a date range and hospitals, again to allow planning of resources when there was an increased pressure on the NHS.

### Data quality and potential bias, including a brief summary of data cleaning and transformations:

According to the About tab on the dataset page/dedicated page online, the data quality …

All measures were taken to making the dataset as unbiased as possible while data cleaning and transformation steps were taken - and this was important to us, as we understand that biased data leads to biased conclusions and we didn’t want anyone to be mislead by our analysis of the data. The only biases that could have been introduce was from the source of the data - this is discussed later in this document but it should be noted that there will be no biases introduced from PHS. The PHS website also has information on the data quality, and we concluded that the data was unbiased and fairly collected with consent from individuals (links to the privacy policies are contained in the Data Ethics of this document).

When loading in the data, the data looked to be fairly clean. First we used the janitor package and the clean_names() function to reduce the column names of all data sets to snake case. We then went on to create individual files to work on for each tab within our shiny app, by taking specific data sets and using the row_bind function to create bigger data sets to be used for each .

Date Time Manipulation
A data set was created from Admissions data collect form PHS, and contained information on the admissions by:

Sex
Deprivation Score
Speciality within hospitals
Health Boards
The main cleaning step for this data set was carried out to create a datetime variable (to be used in the predictive modelling). Using the lubridate package, the week and quarter of year was obtained from the week_ending variable (the quarter needed to be changed from “Q[1, 2, 3, 4]” to “Spring”, “Summer”, “Autumn” or “Winter”).


This was also carried out in the Delayed Discharge data set - row_bind was done on information with:

Health Boards
Speciality within hospitals and, as stated before, a datetime variable was created in the same way as the Admissions data set


A Bed Occupancy data set was created based on the delayed discharge data set, but a variable was changed to become average_occupied_beds based on rounding the amount of occupied beds.

Then final steps were taken to limit the year of data sets to 2018 and onwards (as we determined that recent years were of most importance to make conclusions on the pandemic’s effect against our key performance indicators). There was duplicated data (which was signified by _qualifier variables after each individual variable) which was removed by removing any columns ending with _qualfier.

To allow geo-spatial information to be gained from the data set, we performed a left_join on address line variable to give location specific data.

Geo-spatial Data
The geo-spatial data needed further steps format the data to create interactive maps. Geo-spatial data on the Health Boards within Scotland were mapped to give an interactive map that highlights the bed occupancy, number of admissions and delayed discharge rate within Health Boards. This was done by researching the borders of each Health Board and obtaining polygons/shapes to be mapped using the leaflet package. Once this was done, a join was performed on the each data set - to give each data set an identifier column for Health Boards. This would allow the map to filter plots and infoBoxes when a Health Board was clicked. This was all placed upon the Summary tab, and had three info Boxes; the selected Health Board’s bed occupancy, admissions and delayed discharge. The tab also had two plots of the bed occupancy and the A&E targets - both of which were split up hospitals within the Health Board - and changed depending on the health board selected when clicking on the interactive map.

To look further into the cleaning steps, the data_prep_row_bind and helper files have detailed notes on each step included within them.

How is the data stored and structured
Everything on statistics.gov.scot stores their data as linked data, which is a way of storing data in data sets by giving them a unique URL. This then means that each data point can be given characteristics (we would see this as variables) that can be “given” to a data point.

In practice, the data is stored as triplets:- with the “subject” being a data point, “predicate” being the variable given, then the “object” being the value of the variable.

The benefits of storing data in this format is that the structure of data is held at the data point level, so there is no need for a very complicated structural database system. When the data points hold the data structure, links for each data source is very easy to find and makes linking data sets very easy too. As each data point has a unique URL, searching for data, accumulating data points into data sets and querying data sets is very efficient to do.

Further guidance on how the statistics.gov.scot data is stored and structured can be found at: https://guides.statistics.gov.scot/article/34-understanding-the-data-structure.

<br>

### Ethical and legal considerations of the data:

The data sets used are public sector information licensed under the Open Government Licence, which means that the information contained in the data sets can be used by: * copying, publishing, distributing and transmitting the Information * adapting the Information for use in research * exploiting the Information commercially and non-commercially

In our case, we are adapting it for use in research, and as long as we acknowledge the source of the information (which we are doing here), we can freely use the data sets.

After acquisition, we checked that the information contained in each data set did not contain personal information of individuals - and this was to confirm that Public Health Scotland (the source of the data sets) has followed data protection laws. This was confirmed and more information into data protection carried out by PHS can be found in the following link: https://www.opendata.nhs.scot/about and https://publichealthscotland.scot/our-privacy-notice/organisational-background/.

The data checks we performed were to see if there was any personally identifiable information contained in each data set - potential personal details that might be contained in these data sets would be: 

* Name; 
* Address; 
* Email address; 
* Date of birth; 
* NHS number; 
* Next-of-kin contacts; 
* Details of GP.

All of which were not found. As a final legal consideration was how the data was obtained, but by PHS standards, consent is needed to collect and publish this data on PHS - concluding that the data could be used after considering these ethical/legal factors.
