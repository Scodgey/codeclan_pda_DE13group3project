# The purpose of this script is to join the data from the projects 
#raw_data folder prior to subsequent cleaning and wrangling.

<<<<<<< Updated upstream
librarys
=======

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


nhs_data_joined1 <- bind_rows(act_by_board_age_sex, 
                             act_by_board_specialty,
                             act_by_board_deprivation,
                             act_ae_waiting,.id = NULL)

nhs_data_joined2 <- bind_rows(admis_board_age_sex,
                              admis_board_deprivation,
                              admis_board_specialty,.id = NULL)

nhs_data_joined3 <-bind_rows(bed_by_board_treatment_specialty,
                             delayed_discharge_beddays_board,
                             .id = NULL)

                        

write_csv(nhs_data_joined1,"raw_data/nhs_data_joined1.csv")
write_csv(nhs_data_joined2,"raw_data/nhs_data_joined2.csv")
write_csv(nhs_data_joined3,"raw_data/nhs_data_joined3.csv")


>>>>>>> Stashed changes
