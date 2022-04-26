# The purpose of this script is to join the data from the projects 
#raw_data folder prior to subsequent wrangling and filtering needed for analysis. 

###############################################.
## Individual Data sets
###############################################.


# The below datasets are read-in and will be binded into a single dataframe.

#Activity by Board (Age & Sex)

act_by_board_age_sex <- read_csv(here("raw_data/activity_by_board_age_sex.csv")) %>% 
  clean_names()

#Activity by Board & Speciality
act_by_board_specialty <- read_csv(here("raw_data/activity_by_board_and_specialty.csv")) %>% 
  clean_names()

#Activity by Board & Deprivation
act_by_board_deprivation <- read_csv(here("raw_data/activity_by_board_deprivation.csv")) %>% 
  clean_names()
  
#Activity A&E - Monthly Waiting Times
act_ae_waiting <-read_csv(here("raw_data/monthly_ae_activity_waitingtimes.csv")) %>% 
  clean_names()

#Beds by NHS Board of Treatment
bed_by_board_treatment_specialty <- read_csv(here("raw_data/beds_by_nhs_board_of_treatment_and_specialty.csv")) %>% 
  clean_names()
  
#Delayed Discharge Bed Days
delayed_discharge_beddays_board <- read_csv(here("raw_data/delayed-discharge-beddays-health-board.csv")) %>% 
  clean_names()

#Hospital Admissions by Board, Age & Sex
admis_board_age_sex <- read_csv(here("raw_data/hospital_admissions_by_hb_age_sex.csv")) %>% 
  clean_names()
  
#Hospital Admissions by Board, Deprivation
admis_board_deprivation <- read_csv(here("raw_data/hospital_admissions_hb_deprivation.csv")) %>% 
  clean_names()
  
#Hospital Admissions by Board, Speciality
admis_board_specialty <- read_csv(here("raw_data/hospital_admissions_hb_specialty.csv")) %>% 
  clean_names() 
  

#Hospital Location Data
hospital_locations_lookup_file <- read_csv(here("raw_data/hospital_locations_lookup_file.csv")) %>% 
  clean_names() 

###############################################.
## Joined Data Sets Formation
###############################################.

#Joined Dataset 1
nhs_data_joined1 <- bind_rows(act_by_board_age_sex, 
                             act_by_board_specialty,
                             act_by_board_deprivation,
                             act_ae_waiting,.id = NULL)%>% 
  mutate(quarter_year = str_remove(quarter, pattern = "([Q]*[1-4]+$)"), 
         .after = quarter) %>% 
  mutate(quarter_year = as.numeric(quarter_year)) %>% 
  mutate(quarter =str_remove(quarter, pattern = "(^[0-9]+[0-9]+[0-9]+[0-9]+)"), 
         .after = quarter_year) %>% 
  mutate(season = case_when(
    quarter == "Q1" ~"Spring",
    quarter == "Q2" ~"Summer",
    quarter == "Q3" ~"Autumn",
    quarter == "Q4" ~"Winter"
  ), .after = quarter)

#Joined Dataset 2

nhs_data_joined2 <- bind_rows(admis_board_age_sex,
                              admis_board_deprivation,
                              admis_board_specialty,.id = NULL) %>% 
  mutate(
    week_ending = ymd(week_ending),
   quarter_year = as.yearqtr(week_ending), .after= week_ending,
    quarter = str_remove(quarter_year, pattern = "(^[0-9]+[0-9]+[0-9]+[0-9]+\ )")) %>% 
  mutate(quarter_year = year(quarter_year)) %>% 
  mutate(season = case_when(
    quarter == "Q1" ~"Spring",
    quarter == "Q2" ~"Summer",
    quarter == "Q3" ~"Autumn",
    quarter == "Q4" ~"Winter"
  ), .after = quarter)


#Joined Dataset 3


nhs_data_joined3 <-bind_rows(bed_by_board_treatment_specialty,
                             delayed_discharge_beddays_board,
                             .id = NULL) %>% 
  mutate(quarter_year = str_remove(quarter, pattern = "([Q]*[1-4]+$)"), 
    .after = quarter) %>% 
  mutate(quarter_year = as.numeric(quarter_year)) %>% 
  mutate(quarters =str_remove(quarter, pattern = "(^[0-9]+[0-9]+[0-9]+[0-9]+)"), 
    .after = quarter_year)%>% 
  mutate(season = case_when(
    quarters == "Q1" ~"Spring",
    quarters == "Q2" ~"Summer",
    quarters == "Q3" ~"Autumn",
    quarters == "Q4" ~"Winter"
  ), .after = quarter)


#Joined Dataset 4 - NHS locations added to bed data.

nhs_data_joined4 <- nhs_data_joined3 %>% 
#change variable name to reflect definitions.
  rename("available_staffed_beds" = "all_staffed_beds") %>% 
#Select will need to change if variables changed in joined data set 3. 
  select(-c(month_of_delay:average_daily_number_of_delayed_beds))%>% 
  mutate(average_available_staffed_beds = round(average_available_staffed_beds),
         average_occupied_beds = round(average_occupied_beds), 
         percentage_occupancy = round(percentage_occupancy)) %>% 
  filter(!is.na(quarter_year)) %>% 
#filter years to 2018 Q1 on-wards, as agreed with project group.  
  filter(quarter_year >= 2018 & quarters %in% c("Q1", "Q2", "Q3", "Q4")) %>% 
#Upon review of the data it was identified that every second observation, 
# had a statistical qualifier "d" (see qualifier information for definition). 
#Based on the definition, and the intent of this analysis these observations 
#were removed. #These were filtered out prior to a join with the look_up file. 
  filter(!location_qf %in% "d") %>% 
  left_join(hospital_locations_lookup_file, by = "location") %>% 
#End joined table at postcode variable. 
  select(-c(address_line:based_on_postcode))


###############################################.
## Joined & Single Data Sets - Written to CSV
###############################################.

# Writing the joined data to folder for use in analysis. 

write_csv(nhs_data_joined1,"raw_data/nhs_data_joined1.csv")
write_csv(nhs_data_joined2,"raw_data/nhs_data_joined2.csv")
write_csv(nhs_data_joined3,"raw_data/nhs_data_joined3.csv")
write_csv(nhs_data_joined4,"raw_data/nhs_data_joined4.csv")
write_csv(hospital_locations_lookup_file, "raw_data/hospital_locations_lookup_file.csv")




