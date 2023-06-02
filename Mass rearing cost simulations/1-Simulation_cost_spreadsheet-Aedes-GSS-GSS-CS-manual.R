rm(list = ls())

#### ~~~~~~~~ ####
#### Packages ####

library(tidyverse)
library(strindr)
library(purrr)
library(tictoc)

#### ~~~~~~~ ####
#### INPUTS  ####
#### > 1. Start up parameters and Summary ####
parameter.lists = {list(
  production.goals = 
    list(
      Weekly_pupal_production = 21, # (Mpp/week)
      Number_of_weeks_with_releases_per_year = 52 
    ),
  
  #### > 2. Biological parameters ####
  biological.parm =
    list(
      #### >> 2.1 Rearing efficiency ####
      Egg_hatching_rate = 0.85,
      sex_ratio = .5, # male ratio
      #### >>> 2.1.1. Pupation dynamics ####
      male_pupae_recovery_after_first_sorting = 0.65,
      male_pupae_recovery_after_second_sorting = 0.25 * 0.3 * 2,
      male_pupae_recovery_after_third_sorting = 0.2 * 0.1 * 2,
      female_pupae_recovery_after_first_sorting = 0.32,
      female_pupae_recovery_after_second_sorting = 0.25 * 0.7 * 2,
      female_pupae_recovery_after_third_sorting = 0.2 * 0.9 * 2,
      Number_of_tilting_or_sex_sorting_operations_for_MO = 1,
      #Survival pupae to flying males
      Number_of_tilting_or_sex_sorting_operations_for_colony = 1,
      Survival_pupae_to_flying_males = 0.95,
      Survival_pupae_to_flying_females = 0.95,
      Average_number_of_eggs_per_females_for_the_1st_gonotrophic_cycle = 30,
      Average_number_of_eggs_per_females_for_the_2nd_gonotrophic_cycle = 20,
      Average_number_of_eggs_per_females_for_the_3rd_gonotrophic_cycle = 10,
      #### >> 2.2. Life cycle information (days) ####
      Pre_oviposition_period = 8,
      duration_of_gonotrophic_cycle = 7,
      # Number of gonotrophic cycles before discarding Colony cages
      number_of_gonotrophic_cycles_colonies = 3,
      Duration_of_males_holding_before_release = 4,
      #Duration of the larval cycle until first day of pupation
      Duration_of_the_larval_cycle__Colony = 6,
      #### >> 2.3 Densities ####
      #Eggs density (eggs/mL)
      Egg_density = 91000,
      #Pupae density (pupae/L)
      Pupa_density = 333333
    ),
  
  #### > 3. Capacity of main equipment ####
  main.equipment.capacity = 
    list(
      #### >> 3.1 Larval trays ####
      # larvae/mL
      density_of_larvae_in_colony_trays = 3,
      # dimensions of colony larval trays (cm)
      depth_of_colony_larval_tray = 1,
      Larval_tray_length = 60,
      Larval_tray_width = 100,
      # cm
      height_of_tray_columns = 170,
      free_space_between_trays = 2.5,
      
      #### >> 3.2 Adult cages ####
      #### >>> 3.2.1 MO ####
      # cm2/adult
      Vertical_resting_space_in_MO_cages = 1,
      # Vertical net in MO cages 
      # (compartments ; cm high ; cm wide ; cm long)
      MO_cage_compartment = 12,
      MO_cage_height = 25,
      MO_cage_width = 10,
      MO_cage_length = 6,
      
      #### >>> 3.2.2 colony####
      # cm2/adult
      Vertical_resting_place_for_colony_cages = 1.2,
      # Vertical net in colony cages 
      # (cm high ; cm wide ; cm long ; cm2 per cage)
      Net_colony_cages_height = 100,
      Net_colony_cages_width = 20,
      Net_colony_cages_length = 90
    ),
  
  #### > 4. Rearing task schedule ####
  rearing.task.schedule = 
    list(
      # Frequencies = every n days
      frequency_of_blood_feeding = 3,
      frequency_of_egg_collection = 3,
      Number_of_feeding_rounds_per_blood_membrane = 5,
      Frequency_of_Colony_cage_washing = 1,
      # Frequency of  MO cage washing (every n holding cycle)
      Frequency_of_MO_cage_washing = 1,
      #### >> 4.3. Filter colony ####
      Increase_factor_mother_colony = 1.08
    ),
  
  #### > 5. Diet formula ####
  diet.formula = 
    list(
      #### >> 5.1. Laval diet ####
      #### >>> 5.1.1. Composition ####
      Beef_liver_powder = 0,
      Tuna_meal = 50,
      Brewer_yeast = 15,
      BSF_yeast = 35,
      Component_5 = 0,
      Component_6 = 0,
      Concentration_in_water = 4,
      #### >>> 5.1.2 Larval feeding regime ####
      # (mg ingredients/larva, g/tray, mL of diet solution/tray)
      Ration_per_one_larva_on_day_1 = 0.66,
      Ration_per_one_larva_on_day_2 = 0,
      Ration_per_one_larva_on_day_3 = 0,
      Ration_per_one_larva_on_day_4 = 0.66,
      Ration_per_one_larva_on_day_5 = 0.44,
      Ration_per_one_larva_on_day_6 = 0.66,
      Ration_per_one_larva_on_day_7_after_1st_sorting = 0,
      Ration_per_one_larva_on_day_8_after_2nd_sorting = 0,
      
      #### >> 5.2. Adult diet ####
      #### >>> 5.2.1 Composition ####
      Sugar_percentage_in_adult_diets = 10,
      
      #### >>> 5.2.2 Dosage #### 
      # kg/cage
      Weight_of_sugar_per_colony_cage = 0.03,
      Weight_of_sugar_per_MO_cage = 0.1,
      # days
      Replenishment_of_water_in_adult_cages = 5,
      
      #### >>> 5.2.3 Blod feeding ####
      # mg/female/intake
      Average_Blood_intake_per_female = 1.50
    ),
  
  #### > 6. Diet requirements ####
  # RAS
  
  #### > 7. Storage of diet ingredients ####
  # (storage time in days, volume in m3, height in m, area in m2)
  diet.storage = 
    list(
      Beef_liver_powder_storage_time = 90,
      Beef_liver_powder_storage_bags_per_m3 = 6, 
      Beef_liver_powder_kg_per_unit = 25,
      Beef_liver_powder_height = 1,
      Tuna_meal_storage_time = 90,
      Tuna_meal_storage_bags_per_m3 = 6,
      Tuna_meal_kg_per_unit = 25,
      Tuna_meal_height = 1,
      Brewer_yeast_storage_time = 90,
      Brewer_yeast_storage_bags_per_m3 = 6, 
      Brewer_yeast_kg_per_unit = 25,
      Brewer_yeast_height = 1,
      BSF_yeast_storage_time = 90,
      BSF_yeast_storage_bags_per_m3 = 6, 
      BSF_yeast_kg_per_unit = 25,
      BSF_yeast_height = 1,
      Component_5_storage_time = 90,
      Component_5_storage_bags_per_m3 = 6, 
      Component_5_kg_per_unit = 25,
      Component_5_height = 1,
      Component_6_storage_time = 90,
      Component_6_storage_bags_per_m3 = 6, 
      Component_6_kg_per_unit = 25,
      Component_6_height = 1,
      Total_sugar_for_adult_diet_storage_time = 90,
      Total_sugar_for_adult_diet_storage_bags_per_m3 = 6, 
      Total_sugar_for_adult_diet_kg_per_unit = 50,
      Total_sugar_for_adult_diet_height = 1
    ),
  
  #### > 8. rearing equipment ####
  rearing.equipment = 
    list(
      
      #### >> 8.1. Larval trays ####
      Oversize_factor_larval_trays = 1.3,
      
      #### >> 8.2. Racks for larval trays ####
      Oversize_factor_racks = 1.2,
      
      #### >> 8.3. Cages for colonies ####
      Oversize_factor_cages = 1.2,
      
      #### >> 8.4. Cages for Release Males ####
      Oversize_factor_RM_cages = 1.3,
      
      #### >> 8.5. Irradiator ####
      Number_of_pupae_per_irradiation_canister = 375000,
      Duration_of_one_irradiation_operation = 0.17,
      Irradiator_max_time = 12,
      Irradiator_backup = 0,
      
      #### >> 8.6. L1 sex sorter (COPAS) for GSS and GSS-CS ####
      L1_sex_sorter_male_recovery = 0.696,
      L1_sex_sorter_female_recovery = 0.696,
      L1_sex_sorter_throwput = 0.133,
      L1_sex_sorter_max_time = 5,
      L1_sex_sorter_backup = 1,
      
      #### >> 8.7 Pupal sex sorter (for all) ####
      Pupal_sex_sorter_male_recovery = 0.4273, 
      # IAEA data => automated (Chinese assays): 40.30 ± 5.52% ; 
      # manual: 42.73 ± 2.75% for 2 rounds
      Pupal_sex_sorter_female_recovery = 0.3806, 
      # IAEA data => automated (Chinese assays): 36.96 ± 4.24% ; 
      # manual: 38.06 ± 1.19% for 2 rounds
      Pupal_sorter_throwput = 0.05, # IAEA data manual 0.05 Mpp/h
      Pupal_sorter_max_time = 5,
      Pupal_sorter_backup = 1,
      Male_recovery_for_GSS_filter_double_check = .90, 
      # Filter colonies have been sorted as L1s already. 
      # Removing the top 10% is probably sufficient for 
      # eliminating recombinant females
      
      #### >> 8.8. L1 counter for classical only #### 
      # (otherwise done by the L1 sorter)
      L1_counter_capacity = 20,
      L1_counter_max_time = 4,
      L1_counter_backup = 1,
      
      #### >> 8.9 Larval diet mixer####
      Larval_diet_mixer_capacity = 40,
      Larval_diet_mixer_duration_per_batch = 0.25,
      Larval_diet_mixer_max_time = 3,
      Larval_diet_mixer_backup = 0,
      
      #### >> 8.10. Adult diet mixer ####
      Adult_diet_mixer_capacity = 20,
      Adult_diet_mixer_duration_per_batch = 0.25,
      Adult_diet_mixer_max_time = 3,
      Adult_diet_mixer_backup = 0,
      
      #### >> 8.11. Larval diet feeder ####
      Larval_feeder_capacity = 45,
      Larval_feeder_max_time = 4,
      Larval_feeder_backup = 1,
      
      #### >> 8.12. Blood feeders ####
      Blood_feeder_capacity = 2,
      Blood_feeder_max_time = 6,
      Blood_feeder_backup = 1,
      
      #### >> 8.13 Tray washing machine ####
      Tray_washer_capacity = 200,
      Tray_washer_max_time = 6,
      Tray_washer_backup = 0,
      
      #### >> 8.14 Cage washing machine in rearing facility ####
      Cage_washer_capacity = 2.4,
      Cage_washer_max_time = 6,
      Cage_washer_backup = 0,
      
      #### >> 8.15. Cage washing machine in release facility ####
      MO_cage_washer_capacity = 12,
      MO_cage_washer_max_time = 6,
      MO_cage_washer_backup = 0
    ),
  
  #### > 9. Environmental conditions ####
  # RAS
  
  #### > 10. Water requirements ####
  water.requirements = 
    list(
      #### >> 10.1 Water for rearing ####
      #### >> 10.2. Water for equipment washing ####
      Water_per_tray_wash = 0.5,
      Water_per_cage_wash = 2,
      Water_per_MO_cage_wash = 3,
      
      #### >> 10.3. Water for room cleaning ####
      Percentage_of_water_for_room_cleaning = 0.4
    ),
  
  #### > 11. Floor area calculation ####
  floor.area.calculation = 
    list(
      #### >> 11.1. Mass rearing facility ####
      #### >>> 11.1.1. Larval area ####
      Rack_oversize_factor = 2,
      #### >>> 11.1.2. Adult area ####
      Colony_cage_oversize_factor = 2,
      #### >>> 11.1.3. Common area ####
      Storage_oversize_factor = 3,
      Offices_size_per_staff = 5,
      WC_size_per_staff = 3,
      Percentage_corridors = 0.1,
      Diet_preparation_area = 10,
      Tray_washing_area = 15,
      Cage_washing_area = 15,
      QC_lab_area = 20,
      Workshop_area = 20,
      Warehouse_area = 20,
      Office_staff = 6,
      WC_staff = 10,
      
      #### >> 11.2. Release facility ####
      MO_cage_oversize_factor = 2,
      MO_cages_loading_area = 15,
      MO_QC_lab_area = 20,
      MO_adult_packaging_area = 15,
      MO_diet_preparation_area = 15,
      MO_Warehouse_area = 10,
      MO_office_staff = 2,
      MO_wc_staff = 6
    ),
  
  #### > 12. Construction cost ####
  construction.cost = 
    list(
      
      #### >> 12.1. Mass rearing facility ####
      Cost_m2_office_labs_wc_irradiation_corridor = 1500,
      Cost_m2_rearing_rooms = 1200,
      Cost_m2_storage_warehouse = 1000,
      Expected_lifespan_mass_rearing_facility = 20,
      
      #### >> 12.2. Release facility####
      Cost_m2_chilling_room = 2000,
      Expected_lifespan_release_facility = 20
      
      # Disclaimer: The construction costs will largely vary across countries. 
      # The unit costs of the rearing rooms must include the cost of climatisation. 
      # The construction costs does not include the purchase of the terrain for building. 
    ),
  
  #### > 13. Workload ####
  workload = 
    list(
  
      #### >> 13.1. Mass rearing facility####
      Egg_hatching_work_rate = 2,
      Tray_hanging_work_rate = 0.45,
      L1_dosage_work_rate = 0.25,
      L4_loading_work_rate = 0.05,
      Larval_feeding_work_rate = 0.25,
      Tray_tilting_work_rate = 1,
      Insect_packing_for_irradiation_work_rate = 0,
      Colony_cage_loading_work_rate = 0.2,
      Colony_cage_bloodfeeding_work_rate = 0.05,
      Egg_collection_work_rate = 0.05,
      Egg_storage_work_rate = 0,
      Larval_diet_prep_work_rate = 0.15,
      Adult_diet_prep_work_rate = 0.1,
      Blood_collection_weekly = 1,
      Blood_collection_work_rate = 5,
      Blood_doses_prep_work_rate = 0.1,
      Net_working_time_per_staff_per_day = 7.5,
      
      #### >> 13.2. Release facility####
      MO_cage_loading_work_rate = 0.1,
      MO_cage_chilling_work_rate = 0.1,
      MO_adult_collection_work_rate = 0.15,
      MO_adult_packing_for_release_work_rate = 0.1,
      
      #### >> 13.3. Total number of staff for 7/365####
      Majoring_factor_labourer = 1.7,
      Majoring_factor_team_leader = 1.5,
      Majoring_factor_QC_manager = 1,
      Majoring_factor_QC_technician = 1,
      Majoring_factor_maintenance_manager = 1,
      Majoring_factor_maintenance_officer = 1,
      Majoring_factor_admin_assistant = 1,
      Majoring_factor_manager = 1,
      
      #### >>> 13.3.1. Mass rearing facility ####
      QC_managers_needed_mass_rearing = 1,
      Manager_needed_mass_rearing = 1
      
      #### >>> 13.3.2. Release facility####
      # RAS
      
      #### >>> 13.3.3 Total ####
      # RAS
    ),
  
  #### > 14. Equipment budget ####
  equipment.budget = 
    list(
      
      #### >> 14.1. Mass rearing facility #####
      Larval_trays_unit_price = 80,
      Larval_trays_life_expectancy = 6,
      Racks_for_larval_trays_unit_price = 7000,
      Racks_for_larval_trays_life_expectancy = 10,
      Cages_for_Colonies_unit_price = 350,
      Cages_for_Colonies_life_expectancy = 10,
      Irradiator_unit_price = 250000, # X-ray (Raycell Radsource V)
      Irradiator_life_expectancy = 10,
      L1_Sex_sorter_unit_price = 50000, 
      # Refurbished COPAS is 50k € while new is 350k €
      L1_Sex_sorter_life_expectancy = 10, 
      # Estimated
      Pupal_sex_sorter_unit_price = 40000, 
      # IAEA data => manual: 2k ; automated (Chinese assays): 40k
      Pupal_sex_sorter_life_expectancy = 10,
      L1_counter_unit_price = 2000,
      L1_counter_life_expectancy = 5,
      Larval_diet_mixer_unit_price = 3000,
      Larval_diet_mixer_life_expectancy = 5,
      Adult_diet_mixer_unit_price = 2000,
      Adult_diet_mixer_life_expectancy = 6,
      Larval_diet_feeder_unit_price = 3000,
      Larval_diet_feeder_life_expectancy = 5,
      Blood_feeders_unit_price = 2000,
      Blood_feeders_life_expectancy = 5,
      Tray_washing_machine_in_mass_rearing_facility_unit_price = 20000,
      Tray_washing_machine_in_mass_rearing_facility_life_expectancy = 6,
      Cage_washing_machine_in_mass_rearing_facility_unit_price = 20000,
      Cage_washing_machine_in_mass_rearing_facility_life_expectancy = 6,
      Equipment_for_basic_QC_lab_number = 1,
      Equipment_for_basic_QC_lab_unit_price = 12000,
      Equipment_for_basic_QC_lab_life_expectancy = 5,
      Workshop_equipment_number = 1,
      Workshop_equipment_unit_price = 25000,
      Workshop_equipment_life_expectancy = 10,
      Blood_storage_number = 1,
      Blood_storage_unit_price = 5000,
      Blood_storage_life_expectancy = 6,
      
      #### >> 14.2. Release facility ####
      Cages_for_Release_Males_unit_price = 84,
      Cages_for_Release_Males_life_expectancy = 4,
      Cage_washing_machine_in_release_facility_unit_price = 20000,
      Cage_washing_machine_in_release_facility_life_expectancy = 6,
      Equipment_for_basic_QC_lab_MO_number = 1,
      Equipment_for_basic_QC_lab_MO_unit_price = 6000,
      Equipment_for_basic_QC_lab_MO_life_expectancy = 5,
      Workshop_equipment_MO_number = 1,
      Workshop_equipment_MO_unit_price = 10000,
      Workshop_equipment_MO_life_expectancy = 6
      
      #### >> 14.2. Total ####
      # RAS 
    ),
  
  #### > 15. Diet and consumable costs####
  diet.and.consumable = 
    list(
      #### >> 15.1. Larval diet####
      Beef_liver_powder_unit_cost = 80,
      Tuna_meal_unit_cost = 0.7,
      Brewer_yeast_unit_cost = 8.5,
      BSF_powder_unit_cost = 8.5,
      Component_5_unit_cost = 0,
      Component_6_unit_cost = 0,
      Water_including_the_initial_load_of_trays_unit_cost = 3,
      
      #### >> 15.2. Adult diet####
      Sugar_for_adult_colony_unit_cost = 1,
      Blood_for_adult_diet_unit_cost = 2,
      
      #### >> 15.3. Other consumables####
      Radiation_dosimeters_unit_cost = 1.5,
      Consumables_without_inventoring_unit_cost = 0.2
    )
)

}

#### ~~~~~~~~~~~~####
#### CALCULATION #### 
# method in c('GSS', 'GSS-CS', 'Size.manual', 'Size.auto')
model.function =
  function(
    method = 'Size.manual',
    parameter.lists = parameter.lists
  ){
    lapply(1:length(parameter.lists), function(x)attach(parameter.lists[[x]]))
    if(!(method %in% c('GSS', 'GSS-CS', 'Size.manual', 'Size.auto'))){
      return("Wrong method entered")}
    
    #### > 1. Start up parameters and Summary ####
    # No calculations 
    
    #### > 2. Biological parameters ####
    #### >> 2.1. Rearing efficiency ####
    Survival_eggs_to_pupae = 0.8212 *
      depth_of_colony_larval_tray^(-0.185) /
      Survival_pupae_to_flying_females
    
    #### >>> 2.1.1. Pupation dynamics ####
    overall_male_pupae_recovery = 
      male_pupae_recovery_after_first_sorting + 
      male_pupae_recovery_after_second_sorting + 
      male_pupae_recovery_after_third_sorting
    
    overall_female_pupae_recovery = 
      female_pupae_recovery_after_first_sorting + 
      female_pupae_recovery_after_second_sorting + 
      female_pupae_recovery_after_third_sorting
    
    Oviposition_period = 
      (number_of_gonotrophic_cycles_colonies - 1) * 
      duration_of_gonotrophic_cycle
    
    if(number_of_gonotrophic_cycles_colonies == 1){
      Average_oviposition_rate_during_oviposition_period = 
        Average_number_of_eggs_per_females_for_the_1st_gonotrophic_cycle /
        Oviposition_period
    }else if(number_of_gonotrophic_cycles_colonies==2){
      Average_oviposition_rate_during_oviposition_period = 
        (Average_number_of_eggs_per_females_for_the_1st_gonotrophic_cycle +
           Average_number_of_eggs_per_females_for_the_2nd_gonotrophic_cycle)/
        Oviposition_period
    }else{
      Average_oviposition_rate_during_oviposition_period = 
        (Average_number_of_eggs_per_females_for_the_1st_gonotrophic_cycle +
           Average_number_of_eggs_per_females_for_the_2nd_gonotrophic_cycle + 
           Average_number_of_eggs_per_females_for_the_3rd_gonotrophic_cycle)/
        Oviposition_period
    }
    
    #### >> 2.2. Life cycle information (days) ####
    Duration_of_cage = 
      Oviposition_period + 
      Pre_oviposition_period
    
    #### >> 2.3. Densities ####
    # No calculation
    
    #### > 3. Capacity of main equipment ####
    #### >> 3.1. Larval trays ####
    volume_of_colony_larval_trays = 
      depth_of_colony_larval_tray * 
      Larval_tray_length * 
      Larval_tray_width
    
    L1_per_colony_tray = 
      density_of_larvae_in_colony_trays * 
      volume_of_colony_larval_trays
    
    Number_of_larval_trays_per_rack__Colony = 
      floor(
        height_of_tray_columns/
          (free_space_between_trays + 
             depth_of_colony_larval_tray)
      )
    
    #### >> 3.2. Adult cages ####
    #### >>> 3.2.1. MO ####
    Vertical_net_in_colony_cages =
      2 * MO_cage_compartment * 
      (MO_cage_width + MO_cage_length) * 
      MO_cage_height
    
    Males_per_MO_cage = 
      Vertical_net_in_colony_cages / 
      Vertical_resting_space_in_MO_cages
    
    pupae_load_per_MO_cage = 
      Males_per_MO_cage / 
      Survival_pupae_to_flying_males
    
    #### >>> 3.2.2. Colony ####
    Vertical_resting_in_colony_cages =
      2 * Net_colony_cages_length * 
      Net_colony_cages_height + 
      2 * Net_colony_cages_width *
      Net_colony_cages_height
    
    Adults_in_colony_cages = 
      Vertical_resting_in_colony_cages / 
      Vertical_resting_place_for_colony_cages
    
    female_per_male = 
      round(
        (1-female_pupae_recovery_after_first_sorting) /
          (1-male_pupae_recovery_after_first_sorting), 
        digits=1)
    
    females_in_colony_cages = 
      Adults_in_colony_cages * 
      (female_per_male / 
         (1+female_per_male))
    
    female_pupae_load_per_colony_cage =
      females_in_colony_cages / 
      Survival_pupae_to_flying_females
    
    #### > 4. Rearing task schedule ####
    #### >> 4.1. Male Only colony ####
    Weekly_production_of_flying_males_for_release =
      Weekly_pupal_production *
      Survival_pupae_to_flying_males
    
    MO_cages_loaded_per_day = 
      ceiling(Weekly_pupal_production
              * 1000000 / 7) / 
      pupae_load_per_MO_cage
    
    Total_number_of_cages_permanently_in_use_in_the_emergence_center = 
      MO_cages_loaded_per_day * 
      Duration_of_males_holding_before_release
    
    Number_of_irradiation_operations_per_day = 
      ceiling(Weekly_pupal_production *
                1000000 / 7 /
                Number_of_pupae_per_irradiation_canister)
    
    Male_L1__to_be_seeded_per_day_for_MO = 
      Weekly_pupal_production / 7 /
      Survival_eggs_to_pupae
    
    Larval_trays_to_be_loaded_with_L1_per_day_for_MO = 
      if(method %in% c('GSS', 'GSS-CS')){
        ceiling(Male_L1__to_be_seeded_per_day_for_MO/
                  L1_per_colony_tray*1000000)
      }else{
        Increase_factor_mother_colony * 
          Weekly_pupal_production/ 
          sex_ratio / 
          7 /
          Survival_eggs_to_pupae / 
          Pupal_sex_sorter_male_recovery / 
          L1_per_colony_tray * 1000000 /
          if(Number_of_tilting_or_sex_sorting_operations_for_colony == 1){
            male_pupae_recovery_after_first_sorting
          }else if(Number_of_tilting_or_sex_sorting_operations_for_colony == 2){
            (male_pupae_recovery_after_first_sorting + male_pupae_recovery_after_second_sorting)
          }else{
            (male_pupae_recovery_after_first_sorting + 
               male_pupae_recovery_after_second_sorting + 
               male_pupae_recovery_after_third_sorting)
          }
      }
    
    Larval_racks_to_be_loaded_with_L1_per_day_for_MO = 
      ceiling(Larval_trays_to_be_loaded_with_L1_per_day_for_MO / 
                Number_of_larval_trays_per_rack__Colony)
    
    if(Number_of_tilting_or_sex_sorting_operations_for_MO == 1) {
      Number_of_larval_trays_to_be_loaded_after_the_1st_sorting_for_MO = 0
    } else {
      Number_of_larval_trays_to_be_loaded_after_the_1st_sorting_for_MO = 
        ceiling(
          Larval_trays_to_be_loaded_with_L1_per_day_for_MO *
            (1 - male_pupae_recovery_after_first_sorting))
    }
    
    Number_of_larval_racks_to_be_loaded_after_the_1st_sorting_for_MO = 
      ceiling(
        Number_of_larval_trays_to_be_loaded_after_the_1st_sorting_for_MO / 
          Number_of_larval_trays_per_rack__Colony)
    
    if(Number_of_tilting_or_sex_sorting_operations_for_MO == 3){
      Number_of_larval_trays_to_be_loaded_after_the_2nd_sorting_for_MO = 
        ceiling(Larval_trays_to_be_loaded_with_L1_per_day_for_MO * 
                  (1-(male_pupae_recovery_after_first_sorting +
                        male_pupae_recovery_after_second_sorting)))
    } else {
      Number_of_larval_trays_to_be_loaded_after_the_2nd_sorting_for_MO = 0
    }
    
    Number_of_larval_racks_to_be_loaded_after_the_2nd_sorting_for_MO = 
      ceiling(
        Number_of_larval_trays_to_be_loaded_after_the_2nd_sorting_for_MO / 
          Number_of_larval_trays_per_rack__Colony)
    
    Total_number_of_larval_trays_to_be_loaded_everyday_for_MO =
      Larval_trays_to_be_loaded_with_L1_per_day_for_MO + 
      Number_of_larval_trays_to_be_loaded_after_the_1st_sorting_for_MO + 
      Number_of_larval_trays_to_be_loaded_after_the_2nd_sorting_for_MO
    
    Total_number_of_larval_trays_to_be_fed_everyday_for_MO = 
      Larval_trays_to_be_loaded_with_L1_per_day_for_MO *
      Duration_of_the_larval_cycle__Colony +
      Number_of_larval_trays_to_be_loaded_after_the_1st_sorting_for_MO + 
      Number_of_larval_trays_to_be_loaded_after_the_2nd_sorting_for_MO
    
    Total_number_of_larval_trays_permanently_in_use_for_MO = 
      Total_number_of_larval_trays_to_be_fed_everyday_for_MO
    
    Total_number_of_larval_racks_permanently_in_use_for_MO = 
      Larval_racks_to_be_loaded_with_L1_per_day_for_MO * 
      Duration_of_the_larval_cycle__Colony + 
      Number_of_larval_racks_to_be_loaded_after_the_1st_sorting_for_MO + 
      Number_of_larval_racks_to_be_loaded_after_the_2nd_sorting_for_MO
    
    #### >> 4.2. Rearing colony ####
    Expected_number_of_male_pupae_to_be_produced_per_day = 
      Weekly_pupal_production/7
    
    number.of.rearing.colony = 
      if(method == 'GSS-CS'){2}else{1}
    
    eggs_to_be_hatched_per_day_for_male_only_production = 
      if(method %in% c('GSS-CS','GSS')){
        if(Number_of_tilting_or_sex_sorting_operations_for_MO == 1){
          Male_L1__to_be_seeded_per_day_for_MO/ 
            sex_ratio/ 
            Egg_hatching_rate/
            male_pupae_recovery_after_first_sorting/ 
            L1_sex_sorter_male_recovery
          
        }else if (Number_of_tilting_or_sex_sorting_operations_for_MO == 2){
          Male_L1__to_be_seeded_per_day_for_MO/
            sex_ratio/ 
            Egg_hatching_rate /
            (male_pupae_recovery_after_first_sorting +
               male_pupae_recovery_after_second_sorting) /
            L1_sex_sorter_male_recovery
          
        } else {
          Male_L1__to_be_seeded_per_day_for_MO /
            sex_ratio / 
            Egg_hatching_rate /
            (male_pupae_recovery_after_first_sorting + 
               male_pupae_recovery_after_second_sorting +
               male_pupae_recovery_after_third_sorting) /
            L1_sex_sorter_male_recovery}
      }else{
        if(Number_of_tilting_or_sex_sorting_operations_for_MO == 1){
          Male_L1__to_be_seeded_per_day_for_MO * 
            Increase_factor_mother_colony/
            sex_ratio/ 
            Egg_hatching_rate/
            male_pupae_recovery_after_first_sorting/ 
            Pupal_sex_sorter_male_recovery
          
        }else if (Number_of_tilting_or_sex_sorting_operations_for_MO == 2){
          Male_L1__to_be_seeded_per_day_for_MO* 
            Increase_factor_mother_colony/
            sex_ratio/ 
            Egg_hatching_rate /
            (male_pupae_recovery_after_first_sorting +
               male_pupae_recovery_after_second_sorting) /
            Pupal_sex_sorter_male_recovery
          
        } else {
          Male_L1__to_be_seeded_per_day_for_MO * 
            Increase_factor_mother_colony /
            sex_ratio / 
            Egg_hatching_rate /
            (male_pupae_recovery_after_first_sorting + 
               male_pupae_recovery_after_second_sorting +
               male_pupae_recovery_after_third_sorting) /
            Pupal_sex_sorter_male_recovery}
      }
    
    eggs_to_be_hatched_per_week_for_male_only_production = 
      7 * eggs_to_be_hatched_per_day_for_male_only_production
    
    both_sex_L1_to_be_sorted_per_day_for_male_only = 
      if(method %in% c('GSS', 'GSS-CS')){
        eggs_to_be_hatched_per_day_for_male_only_production *
          Egg_hatching_rate
      }else{
        0
      }
    
    volume_eggs_to_be_hatched_per_day_for_male_only_production = 
      eggs_to_be_hatched_per_day_for_male_only_production / 
      Egg_density * 1000000
    
    Ovipositing_females_permanently_in_the_colony = 
      eggs_to_be_hatched_per_day_for_male_only_production /
      Average_oviposition_rate_during_oviposition_period * 
      1000000
    
    Pre_ovipositing_females_in_the_colony = 
      Ovipositing_females_permanently_in_the_colony *
      Pre_oviposition_period /
      Oviposition_period
    
    Number_of_ovipositing_females_to_be_replaced_everyday = 
      Ovipositing_females_permanently_in_the_colony /
      Oviposition_period
    
    Number_of_pupae_needed_to_replace_females_in_the_rearing_colony = 
      if(method %in% c('GSS', "GSS-CS")){
        Number_of_ovipositing_females_to_be_replaced_everyday /  
          (1-sex_ratio) /
          Survival_pupae_to_flying_females
      } else {
        Number_of_ovipositing_females_to_be_replaced_everyday /  
          (1-sex_ratio) /
          Survival_pupae_to_flying_females / 
          Pupal_sex_sorter_male_recovery
      }
    
    Cage_units_to_be_loaded_per_day_to_produce_the_eggs_for_stockpiling = 
      ceiling(Number_of_ovipositing_females_to_be_replaced_everyday /
                females_in_colony_cages)
    
    Number_of_colony_cages_to_be_blood_fed_per_day_in_the_rearing_colony = 
      ceiling(
        ceiling(
          (Ovipositing_females_permanently_in_the_colony + 
             Pre_ovipositing_females_in_the_colony) /
            females_in_colony_cages) /
          frequency_of_blood_feeding)
    
    Number_of_colony_cages_to_be_collected_for_eggs_per_day_in_the_rearing_colony = 
      ceiling(
        ceiling(
          (Ovipositing_females_permanently_in_the_colony +
             Pre_ovipositing_females_in_the_colony) /
            females_in_colony_cages) /
          frequency_of_egg_collection)
    
    Number_of_eggs_for_female_replacement_needed_from_each_filter_colony_everyday =
      if(method %in% c('GSS', 'GSS-CS')){
        if(Number_of_tilting_or_sex_sorting_operations_for_colony == 1){
          Number_of_ovipositing_females_to_be_replaced_everyday / 
            (1-sex_ratio) / 
            Egg_hatching_rate/
            Survival_eggs_to_pupae/
            Survival_pupae_to_flying_females/
            female_pupae_recovery_after_first_sorting/
            L1_sex_sorter_female_recovery
        } else if (Number_of_tilting_or_sex_sorting_operations_for_colony == 2){
          Number_of_ovipositing_females_to_be_replaced_everyday / 
            (1-sex_ratio) / 
            Egg_hatching_rate /
            Survival_eggs_to_pupae /
            Survival_pupae_to_flying_females /
            (female_pupae_recovery_after_first_sorting +
               female_pupae_recovery_after_second_sorting) /
            L1_sex_sorter_female_recovery
        } else {
          Number_of_ovipositing_females_to_be_replaced_everyday / 
            (1-sex_ratio) / 
            Egg_hatching_rate/
            Survival_eggs_to_pupae/
            Survival_pupae_to_flying_females/
            (female_pupae_recovery_after_first_sorting +
               female_pupae_recovery_after_second_sorting +
               female_pupae_recovery_after_third_sorting) /
            L1_sex_sorter_female_recovery
        }
      }else{
        0
      }
    
    Number_of_L1_both_sex_to_be_sex_sorted_per_day_for_female_replacement =
      if(method %in% c('GSS', 'GSS-CS')){
        Number_of_eggs_for_female_replacement_needed_from_each_filter_colony_everyday *
          Egg_hatching_rate *
          number.of.rearing.colony
      }else{
        0
      }
    
    Number_of_larval_trays_to_be_loaded_per_day_for_female_replacement =
      if(method %in% c('GSS', 'GSS-CS')){
        ceiling(
          Number_of_eggs_for_female_replacement_needed_from_each_filter_colony_everyday *
            Egg_hatching_rate/
            L1_per_colony_tray) * 
          number.of.rearing.colony 
      }else{
        0
      }
    
    Number_of_larval_trays_to_be_reloaded_after_the_first_sorting_for_female_replacement =
      if(Number_of_tilting_or_sex_sorting_operations_for_colony == 1){
        0
      }else{
        ceiling(
          Number_of_larval_trays_to_be_loaded_per_day_for_female_replacement * 
            (1 - (female_pupae_recovery_after_first_sorting)))
      }
    
    Number_of_larval_trays_to_be_reloaded_after_the_second_sorting_for_female_replacement =
      if(Number_of_tilting_or_sex_sorting_operations_for_colony == 3){ 
        ceiling(
          Number_of_larval_trays_to_be_loaded_per_day_for_female_replacement * 
            (1 - (female_pupae_recovery_after_first_sorting +
                    female_pupae_recovery_after_second_sorting)))
      } else {
        0
      }
    
    Number_of_larval_trays_to_be_fed_everyday =
      Number_of_larval_trays_to_be_loaded_per_day_for_female_replacement *
      Duration_of_the_larval_cycle__Colony +
      Number_of_larval_trays_to_be_reloaded_after_the_first_sorting_for_female_replacement +
      Number_of_larval_trays_to_be_reloaded_after_the_second_sorting_for_female_replacement
    
    Total_number_of_trays_permanently_in_use_in_the_larval_room = 
      Number_of_larval_trays_to_be_loaded_per_day_for_female_replacement *
      Duration_of_the_larval_cycle__Colony +
      Number_of_larval_trays_to_be_reloaded_after_the_first_sorting_for_female_replacement +
      Number_of_larval_trays_to_be_reloaded_after_the_second_sorting_for_female_replacement
    
    Total_number_of_racks_permanently_in_use_in_the_larval_room =
      ceiling(
        Number_of_larval_trays_to_be_loaded_per_day_for_female_replacement/
          Number_of_larval_trays_per_rack__Colony) * 
      Duration_of_the_larval_cycle__Colony +
      ceiling(
        Number_of_larval_trays_to_be_reloaded_after_the_first_sorting_for_female_replacement / 
          Number_of_larval_trays_per_rack__Colony) +
      ceiling(Number_of_larval_trays_to_be_reloaded_after_the_second_sorting_for_female_replacement /
                Number_of_larval_trays_per_rack__Colony)
    
    Pre_oviposition_cages_permanently_in_use_for_egg_production = 
      Cage_units_to_be_loaded_per_day_to_produce_the_eggs_for_stockpiling *
      Pre_oviposition_period
    
    Oviposition_cages_permanently_in_use_for_egg_production = 
      Cage_units_to_be_loaded_per_day_to_produce_the_eggs_for_stockpiling *
      Oviposition_period
    
    Total_number_of_cages_permanently_in_use_for_egg_production__Preoviposition_Oviposition = #removed MO
      Pre_oviposition_cages_permanently_in_use_for_egg_production +
      Oviposition_cages_permanently_in_use_for_egg_production
    
    #### >> 4.3. Filter colony####
    if(method %in% c('GSS', 'GSS-CS')){
      Number_of_eggs_for_female_replacement_needed_from_each_filter_colony_week =
        Number_of_eggs_for_female_replacement_needed_from_each_filter_colony_everyday * 7
      
      Number_eggs_for_rearing_colony_and_filter_colony_per_week = 
        if(method %in% c('GSS', 'GSS-CS')){
          Number_of_eggs_for_female_replacement_needed_from_each_filter_colony_week * 
            Increase_factor_mother_colony
        }else{
          eggs_to_be_hatched_per_day_for_male_only_production *
            Increase_factor_mother_colony
        }
      
      Number_eggs_for_rearing_colony_and_filter_colony_per_day = 
        Number_eggs_for_rearing_colony_and_filter_colony_per_week / 7
      
      Number_of_ovipositing_females_in_each_filter = 
        Number_eggs_for_rearing_colony_and_filter_colony_per_day / 
        Average_oviposition_rate_during_oviposition_period 
      
      Number_of_preovipositing_females_in_each_filter = 
        Number_of_ovipositing_females_in_each_filter * 
        Pre_oviposition_period/
        Oviposition_period
      
      Number_of_females_to_be_replaced_everyday_in_each_filter = 
        Number_of_ovipositing_females_in_each_filter/
        Oviposition_period
      
      Number_of_colony_cages_to_be_bloodfed_per_day_in_both_filters = 
        ceiling(
          ceiling(
            (Number_of_ovipositing_females_in_each_filter + 
               Number_of_preovipositing_females_in_each_filter) /
              females_in_colony_cages)/
            frequency_of_blood_feeding) * 
        number.of.rearing.colony
      
      Number_of_colony_cages_to_be_collected_for_eggs_per_day_in_both_filters = 
        ceiling(
          ceiling(
            (Number_of_ovipositing_females_in_each_filter + 
               Number_of_females_to_be_replaced_everyday_in_each_filter) /
              females_in_colony_cages) /
            frequency_of_egg_collection) * 
        number.of.rearing.colony
      
      Number_of_colony_cages_to_be_loaded_per_day_in_both_filters = 
        ceiling(
          Number_of_females_to_be_replaced_everyday_in_each_filter/
            females_in_colony_cages) *
        number.of.rearing.colony
      
      Preoviposition_cages_permanently_in_use_for_egg_production_in_both_filters = 
        Number_of_colony_cages_to_be_loaded_per_day_in_both_filters *
        Pre_oviposition_period
      
      Oviposition_cages_permanently_in_use_for_egg_production_in_both_filters = 
        Number_of_colony_cages_to_be_loaded_per_day_in_both_filters *
        Oviposition_period
      
      Total_number_of_cages_permanently_in_use_for_egg_production_in_both_filters = 
        Preoviposition_cages_permanently_in_use_for_egg_production_in_both_filters +
        Oviposition_cages_permanently_in_use_for_egg_production_in_both_filters
      
      Eggs_to_be_hatched_per_day_to_replace_the_females_in_each_filter =
        ((if(Number_of_tilting_or_sex_sorting_operations_for_colony == 1){ 
          Number_of_females_to_be_replaced_everyday_in_each_filter /
            (1-sex_ratio) / 
            Egg_hatching_rate/
            Survival_eggs_to_pupae/
            Survival_pupae_to_flying_females/
            female_pupae_recovery_after_first_sorting/
            L1_sex_sorter_female_recovery /
            Male_recovery_for_GSS_filter_double_check
        }else if(Number_of_tilting_or_sex_sorting_operations_for_colony == 2){
          Number_of_females_to_be_replaced_everyday_in_each_filter /
            (1-sex_ratio) / 
            Egg_hatching_rate /
            Survival_eggs_to_pupae /
            Survival_pupae_to_flying_females /
            (female_pupae_recovery_after_first_sorting +
               female_pupae_recovery_after_second_sorting) / 
            L1_sex_sorter_female_recovery /
            Male_recovery_for_GSS_filter_double_check
        }else{
          Number_of_females_to_be_replaced_everyday_in_each_filter / 
            (1-sex_ratio) /
            Egg_hatching_rate /
            Survival_eggs_to_pupae /
            Survival_pupae_to_flying_females /
            (female_pupae_recovery_after_first_sorting +
               female_pupae_recovery_after_second_sorting +
               female_pupae_recovery_after_third_sorting)/
            L1_sex_sorter_female_recovery /
            Male_recovery_for_GSS_filter_double_check}
        )) / 1000000
      
      Number_of_L1_both_sex_to_be_sex_sorted_per_day_for_both_filters = 
        Eggs_to_be_hatched_per_day_to_replace_the_females_in_each_filter * 
        Egg_hatching_rate * 
        number.of.rearing.colony
      
      Number_of_larval_trays_to_be_loaded_with_L1_per_day_in_both_filters = 
        ceiling(
          Eggs_to_be_hatched_per_day_to_replace_the_females_in_each_filter * 
            Egg_hatching_rate /
            L1_per_colony_tray * 1000000) * 
        number.of.rearing.colony
      
      Number_of_larval_trays_to_be_loaded_after_the_first_sorting_per_day_in_both_filters = 
        if(Number_of_tilting_or_sex_sorting_operations_for_colony==1){
          0
        } else {
          ceiling(
            Number_of_larval_trays_to_be_loaded_with_L1_per_day_in_both_filters *
              (1 - 
                 mean(c(male_pupae_recovery_after_first_sorting, 
                        female_pupae_recovery_after_first_sorting))
              )
          )
        }
      
      Number_of_larval_trays_to_be_loaded_after_the_second_sorting_per_day_in_both_filters = 
        if(Number_of_tilting_or_sex_sorting_operations_for_colony == 3){
          ceiling(Number_of_larval_trays_to_be_loaded_with_L1_per_day_in_both_filters *
                    (1-
                       mean(c(male_pupae_recovery_after_first_sorting +
                                male_pupae_recovery_after_second_sorting, 
                              female_pupae_recovery_after_first_sorting +
                                female_pupae_recovery_after_second_sorting))
                    )
          )
        }else {0}
      
      Number_of_larval_trays_to_be_fed_everyday_in_both_filters = 
        Number_of_larval_trays_to_be_loaded_with_L1_per_day_in_both_filters *
        Duration_of_the_larval_cycle__Colony + 
        Number_of_larval_trays_to_be_loaded_after_the_first_sorting_per_day_in_both_filters + 
        Number_of_larval_trays_to_be_loaded_after_the_second_sorting_per_day_in_both_filters
      
      Number_of_trays_to_be_sorted_every_day_in_both_filters = 
        Number_of_larval_trays_to_be_loaded_with_L1_per_day_in_both_filters + 
        Number_of_larval_trays_to_be_loaded_after_the_first_sorting_per_day_in_both_filters + 
        Number_of_larval_trays_to_be_loaded_after_the_second_sorting_per_day_in_both_filters
      
      Number_of_trays_to_be_loaded_every_day_in_both_filters = 
        Number_of_trays_to_be_sorted_every_day_in_both_filters
      
      Total_number_of_trays_permanently_in_use_in_the_larval_room_in_both_filters = 
        (Number_of_larval_trays_to_be_loaded_with_L1_per_day_in_both_filters *
           Duration_of_the_larval_cycle__Colony + 
           Number_of_larval_trays_to_be_loaded_after_the_first_sorting_per_day_in_both_filters +
           Number_of_larval_trays_to_be_loaded_after_the_second_sorting_per_day_in_both_filters ) # ERROR *2
      
      Number_of_larval_racks_to_be_loaded_with_L1_per_day_in_both_filters = 
        if(Number_of_larval_trays_to_be_loaded_with_L1_per_day_in_both_filters<10){
          0
          }else{
            ceiling(
              Number_of_larval_trays_to_be_loaded_with_L1_per_day_in_both_filters /
                Number_of_larval_trays_per_rack__Colony)
          }
      
      Number_of_larval_racks_to_be_loaded_after_the_first_sorting_per_day_in_both_filters = # added minimum of racks 
        if(Number_of_larval_trays_to_be_loaded_after_the_first_sorting_per_day_in_both_filters<10){
          0
        }else{
          ceiling(
            Number_of_larval_trays_to_be_loaded_after_the_first_sorting_per_day_in_both_filters /
              Number_of_larval_trays_per_rack__Colony)
        }
      
      Number_of_larval_racks_to_be_loaded_after_the_second_sorting_per_day_in_both_filters =  
        if(Number_of_larval_trays_to_be_loaded_after_the_second_sorting_per_day_in_both_filters){
          0
        }else{
          ceiling(
            Number_of_larval_trays_to_be_loaded_after_the_second_sorting_per_day_in_both_filters /
              Number_of_larval_trays_per_rack__Colony)
        }
      
      Total_number_of_racks_permanently_in_use_in_the_larval_room_in_both_filters = 
        ceiling(
          Number_of_larval_racks_to_be_loaded_with_L1_per_day_in_both_filters * 
            Duration_of_the_larval_cycle__Colony + 
            Number_of_larval_racks_to_be_loaded_after_the_first_sorting_per_day_in_both_filters + 
            Number_of_larval_racks_to_be_loaded_after_the_second_sorting_per_day_in_both_filters) # ERROR *2
      
    }else{
      Number_of_eggs_for_female_replacement_needed_from_each_filter_colony_week = 
        Number_eggs_for_rearing_colony_and_filter_colony_per_week = 
        Number_eggs_for_rearing_colony_and_filter_colony_per_day = 
        Number_of_ovipositing_females_in_each_filter = 
        Number_of_preovipositing_females_in_each_filter = 
        Number_of_females_to_be_replaced_everyday_in_each_filter = 
        Number_of_colony_cages_to_be_bloodfed_per_day_in_both_filters = 
        Number_of_colony_cages_to_be_collected_for_eggs_per_day_in_both_filters = 
        Number_of_colony_cages_to_be_loaded_per_day_in_both_filters = 
        Preoviposition_cages_permanently_in_use_for_egg_production_in_both_filters = 
        Oviposition_cages_permanently_in_use_for_egg_production_in_both_filters = 
        Total_number_of_cages_permanently_in_use_for_egg_production_in_both_filters = 
        Eggs_to_be_hatched_per_day_to_replace_the_females_in_each_filter = 
        Number_of_L1_both_sex_to_be_sex_sorted_per_day_for_both_filters = 
        Number_of_larval_trays_to_be_loaded_with_L1_per_day_in_both_filters = 
        Number_of_larval_trays_to_be_loaded_after_the_first_sorting_per_day_in_both_filters = 
        Number_of_larval_trays_to_be_loaded_after_the_second_sorting_per_day_in_both_filters = 
        Number_of_larval_trays_to_be_fed_everyday_in_both_filters = 
        Number_of_trays_to_be_sorted_every_day_in_both_filters = 
        Number_of_trays_to_be_loaded_every_day_in_both_filters = 
        Total_number_of_trays_permanently_in_use_in_the_larval_room_in_both_filters = 
        Number_of_larval_racks_to_be_loaded_with_L1_per_day_in_both_filters = 
        Number_of_larval_racks_to_be_loaded_after_the_first_sorting_per_day_in_both_filters = 
        Number_of_larval_racks_to_be_loaded_after_the_second_sorting_per_day_in_both_filters = 
        Total_number_of_racks_permanently_in_use_in_the_larval_room_in_both_filters = 0
    }
    
    #### > 5. Diet formula ####
    #### >> 5.1. Laval diet ####
    #### >>> 5.1.1. Composition ####
    Total_compo_larval_diet = 
      Beef_liver_powder + Tuna_meal + 
      Brewer_yeast + BSF_yeast + 
      Component_5 + Component_6
    
    #### >>> 5.1.2 Larval feeding regime ####
    # (mg ingredients/larva, g/tray, mL of diet solution/tray)
    Volume_of_larval_diet_added_on_day_i = c(
      Day_1 = Ration_per_one_larva_on_day_1*L1_per_colony_tray/1000,
      Day_2 = Ration_per_one_larva_on_day_2*L1_per_colony_tray/1000,
      Day_3 = Ration_per_one_larva_on_day_3*L1_per_colony_tray/1000,
      Day_4 = Ration_per_one_larva_on_day_4*L1_per_colony_tray/1000,
      Day_5 = Ration_per_one_larva_on_day_5*L1_per_colony_tray/1000,
      Day_6 = Ration_per_one_larva_on_day_6*L1_per_colony_tray/1000,
      Day_7 = Ration_per_one_larva_on_day_7_after_1st_sorting*L1_per_colony_tray/1000,
      Day_8 = Ration_per_one_larva_on_day_8_after_2nd_sorting*L1_per_colony_tray/1000)
    
    Concentration_of_larval_diet_added_on_day_i = 
      Volume_of_larval_diet_added_on_day_i / 
      (Concentration_in_water / 100)
    
    #### >> 5.2. Adult diet ####
    #### >>> 5.2.1 Composition ####
    Water_percentage_in_adult_diets = 
      100 - Sugar_percentage_in_adult_diets
    
    #### >>> 5.2.2 Dosage ####
    Volume_of_water_per_colony_cage = 
      Weight_of_sugar_per_colony_cage*
      Water_percentage_in_adult_diets/
      Sugar_percentage_in_adult_diets
    
    Volume_of_water_per_MO_cage = 
      Water_percentage_in_adult_diets*
      Weight_of_sugar_per_MO_cage/
      Sugar_percentage_in_adult_diets
    
    #### >>> 5.2.3 Blod feeding ####
    # mL/casing
    Volume_of_blood_per_casing = 
      ceiling(
        Average_Blood_intake_per_female *
          females_in_colony_cages *
          Number_of_feeding_rounds_per_blood_membrane
      )/1000
    
    # mL/cage/day
    Blood_for_colony_females_per_day = 
      ceiling(
        Average_Blood_intake_per_female *
          females_in_colony_cages/1000)
    
    #### > 6. Diet requirements####
    #### >> 6.1. Ingredients required for larval diet ####
    # (Daily, kg/day or L/day)
    Total_volume_added_per_day = (
      sum(Volume_of_larval_diet_added_on_day_i[1:6]) *
        (
          Larval_trays_to_be_loaded_with_L1_per_day_for_MO +
            Number_of_larval_trays_to_be_loaded_per_day_for_female_replacement +
            Number_of_larval_trays_to_be_loaded_with_L1_per_day_in_both_filters 
        ) +
        Volume_of_larval_diet_added_on_day_i[7] *
        (
          Number_of_larval_trays_to_be_loaded_after_the_1st_sorting_for_MO +
            Number_of_larval_trays_to_be_reloaded_after_the_first_sorting_for_female_replacement +
            Number_of_larval_trays_to_be_loaded_after_the_first_sorting_per_day_in_both_filters  
        ) +
        Volume_of_larval_diet_added_on_day_i[8] *
        (
          Number_of_larval_trays_to_be_loaded_after_the_2nd_sorting_for_MO +
            Number_of_larval_trays_to_be_reloaded_after_the_second_sorting_for_female_replacement  +
            Number_of_larval_trays_to_be_loaded_after_the_second_sorting_per_day_in_both_filters 
        )
    )/1000
    
    names(Total_volume_added_per_day) = 'Total_volume_added_per_day'
    daily_ingredients = c(
      Beef_liver_powder_daily = 
        Beef_liver_powder / 100 * 
        Total_volume_added_per_day,
      
      Tuna_meal_daily = 
        Tuna_meal / 100 * 
        Total_volume_added_per_day,
      
      Brewer_yeast_daily = 
        Brewer_yeast / 100 * 
        Total_volume_added_per_day,
      
      BSF_yeast_daily = 
        BSF_yeast / 100 *
        Total_volume_added_per_day,
      
      Component_5_daily = 
        Component_5 / 100 *
        Total_volume_added_per_day,
      
      Component_6_daily = 
        Component_6 / 100 *
        Total_volume_added_per_day
    )
    names(daily_ingredients) = 
      c('Beef_liver', 'Tuna', 
        'Brewer_yeast', 'BSF_yeast', 
        'Comp5', 'Comp6')
    
    Larval_diet_solution_daily = 
      sum(daily_ingredients) / (Concentration_in_water/100)
    
    Water_larval_diet_daily = 
      (Larval_trays_to_be_loaded_with_L1_per_day_for_MO +
         Number_of_larval_trays_to_be_loaded_per_day_for_female_replacement * 
         number.of.rearing.colony +
         Number_of_larval_trays_to_be_loaded_with_L1_per_day_in_both_filters * 
         number.of.rearing.colony) *
      volume_of_colony_larval_trays / 1000 + 
      Larval_diet_solution_daily
    
    #### >> 6.2. Ingredients required for larval diet ####
    # (Weekly, kg/week or L/week)
    Weekly_ingredients = daily_ingredients * 7
    Larval_diet_solution_weekly = Larval_diet_solution_daily * 7
    Water_larval_diet_weekly = Water_larval_diet_daily * 7
    
    #### >> 6.3. Ingredients required for Adult Colony ####
    # (Daily, L/day or kg/day) 
    Water_for_adult_colony_daily =
      Total_number_of_cages_permanently_in_use_for_egg_production__Preoviposition_Oviposition/
      Replenishment_of_water_in_adult_cages *
      Volume_of_water_per_colony_cage
    
    Water_for_release_males_daily = 
      MO_cages_loaded_per_day * 
      Volume_of_water_per_MO_cage
    
    Total_water_for_adult_diet_daily = 
      Water_for_adult_colony_daily + 
      Water_for_release_males_daily
    
    Sugar_for_adult_colony_daily = 
      Total_number_of_cages_permanently_in_use_for_egg_production__Preoviposition_Oviposition *
      Weight_of_sugar_per_colony_cage /
      Replenishment_of_water_in_adult_cages
    
    Sugar_for_release_males_daily = 
      MO_cages_loaded_per_day *
      Weight_of_sugar_per_MO_cage
    
    Total_sugar_for_adult_diet_daily = 
      Sugar_for_adult_colony_daily + 
      Sugar_for_release_males_daily
    
    Blood_for_adult_diet_daily = 
      (Number_of_colony_cages_to_be_blood_fed_per_day_in_the_rearing_colony +
         Number_of_colony_cages_to_be_bloodfed_per_day_in_both_filters * 
         number.of.rearing.colony) *
      Blood_for_colony_females_per_day / 1000 
    
    #### >> 6.4. Ingredients required for Adult Colony ####
    # (Weekly, L/week or kg/week)
    Water_for_adult_colony_weekly = Water_for_adult_colony_daily*7
    Water_for_release_males_weekly = Water_for_release_males_daily*7
    Total_water_for_adult_diet_weekly = Total_water_for_adult_diet_daily*7 
    Sugar_for_adult_colony_weekly = Sugar_for_adult_colony_daily*7
    Sugar_for_release_males_weekly = Sugar_for_release_males_daily*7
    Total_sugar_for_adult_diet_weekly = Total_sugar_for_adult_diet_daily*7
    Blood_for_adult_diet_weekly = Blood_for_adult_diet_daily*7
    
    #### > 7. Storage of diet ingredients ####
    # (storage time in days, volume in m3, height in m, area in m2)
    Ingredients_volume = c(
      ceiling(
        daily_ingredients[1] *
          Beef_liver_powder_storage_time/
          Beef_liver_powder_kg_per_unit/
          Beef_liver_powder_storage_bags_per_m3),
      ceiling(
        daily_ingredients[2] *
          Tuna_meal_storage_time /
          Tuna_meal_kg_per_unit /
          Tuna_meal_storage_bags_per_m3),
      ceiling(
        daily_ingredients[3] *
          Brewer_yeast_storage_time /
          Brewer_yeast_kg_per_unit /
          Brewer_yeast_storage_bags_per_m3),
      ceiling(
        daily_ingredients[4] *
          BSF_yeast_storage_time/
          BSF_yeast_kg_per_unit/
          BSF_yeast_storage_bags_per_m3),
      ceiling(
        daily_ingredients[5] *
          Component_5_storage_time /
          Component_5_kg_per_unit /
          Component_5_storage_bags_per_m3), 
      ceiling(
        daily_ingredients[6] *
          Component_6_storage_time /
          Component_6_kg_per_unit /
          Component_6_storage_bags_per_m3)
    )
    
    Ingredients_height = c(Beef_liver_powder_height, 
                           Tuna_meal_height, 
                           Brewer_yeast_height, 
                           BSF_yeast_height, 
                           Component_5_height, 
                           Component_6_height)
    
    Ingredients_area = Ingredients_volume / Ingredients_height
    
    Total_sugar_for_adult_diet_volume = 
      ceiling(
        Total_sugar_for_adult_diet_daily*
          Total_sugar_for_adult_diet_storage_time/
          Total_sugar_for_adult_diet_kg_per_unit/
          Total_sugar_for_adult_diet_storage_bags_per_m3)
    
    Total_sugar_for_adult_diet_area = 
      Total_sugar_for_adult_diet_volume/
      Total_sugar_for_adult_diet_height
    
    Blood_for_storage = Blood_for_adult_diet_daily
    Water_for_storage = Water_larval_diet_daily + 
      Total_water_for_adult_diet_daily
    
    size_of_store_for_diet_ingredients = 
      sum(Ingredients_area, Total_sugar_for_adult_diet_area)
    
    #### > 8. rearing equipment ####
    #### >> 8.1. Larval trays ####
    Total_larval_trays = 
      Total_number_of_larval_trays_permanently_in_use_for_MO +
      Total_number_of_trays_permanently_in_use_in_the_larval_room +
      Total_number_of_trays_permanently_in_use_in_the_larval_room_in_both_filters
    
    Total_number_of_larval_trays_required = 
      ceiling(
        Total_larval_trays * 
          Oversize_factor_larval_trays)
    
    #### >> 8.2 Racks for larval trays####
    Total_racks = 
      Total_number_of_larval_racks_permanently_in_use_for_MO +
      Total_number_of_racks_permanently_in_use_in_the_larval_room +
      Total_number_of_racks_permanently_in_use_in_the_larval_room_in_both_filters
    
    Total_number_of_racks_required = 
      ceiling(
        Total_racks * 
          Oversize_factor_racks)
    
    #### >> 8.3. Cages for colonies####
    Total_colony_cages = 
      Total_number_of_cages_permanently_in_use_for_egg_production__Preoviposition_Oviposition +
      Total_number_of_cages_permanently_in_use_for_egg_production_in_both_filters
    
    Total_number_of_cages_required = 
      ceiling( 
        Total_colony_cages * 
          Oversize_factor_cages)
    
    #### >> 8.4 Cages for Release Males ####
    Total_RM_cages = 
      Total_number_of_cages_permanently_in_use_in_the_emergence_center
    Total_number_of_RM_cages_required =
      ceiling( Total_RM_cages * Oversize_factor_RM_cages)
    
    #### >> 8.5. Irradiator ####
    Number_of_insects_to_be_irradiated_per_day = 
      Weekly_pupal_production / 7
    
    Irradiator_workload = 
      Duration_of_one_irradiation_operation * 
      Number_of_irradiation_operations_per_day
    
    Irradiator_number_of_units = 
      ceiling(
        Irradiator_backup + 
          Irradiator_workload /
          Irradiator_max_time)
    
    # corrected workload per unit
    Irradiator_workload_per_unit = 
      Irradiator_workload / 
      (Irradiator_number_of_units - Irradiator_backup)
    
    #### >> 8.6. L1 sex sorter (COPAS) for GSS and GSS-CS ####
    L1_to_be_sexed_per_day = 
      Number_of_L1_both_sex_to_be_sex_sorted_per_day_for_female_replacement /
      1000000 +
      both_sex_L1_to_be_sorted_per_day_for_male_only +
      Number_of_L1_both_sex_to_be_sex_sorted_per_day_for_both_filters 
    
    L1_sex_sorter_workload = 
      L1_to_be_sexed_per_day /
      L1_sex_sorter_throwput
    
    L1_sex_sorter_number_of_units = 
      if(L1_to_be_sexed_per_day == 0){
        0 
      }else{
        ceiling(
          L1_sex_sorter_backup + L1_sex_sorter_workload/
            L1_sex_sorter_max_time)
      }
    
    L1_sex_sorter_workload_per_unit = 
      if(L1_to_be_sexed_per_day == 0){ 
        0 
      }else{ 
        L1_sex_sorter_workload/
          (L1_sex_sorter_number_of_units - L1_sex_sorter_backup) 
      }
    
    #### >> 8.7. Pupal sex sorter (for all) ####
    # In GSS and GSS-CS the male pupae are double checked so number of 
    # pupae to be sorted = this number. 
    # In classical, take calculation from classical spreadsheet
    Number_of_pupae_to_be_sexed_per_day = 
      if(method %in% c('GSS', 'GSS-CS')){
        Number_of_L1_both_sex_to_be_sex_sorted_per_day_for_both_filters *
          L1_sex_sorter_female_recovery *
          Survival_eggs_to_pupae
      }else{
        Larval_trays_to_be_loaded_with_L1_per_day_for_MO * 
          Egg_hatching_rate * 
          Survival_eggs_to_pupae * L1_per_colony_tray /
          1000000
      }
    
    Pupal_sorter_workload = 
      Number_of_pupae_to_be_sexed_per_day / 
      Pupal_sorter_throwput
    
    Pupal_sorter_number_of_units = 
      ceiling(
        Pupal_sorter_backup + Pupal_sorter_workload /
          Pupal_sorter_max_time)
    
    Pupal_sorter_workload_per_units = 
      Pupal_sorter_workload /
      (Pupal_sorter_number_of_units - Pupal_sorter_backup)
    
    #### >> 8.8. L1 counter for classical only ####
    # (otherwise done by the L1 sorter)
    Number_of_trays_to_be_seeded_per_day =
      if(method %in% c('GSS', 'GSS-CS')){
        0
      }else{
        Larval_trays_to_be_loaded_with_L1_per_day_for_MO
      }
    
    L1_counter_workload = 
      Number_of_trays_to_be_seeded_per_day / 
      L1_counter_capacity
    
    L1_counter_number_of_units = 
      if(Number_of_trays_to_be_seeded_per_day==0){ 
        0 
      }else{ 
        ceiling(L1_counter_backup + L1_counter_workload/L1_counter_max_time)
      }
    
    L1_counter_workload_per_units =  
      if (Number_of_trays_to_be_seeded_per_day==0){
        0
      }else{
        L1_counter_workload/(L1_counter_number_of_units - L1_counter_backup)
      } 
    
    #### >> 8.9. Larval diet mixer ####
    Larval_diet_mixer_daily_batches = 
      ceiling(Larval_diet_solution_daily/
                Larval_diet_mixer_capacity)
    
    Larval_diet_mixer_workload = 
      Larval_diet_mixer_daily_batches * 
      Larval_diet_mixer_duration_per_batch
    
    Larval_diet_mixer_number_of_units = 
      ceiling(Larval_diet_mixer_backup + 
                Larval_diet_mixer_workload / 
                Larval_diet_mixer_max_time)
    
    Larval_diet_mixer_workload_per_unit = 
      Larval_diet_mixer_workload / 
      (Larval_diet_mixer_number_of_units - Larval_diet_mixer_backup)
    
    #### >> 8.10. Adult diet mixer ####
    Adult_diet_mixer_daily_batches = 
      ceiling(
        Total_water_for_adult_diet_daily /
          Adult_diet_mixer_capacity)
    
    Adult_diet_mixer_workload = 
      Adult_diet_mixer_daily_batches * 
      Adult_diet_mixer_duration_per_batch
    
    Adult_diet_mixer_number_of_units = 
      ceiling(Adult_diet_mixer_backup + 
                Adult_diet_mixer_workload / Adult_diet_mixer_max_time)
    
    Adult_diet_mixer_workload_per_unit = 
      Adult_diet_mixer_workload / 
      (Adult_diet_mixer_number_of_units - Adult_diet_mixer_backup)
    
    #### >> 8.11 Larval diet feeder ####
    Total_number_of_larval_trays_to_be_fed_everyday = 
      Total_number_of_larval_trays_to_be_fed_everyday_for_MO +
      Number_of_larval_trays_to_be_fed_everyday +
      Number_of_larval_trays_to_be_fed_everyday_in_both_filters
    
    Larval_feeder_workload = 
      Total_number_of_larval_trays_to_be_fed_everyday/Larval_feeder_capacity
    
    Larval_feeder_number_of_units = 
      ceiling(Larval_feeder_backup + Larval_feeder_workload/Larval_feeder_max_time)
    
    Larval_feeder_workload_per_unit = 
      Larval_feeder_workload/(Larval_feeder_number_of_units - Larval_feeder_backup)
    
    #### >> 8.12. Blood feeders ####
    Total_number_of_cages_to_be_blood_fed_per_day = (
      (Oviposition_cages_permanently_in_use_for_egg_production + 
         Oviposition_cages_permanently_in_use_for_egg_production_in_both_filters) +
        (Pre_oviposition_cages_permanently_in_use_for_egg_production +
           Preoviposition_cages_permanently_in_use_for_egg_production_in_both_filters) *
        (Pre_oviposition_period-3)/Pre_oviposition_period)/frequency_of_blood_feeding
    
    Blood_feeder_workload = 
      Total_number_of_cages_to_be_blood_fed_per_day/
      Blood_feeder_capacity
    
    Blood_feeder_number_of_units = 
      ceiling(Blood_feeder_backup + 
                Blood_feeder_workload/Blood_feeder_max_time)
    
    Blood_feeder_workload_per_unit =  
      Blood_feeder_workload / 
      (Blood_feeder_number_of_units - Blood_feeder_backup)
    
    #### >> 8.13. Tray washing machine ####
    Trays_to_be_washed_per_day = 
      Larval_trays_to_be_loaded_with_L1_per_day_for_MO + 
      Number_of_larval_trays_to_be_loaded_after_the_1st_sorting_for_MO + 
      Number_of_larval_trays_to_be_loaded_after_the_2nd_sorting_for_MO + 
      Number_of_larval_trays_to_be_loaded_per_day_for_female_replacement +
      Number_of_larval_trays_to_be_reloaded_after_the_first_sorting_for_female_replacement +
      Number_of_larval_trays_to_be_reloaded_after_the_second_sorting_for_female_replacement +
      Number_of_larval_trays_to_be_loaded_with_L1_per_day_in_both_filters +
      Number_of_larval_trays_to_be_loaded_after_the_first_sorting_per_day_in_both_filters +
      Number_of_larval_trays_to_be_loaded_after_the_second_sorting_per_day_in_both_filters
    
    Tray_washer_workload = 
      Trays_to_be_washed_per_day/
      Tray_washer_capacity
    
    Tray_washer_number_of_units = 
      ceiling(Tray_washer_backup +
                Tray_washer_workload/Tray_washer_max_time)
    
    Tray_washer_workload_per_unit = 
      Tray_washer_workload /
      (Tray_washer_number_of_units - Tray_washer_backup)
    
    #### >> 8.14. Cage washing machine in rearing facility ####
    Cages_to_be_washed_per_day = 
      (Cage_units_to_be_loaded_per_day_to_produce_the_eggs_for_stockpiling +
         Number_of_colony_cages_to_be_loaded_per_day_in_both_filters)/
      Frequency_of_Colony_cage_washing 
    
    Cage_washer_workload = 
      Cages_to_be_washed_per_day/
      Cage_washer_capacity
    
    Cage_washer_number_of_units = 
      ceiling(Cage_washer_backup + 
                Cage_washer_workload/Cage_washer_max_time)
    
    Cage_washer_workload_per_unit = 
      Cage_washer_workload / 
      (Cage_washer_number_of_units - Cage_washer_backup)
    
    #### >> 8.15. Cage washing machine in release facility ####
    MO_cages_to_be_washed_per_day = 
      MO_cages_loaded_per_day/
      Frequency_of_MO_cage_washing
    
    MO_cage_washer_workload = 
      MO_cages_to_be_washed_per_day/
      MO_cage_washer_capacity
    
    MO_cage_washer_number_of_units = 
      ceiling(MO_cage_washer_backup + 
                MO_cage_washer_workload/MO_cage_washer_max_time)
    
    MO_cage_washer_workload_per_unit = 
      MO_cage_washer_workload /
      (MO_cage_washer_number_of_units - MO_cage_washer_backup)
    
    #### > 9. Environmental conditions ####
    # No calculation 
    
    #### > 10. Water requirements ####
    #### >> 10.1. Water for rearing####
    Water_for_larval_trays_initial_loading_daily = 
      (Larval_trays_to_be_loaded_with_L1_per_day_for_MO + 
         Number_of_larval_trays_to_be_loaded_per_day_for_female_replacement +
         Number_of_larval_trays_to_be_loaded_with_L1_per_day_in_both_filters) * 
      volume_of_colony_larval_trays / 1000
    
    Water_for_larval_trays_initial_loading_weekly = 
      Water_for_larval_trays_initial_loading_daily * 7
    
    #### >> 10.2. Water for equipment washing ####
    Water_for_tray_washing_daily =
    Trays_to_be_washed_per_day *
      Water_per_tray_wash
    
    Water_for_tray_washing_weekly = 
      Water_for_tray_washing_daily * 7
    
    Water_for_colony_cage_washing_daily = 
      Cages_to_be_washed_per_day * 
      Water_per_cage_wash
    
    Water_for_colony_cage_washing_weekly = 
      Water_for_colony_cage_washing_daily * 7
    
    Water_for_MO_cage_washing_daily = 
      MO_cages_to_be_washed_per_day * 
      Water_per_MO_cage_wash
    
    Water_for_MO_cage_washing_weekly = 
      Water_for_MO_cage_washing_daily * 7
    
    #### >> 10.3. Water for room cleaning ####
    Water_for_room_cleaning_daily = 
      (Water_for_larval_trays_initial_loading_daily +
         Larval_diet_solution_daily +
         Water_for_adult_colony_daily +
         Water_for_release_males_daily +
         Water_for_tray_washing_daily +
         Water_for_colony_cage_washing_daily +
         Water_for_MO_cage_washing_daily) * 
      Percentage_of_water_for_room_cleaning
    
    Water_for_room_cleaning_weekly = 
      Water_for_adult_colony_daily * 7
    
    #### >> 10.4. Total water requirements ####
    Total_water_required_daily = 
      Water_for_larval_trays_initial_loading_daily +
      Larval_diet_solution_daily +
      Water_for_adult_colony_daily +
      Water_for_release_males_daily +
      Water_for_tray_washing_daily +
      Water_for_colony_cage_washing_daily +
      Water_for_MO_cage_washing_daily +
      Water_for_room_cleaning_daily
    
    Total_water_required_weekly = 
      Total_water_required_daily * 7 
    
    #### > 11. Floor area calculation ####
    #### >> 11.1. Mass rearing facility ####
    #### >>> 11.1.1 Laval area ####
    Rack_unit_footprint = 
      (Larval_tray_length + 20) *
      (Larval_tray_width + 20) / 10000
    
    Larval_development_room_area = 
      Total_number_of_racks_required * 
      Rack_unit_footprint * 
      Rack_oversize_factor
    #add for filter colonies
    
    Tray_loading_room_area =
      (Larval_racks_to_be_loaded_with_L1_per_day_for_MO + 
         ceiling(Number_of_larval_trays_to_be_loaded_per_day_for_female_replacement/
                   Number_of_larval_trays_per_rack__Colony) +
         Number_of_larval_racks_to_be_loaded_with_L1_per_day_in_both_filters) *
      Rack_unit_footprint * Rack_oversize_factor
    
    Larval_pupal_sorting_room_area = 
      0.1 * Larval_development_room_area
    Sex_sorting_room_area = 
      0.1 * Larval_development_room_area
    
    #### >>> 11.1.2 Adult area ####
    Colony_cage_unit_footprint = 
      (Net_colony_cages_width+20)*
      (Net_colony_cages_length+20)/10000/2
    
    Adult_room_area = 
      Total_number_of_cages_required * 
      Colony_cage_unit_footprint * 
      Colony_cage_oversize_factor
    
    Cage_loading_room_area = 
      (Cage_units_to_be_loaded_per_day_to_produce_the_eggs_for_stockpiling + 
         Number_of_colony_cages_to_be_loaded_per_day_in_both_filters) * 
      Colony_cage_unit_footprint *
      Colony_cage_oversize_factor
    
    #### >>> 11.1.3. Common area ####
    Irradiation_room_area =
      max(15,10*Irradiator_number_of_units)
    
    Storage_area =
      size_of_store_for_diet_ingredients*Storage_oversize_factor
    
    Offices_area = 
      Office_staff*Offices_size_per_staff
    
    WC_area = 
      WC_staff*WC_size_per_staff
    
    Corridor_area = 
      Percentage_corridors*(
        Larval_development_room_area +
          Tray_loading_room_area +
          Larval_pupal_sorting_room_area +
          Sex_sorting_room_area +
          Adult_room_area +
          Cage_loading_room_area +
          Diet_preparation_area +
          Tray_washing_area +
          Cage_washing_area +
          QC_lab_area +
          Irradiation_room_area +
          Workshop_area +
          Warehouse_area +
          Storage_area +
          Offices_area +
          WC_area)
    
    #### >>> 11.1.4. Total ####
    Mass_rearing_facility_area = 
      Larval_development_room_area +
      Tray_loading_room_area +
      Larval_pupal_sorting_room_area +
      Sex_sorting_room_area +
      Adult_room_area +
      Cage_loading_room_area +
      Diet_preparation_area +
      Tray_washing_area +
      Cage_washing_area +
      QC_lab_area +
      Irradiation_room_area +
      Workshop_area +
      Warehouse_area +
      Storage_area +
      Offices_area +
      WC_area +
      Corridor_area
    
    #### >> 11.2. Release facility ####
    MO_cage_footprint = 
      MO_cage_compartment * 
      MO_cage_width * 
      MO_cage_length *
      1.5/10000/2
    
    MO_room_area = 
      Total_number_of_RM_cages_required  *
      MO_cage_footprint * 
      MO_cage_oversize_factor
    
    Chilling_room_area = 
      MO_cages_loaded_per_day * 
      MO_cage_footprint * 
      MO_cage_oversize_factor
    
    MO_Offices_area = 
      max(15,MO_office_staff*Offices_size_per_staff)
    
    MO_WC_area =
      MO_wc_staff * WC_size_per_staff
    
    MO_Corridor_area = 
      Percentage_corridors *(
        MO_room_area +
          Chilling_room_area +
          MO_cages_loading_area +
          MO_QC_lab_area +
          MO_adult_packaging_area +
          MO_diet_preparation_area +
          MO_Warehouse_area +
          MO_Offices_area +
          MO_WC_area)
    
    #### >>> 11.2.1 Total ####
    Release_facility_area = 
      MO_room_area +
      Chilling_room_area +
      MO_cages_loading_area +
      MO_QC_lab_area +
      MO_adult_packaging_area +
      MO_diet_preparation_area +
      MO_Warehouse_area +
      MO_Offices_area +
      MO_WC_area +
      MO_Corridor_area
    
    #### >> 12. Construction cost ####
    #### >> 12.1. Mass rearing facility ####
    Area_office_labs_wc_irradiation_corridor = 
      Offices_area + 
      Irradiation_room_area + 
      Diet_preparation_area + 
      QC_lab_area + 
      WC_area + 
      Corridor_area
    
    Cost_office_labs_wc_irradiation_corridor = 
      Area_office_labs_wc_irradiation_corridor * 
      Cost_m2_office_labs_wc_irradiation_corridor
    
    Area_rearing_rooms =
      Larval_development_room_area +
      Tray_loading_room_area +
      Larval_pupal_sorting_room_area +
      Sex_sorting_room_area +
      Adult_room_area +
      Cage_loading_room_area +
      Tray_washing_area +
      Cage_washing_area
    
    Cost_rearing_rooms = 
      Area_rearing_rooms * 
      Cost_m2_rearing_rooms
    
    Area_storage_warehouse = 
      Storage_area + 
      Warehouse_area
    
    Cost_storage_warehouse = 
      Area_storage_warehouse * 
      Cost_m2_storage_warehouse
    
    Construction_cost_mass_rearing_facility = 
      Cost_office_labs_wc_irradiation_corridor +
      Cost_rearing_rooms +
      Cost_storage_warehouse
    
    Yearly_depreciation_mass_rearing_facility = 
      Construction_cost_mass_rearing_facility / 
      Expected_lifespan_mass_rearing_facility
    
    #### >> 12.2. Release facility####
    Area_office_labs_wc_irradiation_corridor_MO = 
      MO_Offices_area + 
      MO_QC_lab_area + 
      MO_WC_area +  
      MO_Corridor_area + 
      MO_diet_preparation_area
    
    Cost__office_labs_wc_irradiation_corridor_MO = 
      Cost_m2_office_labs_wc_irradiation_corridor * 
      Area_office_labs_wc_irradiation_corridor_MO
    
    Cost_chilling_room_MO = 
      Chilling_room_area * Cost_m2_chilling_room
    
    Area_rearing_rooms_MO = 
      MO_room_area + MO_cages_loading_area + MO_adult_packaging_area
    
    Cost_rearing_rooms_MO = 
      Area_rearing_rooms_MO * Cost_m2_rearing_rooms
    
    Cost_storage_warehouse_MO = 
      MO_Warehouse_area * Cost_m2_storage_warehouse
    
    Construction_cost_release_facility = 
      Cost__office_labs_wc_irradiation_corridor_MO +
      Cost_chilling_room_MO +
      Cost_rearing_rooms_MO +
      Cost_storage_warehouse_MO
    
    Yearly_depreciation_release_facility = 
      Construction_cost_release_facility / Expected_lifespan_release_facility
    
    # Disclaimer: 
    # The construction costs will largely vary across countries. 
    # The unit costs of the rearing rooms must include the cost of climatisation. 
    # The construction costs does not include the purchase of the terrain for building. 
    
    #### > 13. Workload ####
    #### >> 13.1. Mass rearing facility ####
    Egg_hatching_amount = 
      eggs_to_be_hatched_per_day_for_male_only_production/Egg_density*1000000 + 
      number.of.rearing.colony * Number_of_eggs_for_female_replacement_needed_from_each_filter_colony_everyday/Egg_density +
      number.of.rearing.colony * Eggs_to_be_hatched_per_day_to_replace_the_females_in_each_filter/Egg_density
    Egg_hatching_workload = 1 * Egg_hatching_work_rate

    Tray_hanging_amount = 
      Larval_racks_to_be_loaded_with_L1_per_day_for_MO + Number_of_larval_racks_to_be_loaded_after_the_1st_sorting_for_MO + Number_of_larval_racks_to_be_loaded_after_the_2nd_sorting_for_MO + 
      ceiling(Number_of_larval_trays_to_be_loaded_per_day_for_female_replacement/Number_of_larval_trays_per_rack__Colony) +
      ceiling(Number_of_larval_trays_to_be_reloaded_after_the_first_sorting_for_female_replacement/Number_of_larval_trays_per_rack__Colony) +
      ceiling(Number_of_larval_trays_to_be_reloaded_after_the_second_sorting_for_female_replacement/Number_of_larval_trays_per_rack__Colony) +
      Number_of_larval_racks_to_be_loaded_with_L1_per_day_in_both_filters +
    Number_of_larval_racks_to_be_loaded_after_the_first_sorting_per_day_in_both_filters +
      Number_of_larval_racks_to_be_loaded_after_the_second_sorting_per_day_in_both_filters
    
    Tray_hanging_workload = 
      Tray_hanging_amount * Tray_hanging_work_rate
    
    L1_dosage_amount = 
      Larval_racks_to_be_loaded_with_L1_per_day_for_MO +
      ceiling(Number_of_larval_trays_to_be_loaded_per_day_for_female_replacement/Number_of_larval_trays_per_rack__Colony) +
      Number_of_larval_racks_to_be_loaded_with_L1_per_day_in_both_filters 
    
    L1_dosage_workload = 
      L1_dosage_amount * 
      L1_dosage_work_rate
    
    L4_loading_amount = 
      Number_of_larval_racks_to_be_loaded_after_the_1st_sorting_for_MO + Number_of_larval_racks_to_be_loaded_after_the_2nd_sorting_for_MO +
      ceiling(Number_of_larval_trays_to_be_reloaded_after_the_first_sorting_for_female_replacement/Number_of_larval_trays_per_rack__Colony) +
      ceiling(Number_of_larval_trays_to_be_reloaded_after_the_second_sorting_for_female_replacement/Number_of_larval_trays_per_rack__Colony) +
      Number_of_larval_racks_to_be_loaded_after_the_first_sorting_per_day_in_both_filters + 
    Number_of_larval_racks_to_be_loaded_after_the_second_sorting_per_day_in_both_filters
    
    L4_loading_workload = 
      L4_loading_amount * L4_loading_work_rate
    
    Larval_feeding_amount = 
      Total_number_of_larval_racks_permanently_in_use_for_MO +
    Total_number_of_racks_permanently_in_use_in_the_larval_room +
      Total_number_of_racks_permanently_in_use_in_the_larval_room_in_both_filters 
    
    Larval_feeding_workload = 
      Larval_feeding_amount * Larval_feeding_work_rate
    
    Tray_tilting_amount = Tray_hanging_amount
    Tray_tilting_workload = Tray_tilting_amount * Tray_tilting_work_rate
    
    L1_sex_sorting_work_rate = 1/L1_sex_sorter_throwput
    L1_sex_sorting_workload = L1_to_be_sexed_per_day * L1_sex_sorting_work_rate
    
    Pupal_sex_sorting_work_rate = 1/Pupal_sorter_throwput
    Pupal_sex_sorting_workload =  Number_of_pupae_to_be_sexed_per_day * Pupal_sex_sorting_work_rate
    
    Tray_washing_workload = Trays_to_be_washed_per_day / Tray_washer_capacity
    
    Irradiation_workload = Number_of_irradiation_operations_per_day * 
      Duration_of_one_irradiation_operation
    
    Insect_packing_for_irradiation_workload = 
      Insect_packing_for_irradiation_work_rate * 
      Number_of_irradiation_operations_per_day
    
    Colony_cage_loading_amount = 
      Cage_units_to_be_loaded_per_day_to_produce_the_eggs_for_stockpiling + 
      Number_of_colony_cages_to_be_loaded_per_day_in_both_filters
    
    Colony_cage_loading_workload = 
      Colony_cage_loading_amount * 
      Colony_cage_loading_work_rate
    
    Colony_cage_bloodfeeding_amount = 
      Number_of_colony_cages_to_be_blood_fed_per_day_in_the_rearing_colony + # CHECK WHY FROM PROCESS 
    Number_of_colony_cages_to_be_bloodfed_per_day_in_both_filters
    
    Colony_cage_bloodfeeding_workload = 
      Colony_cage_bloodfeeding_amount * 
      Colony_cage_bloodfeeding_work_rate
    
    Egg_collection_amount = 
      Number_of_colony_cages_to_be_collected_for_eggs_per_day_in_the_rearing_colony +
    Number_of_colony_cages_to_be_collected_for_eggs_per_day_in_both_filters
    
    Egg_collection_workload = 
      Egg_collection_amount * Egg_collection_work_rate
    
    Egg_storage_amount = Egg_collection_amount
    
    Egg_storage_workload = 
      Egg_storage_amount * 
      Egg_storage_work_rate
    
    Colony_cage_washing_amount = Colony_cage_loading_amount
    
    Colony_cage_washing_workload = 
      Colony_cage_washing_amount / Cage_washer_capacity
    
    Larval_diet_prep_batches = 
      ceiling(Larval_diet_solution_daily / 
                Larval_diet_mixer_capacity)
    
    Larval_diet_prep_workload = 
      Larval_diet_prep_batches * Larval_diet_prep_work_rate
    
    Adult_diet_prep_batches = 
      ceiling(Water_for_adult_colony_daily / 
                Adult_diet_mixer_capacity)
    
    Adult_diet_prep_workload = 
      Adult_diet_prep_batches * 
      Adult_diet_prep_work_rate
    
    Blood_collection_workload = 
      Blood_collection_weekly * 
      Blood_collection_work_rate /7

    Blood_doses_prep_amount = 
      ceiling(Blood_for_adult_diet_daily / 
                Volume_of_blood_per_casing * 1000)
    
    Blood_doses_prep_workload = 
      Blood_doses_prep_amount * Blood_doses_prep_work_rate
    
    Workload_mass_rearing_facility = 
      Egg_hatching_workload +
      Tray_hanging_workload +
      L1_dosage_workload +
      L4_loading_workload +
      Larval_feeding_workload +
      Tray_tilting_workload +
      L1_sex_sorting_workload +
      Pupal_sorter_workload + 
      Tray_washing_workload + 
      Irradiation_workload +
      Insect_packing_for_irradiation_workload +
      Colony_cage_loading_workload +
      Colony_cage_bloodfeeding_workload +
      Egg_collection_workload +
      Egg_storage_workload +
      Colony_cage_washing_workload +
      Larval_diet_prep_workload +
      Adult_diet_prep_workload +
      Blood_collection_workload +
      Blood_doses_prep_workload
    
    Staff_needed_every_day_mass_rearing = 
      ceiling(Workload_mass_rearing_facility / 
                Net_working_time_per_staff_per_day)
    
    Team_leaders_needed_mass_rearing = 
      ceiling(Staff_needed_every_day_mass_rearing / 10)
    
    #### >> 13.2. Release facility ####
    MO_cage_loading_workload = 
      MO_cage_loading_work_rate * 
      MO_cages_loaded_per_day
    
    MO_adult_diet_prep_batches = 
      ceiling(
        Water_for_release_males_daily/
          Adult_diet_mixer_capacity)
    
    MO_adult_diet_prep_work_rate = 
      Adult_diet_prep_work_rate
    
    MO_adult_diet_prep_workload = 
      MO_adult_diet_prep_batches * 
      MO_adult_diet_prep_work_rate
    
    MO_cage_chilling_workload = 
      MO_cages_loaded_per_day * 
      MO_cage_chilling_work_rate
    
    MO_adult_collection_workload = 
      MO_cages_loaded_per_day * 
      MO_adult_collection_work_rate
    
    MO_adult_packing_for_release_workload = 
      MO_cages_loaded_per_day * 
      MO_adult_packing_for_release_work_rate
    
    MO_cage_washing_amount = 
      ceiling(MO_cages_loaded_per_day / 
                Frequency_of_MO_cage_washing)

    MO_cage_washing_work_rate = 1/MO_cage_washer_capacity
    MO_cage_washing_workload = MO_cage_washing_amount * MO_cage_washing_work_rate
    
    Workload_release_facility =
      MO_cage_loading_workload +
      MO_adult_diet_prep_workload +
      MO_cage_chilling_workload +
      MO_adult_collection_workload +
      MO_adult_packing_for_release_workload +
      MO_cage_washing_workload
    
    Staff_needed_every_day_release_facility = 
      ceiling(Workload_release_facility / 
                Net_working_time_per_staff_per_day)
    
    Team_leaders_needed_release_facility = 
      ceiling(Staff_needed_every_day_release_facility / 10)
    
    #### >> 13.3. Total number of staff for 7/365 ####
    #### >>> 13.3.1. Mass rearing facility ####
    Total_rearing_labourers_mass_rearing = 
      ceiling(Staff_needed_every_day_mass_rearing * 
                Majoring_factor_labourer)
    
    Total_team_leaders_mass_rearing = 
      ceiling(Team_leaders_needed_mass_rearing * 
                Majoring_factor_team_leader)
    
    Total_QC_managers_mass_rearing = 
      ceiling(QC_managers_needed_mass_rearing * 
                Majoring_factor_QC_manager)
    
    QC_technicians_needed_mass_rearing = 
      if(
        ceiling((Total_rearing_labourers_mass_rearing + 
                 Total_team_leaders_mass_rearing)/10)-
        Total_QC_managers_mass_rearing <0
      ){
        0
      }else{
        ceiling(
          (Total_rearing_labourers_mass_rearing + 
             Total_team_leaders_mass_rearing) / 10) - 
          Total_QC_managers_mass_rearing}
    
    Total_QC_technicians_needed_mass_rearing = 
      QC_technicians_needed_mass_rearing * 
      Majoring_factor_QC_technician
    
    Maintenance_manager_needed_mass_rearing = 
      if(Total_rearing_labourers_mass_rearing + 
         Total_team_leaders_mass_rearing > 15){1}else{0}
    
    Total_Maintenance_manager_needed_mass_rearing = 
      Maintenance_manager_needed_mass_rearing * 
      Majoring_factor_maintenance_manager
    
    Maintenance_officer_needed_mass_rearing = 
      round(
        (Total_rearing_labourers_mass_rearing + 
           Total_team_leaders_mass_rearing)/20 -
          Maintenance_manager_needed_mass_rearing)
    
    Total_Maintenance_officer_needed_mass_rearing = 
      Maintenance_officer_needed_mass_rearing * 
      Majoring_factor_maintenance_officer
    
    Total_manager_needed_mass_rearing = 
      Manager_needed_mass_rearing * 
      Majoring_factor_manager
    
    Admin_assistant_needed_mass_rearing = 
      floor((Total_rearing_labourers_mass_rearing + 
               Total_team_leaders_mass_rearing + 
               Total_QC_managers_mass_rearing + 
               Total_QC_technicians_needed_mass_rearing + 
               Total_manager_needed_mass_rearing)/20)
    
    Total_Admin_assistant_needed_mass_rearing = 
      Admin_assistant_needed_mass_rearing * 
      Majoring_factor_admin_assistant
    
    #### >>> 13.3.2. Release facility ####
    Total_rearing_labourers_release_facility = 
      ceiling(Staff_needed_every_day_release_facility * 
                Majoring_factor_labourer)
    
    Total_team_leaders_release_facility = 
      ceiling(Team_leaders_needed_release_facility * 
                Majoring_factor_team_leader)
    
    QC_managers_needed_release_facility = 
      if (Total_rearing_labourers_release_facility + 
          Total_team_leaders_release_facility >15){
        1
      }else{
        0
      }
    
    Total_QC_managers_release_facility = 
      ceiling(QC_managers_needed_release_facility * 
                Majoring_factor_QC_manager)
    
    QC_technicians_needed_release_facility =
      round(((Total_rearing_labourers_release_facility + 
                Total_team_leaders_release_facility)/15) - 
              Total_QC_managers_release_facility, digits = 0)
    Total_QC_technicians_needed_release_facility = 
      QC_technicians_needed_release_facility * 
      Majoring_factor_QC_technician
    
    Maintenance_manager_needed_release_facility = 
      if(Total_rearing_labourers_release_facility + 
         Total_team_leaders_release_facility > 15){
        1
      }else{
        0}
    
    Total_Maintenance_manager_needed_release_facility = 
      Maintenance_manager_needed_release_facility * 
      Majoring_factor_maintenance_manager
    
    Maintenance_officer_needed_release_facility = 
      round((
        Total_rearing_labourers_release_facility + 
          Total_team_leaders_release_facility)/20) - 
      Maintenance_manager_needed_release_facility
    
    Total_Maintenance_officer_needed_release_facility = 
      Maintenance_officer_needed_release_facility * 
      Majoring_factor_maintenance_officer
    
    Manager_needed_release_facility = 
      if(Total_rearing_labourers_release_facility + 
         Total_team_leaders_release_facility + 
         QC_managers_needed_release_facility > 15){
        1
      }else{
        0
      }
    
    Total_manager_needed_release_facility =
      Manager_needed_release_facility * 
      Majoring_factor_manager
    
    Admin_assistant_needed_release_facility = 
      floor((Total_rearing_labourers_release_facility + 
               Total_team_leaders_release_facility + 
               Total_QC_managers_release_facility + 
               Total_QC_technicians_needed_release_facility + 
               Total_manager_needed_release_facility)/25)
    
    Total_Admin_assistant_needed_release_facility = 
      Admin_assistant_needed_release_facility * 
      Majoring_factor_admin_assistant
    
    #### >>> 13.3.3 Total ####
    Total_rearing_labourers_both_facilities = 
      Total_rearing_labourers_mass_rearing + 
      Total_rearing_labourers_release_facility
    
    Total_team_leaders_both_facilities = 
      Total_team_leaders_mass_rearing + 
      Total_team_leaders_release_facility
    
    Total_QC_managers_both_facilities = 
      Total_QC_managers_mass_rearing + 
      Total_QC_managers_release_facility
    
    Total_QC_technicians_both_facilities = 
      Total_QC_technicians_needed_mass_rearing + 
      Total_QC_technicians_needed_release_facility
    
    Total_Maintenance_manager_both_facilities = 
      Total_Maintenance_manager_needed_mass_rearing + 
      Total_Maintenance_manager_needed_release_facility
    
    Total_Maintenance_officer_both_facilities = 
      Total_Maintenance_officer_needed_mass_rearing + 
      Total_Maintenance_officer_needed_release_facility
    
    Total_manager_both_facilities = 
      Total_manager_needed_mass_rearing + 
      Total_manager_needed_release_facility
    
    Total_Admin_assistant_both_facilities = 
      Total_Admin_assistant_needed_mass_rearing + 
      Total_Admin_assistant_needed_release_facility
    
    Total_staff_both_facilities = 
      Total_rearing_labourers_both_facilities +
      Total_team_leaders_both_facilities +
      Total_QC_managers_both_facilities +
      Total_QC_technicians_both_facilities +
      Total_Maintenance_manager_both_facilities +
      Total_Maintenance_officer_both_facilities +
      Total_manager_both_facilities +
      Total_Admin_assistant_both_facilities
    
    #### > 14. Equipment budget####
    #### >> 14.1 Mass rearing facility#####
    Larval_trays_total_cost = 
      Total_number_of_larval_trays_required * 
      Larval_trays_unit_price
    
    Racks_for_larval_trays_total_cost = 
      Total_number_of_racks_required * 
      Racks_for_larval_trays_unit_price
    
    Cages_for_Colonies_total_cost = 
      Total_number_of_cages_required * 
      Cages_for_Colonies_unit_price
    
    Irradiator_total_cost = 
      Irradiator_number_of_units * 
      Irradiator_unit_price

    L1_Sex_sorter_total_cost = 
      L1_sex_sorter_number_of_units * 
      L1_Sex_sorter_unit_price
    
    Pupal_sex_sorter_total_cost = 
      Pupal_sorter_number_of_units * 
      Pupal_sex_sorter_unit_price 
    
    L1_counter_total_cost = 
      L1_counter_number_of_units * 
      L1_counter_unit_price
    
    Larval_diet_mixer_total_cost = 
      Larval_diet_mixer_number_of_units * 
      Larval_diet_mixer_unit_price
    
    Adult_diet_mixer_total_cost = 
      Adult_diet_mixer_number_of_units * 
      Adult_diet_mixer_unit_price
    
    Larval_diet_feeder_total_cost = 
      Larval_feeder_number_of_units * 
      Larval_diet_feeder_unit_price
    
    Blood_feeders_total_cost = 
      Blood_feeder_number_of_units * 
      Blood_feeders_unit_price
    
    Tray_washing_machine_in_mass_rearing_facility_total_cost = 
      Tray_washer_number_of_units * 
      Tray_washing_machine_in_mass_rearing_facility_unit_price
    
    Cage_washing_machine_in_mass_rearing_facility_total_cost = 
      Cage_washer_number_of_units * 
      Cage_washing_machine_in_mass_rearing_facility_unit_price
    
    Equipment_for_basic_QC_lab_total_cost = 
      Equipment_for_basic_QC_lab_number * 
      Equipment_for_basic_QC_lab_unit_price 
    
    Workshop_equipment_total_cost = 
      Workshop_equipment_number * 
      Workshop_equipment_unit_price
    
    Blood_storage_total_cost = 
      Blood_storage_number * 
      Blood_storage_unit_price
    
    Mass_rearing_facility_equipment_cost = 
      Larval_trays_total_cost +
      Racks_for_larval_trays_total_cost +
      Cages_for_Colonies_total_cost +
      Irradiator_total_cost +
      L1_Sex_sorter_total_cost +
      Pupal_sex_sorter_total_cost +
      L1_counter_total_cost +
      Larval_diet_mixer_total_cost +
      Adult_diet_mixer_total_cost +
      Larval_diet_feeder_total_cost +
      Blood_feeders_total_cost +
      Tray_washing_machine_in_mass_rearing_facility_total_cost +
      Cage_washing_machine_in_mass_rearing_facility_total_cost +
      Equipment_for_basic_QC_lab_total_cost +
      Workshop_equipment_total_cost +
      Blood_storage_total_cost
    
    Mass_rearing_facility_equipment_yearly_depreciation = 
      Larval_trays_total_cost / Larval_trays_life_expectancy +
      Racks_for_larval_trays_total_cost / Racks_for_larval_trays_life_expectancy +
      Cages_for_Colonies_total_cost / Cages_for_Colonies_life_expectancy +
      Irradiator_total_cost / Irradiator_life_expectancy +
      L1_Sex_sorter_total_cost / L1_Sex_sorter_life_expectancy +
      Pupal_sex_sorter_total_cost / Pupal_sex_sorter_life_expectancy +
      L1_counter_total_cost / L1_counter_life_expectancy +
      Larval_diet_mixer_total_cost / Larval_diet_mixer_life_expectancy +
      Adult_diet_mixer_total_cost / Adult_diet_mixer_life_expectancy +
      Larval_diet_feeder_total_cost / Larval_diet_feeder_life_expectancy +
      Blood_feeders_total_cost / Blood_feeders_life_expectancy +
      Tray_washing_machine_in_mass_rearing_facility_total_cost / 
      Tray_washing_machine_in_mass_rearing_facility_life_expectancy +
      Cage_washing_machine_in_mass_rearing_facility_total_cost / 
      Cage_washing_machine_in_mass_rearing_facility_life_expectancy +
      Equipment_for_basic_QC_lab_total_cost / 
      Equipment_for_basic_QC_lab_life_expectancy +
      Workshop_equipment_total_cost / Workshop_equipment_life_expectancy +
      Blood_storage_total_cost / Blood_storage_life_expectancy
    
    #### >> 14.2. Release facility####
    Cages_for_Release_Males_total_cost = 
      Total_number_of_RM_cages_required * 
      Cages_for_Release_Males_unit_price
    
    Cage_washing_machine_in_release_facility_number = 
      MO_cage_washer_number_of_units
    
    Cage_washing_machine_in_release_facility_total_cost = 
      Cage_washing_machine_in_release_facility_number *
      Cage_washing_machine_in_release_facility_unit_price
    
    Equipment_for_basic_QC_lab_MO_total_cost = 
      Equipment_for_basic_QC_lab_MO_number * 
      Equipment_for_basic_QC_lab_MO_unit_price
    
    Workshop_equipment_MO_total_cost = 
      Workshop_equipment_MO_number * 
      Workshop_equipment_MO_unit_price
    
    Release_facility_equipment_cost = 
      Cages_for_Release_Males_total_cost +
      Cage_washing_machine_in_release_facility_total_cost +
      Equipment_for_basic_QC_lab_MO_total_cost +
      Workshop_equipment_MO_total_cost
    
    Release_facility_equipment_yearly_depreciation = 
      Cages_for_Release_Males_total_cost / Cages_for_Release_Males_life_expectancy +
      Cage_washing_machine_in_release_facility_total_cost / Cage_washing_machine_in_release_facility_life_expectancy +
      Equipment_for_basic_QC_lab_MO_total_cost / Equipment_for_basic_QC_lab_MO_life_expectancy + 
    Workshop_equipment_MO_total_cost / Workshop_equipment_MO_life_expectancy
    
    #### >> 14.3. Total ####
    Total_equipment_cost = 
      Mass_rearing_facility_equipment_cost + 
      Release_facility_equipment_cost
    
    Total_equipment_yearly_depreciation = 
      Mass_rearing_facility_equipment_yearly_depreciation + 
      Release_facility_equipment_yearly_depreciation
    
    #### > 15. Diet and consumable costs ####
    #### >> 15.1. Larval diet ####
    Ingredient_quantity =
      Weekly_ingredients * 
      Number_of_weeks_with_releases_per_year
    
    Water_including_the_initial_load_of_trays_quantity = 
      Total_water_required_weekly *   
    Number_of_weeks_with_releases_per_year / 1000
    
    Ingredient_yearly_cost = Ingredient_quantity * c(
      Beef_liver_powder_unit_cost,
      Tuna_meal_unit_cost,
      Brewer_yeast_unit_cost,
      BSF_powder_unit_cost,
      Component_5_unit_cost,
      Component_6_unit_cost
    )
    
    Water_including_the_initial_load_of_trays_yearly_cost = 
      Water_including_the_initial_load_of_trays_unit_cost * 
      Water_including_the_initial_load_of_trays_quantity
    
    #### >> 15.2. Adult diet ####
    Sugar_for_adult_colony_quantity =
      Total_sugar_for_adult_diet_weekly * 
      Number_of_weeks_with_releases_per_year
    
    Sugar_for_adult_colony_yearly_cost = 
      Sugar_for_adult_colony_unit_cost * 
      Sugar_for_adult_colony_quantity
    
    Blood_for_adult_diet_quantity = 
      Blood_for_adult_diet_weekly * 
      Number_of_weeks_with_releases_per_year
    
    Blood_for_adult_diet_yearly_cost = 
      Blood_for_adult_diet_unit_cost * 
      Blood_for_adult_diet_quantity
    
    Total_diet_yearly_cost = 
      sum(Ingredient_yearly_cost) + 
      Water_including_the_initial_load_of_trays_yearly_cost +
      Sugar_for_adult_colony_yearly_cost +
      Blood_for_adult_diet_yearly_cost
    
    #### >> 15.3. Other consumables ####
    Radiation_dosimeters_quantity = 
      Number_of_irradiation_operations_per_day * 
      7 * 
      Number_of_weeks_with_releases_per_year
    
    Radiation_dosimeters_yearly_cost = 
      Radiation_dosimeters_unit_cost * 
      Radiation_dosimeters_quantity
    
    Consumables_without_inventoring_yearly_cost = 
      Consumables_without_inventoring_unit_cost * 
      (Total_diet_yearly_cost + Radiation_dosimeters_yearly_cost)
    
    Total_other_consumables_yearly_cost = 
      Radiation_dosimeters_yearly_cost + 
      Consumables_without_inventoring_yearly_cost
    
    Yearly_cost_of_diet_and_consumables = 
      Total_diet_yearly_cost + 
      Total_other_consumables_yearly_cost
    
    #### > 16. results ####
    results = list(
      production = {data.frame(
        Weekly_goal = Weekly_pupal_production,
        Number_of_eggs_to_be_hatch = Egg_hatching_amount*Egg_density,
        Number_of_larvae = Total_larval_trays * L1_per_colony_tray,
        Number_of_larval_rack = Total_racks, 
        Number_of_adults = Total_colony_cages * females_in_colony_cages * 
          (1 + 1/female_per_male),
        Number_of_Male_Release_cage = Total_RM_cages
      )},
      
      area = {data.frame(
        # Mass rearig facility
        Weekly_goal = Weekly_pupal_production,
        Larval_development_room_area, 
        Tray_loading_room_area,
        Larval_pupal_sorting_room_area,
        Sex_sorting_room_area,
        Adult_room_area,
        Cage_loading_room_area,
        Irradiation_room_area,
        Storage_area,
        Offices_area,
        WC_area,
        Corridor_area,
        Mass_rearing_facility_area,
        # Release facility
        MO_room_area,
        Chilling_room_area,
        MO_Offices_area,
        MO_WC_area,
        MO_Corridor_area,
        Release_facility_area)},
      
      workload = {data.frame(
        Weekly_goal = Weekly_pupal_production,
        # Workload
        ## Mass Rearing  
        Egg_hatching_workload,
        Tray_hanging_workload,
        L1_dosage_workload,
        L4_loading_workload,
        Larval_feeding_workload,
        Tray_tilting_workload,
        L1_sex_sorting_workload,
        Tray_washing_workload,
        Irradiation_workload,
        Insect_packing_for_irradiation_workload,
        Colony_cage_loading_workload,
        Colony_cage_bloodfeeding_workload,
        Egg_collection_workload,
        Egg_storage_workload,
        Colony_cage_washing_workload,
        Larval_diet_prep_workload,
        Adult_diet_prep_workload,
        Blood_collection_workload,
        Blood_doses_prep_workload,
        Workload_mass_rearing_facility,
        ## Release
        MO_cage_loading_workload,
        MO_adult_diet_prep_workload,
        MO_cage_chilling_workload,
        MO_adult_collection_workload,
        MO_adult_packing_for_release_workload,
        MO_cage_washing_workload,
        Workload_release_facility,
        
        # Staff 
        ## Mass rearing
        Staff_needed_every_day_mass_rearing,
        Team_leaders_needed_mass_rearing,
        Total_rearing_labourers_mass_rearing,
        Total_team_leaders_mass_rearing,
        Total_QC_managers_mass_rearing,
        QC_technicians_needed_mass_rearing,
        Maintenance_manager_needed_mass_rearing,
        Total_Maintenance_manager_needed_mass_rearing,
        Maintenance_officer_needed_mass_rearing,
        Total_Maintenance_officer_needed_mass_rearing,
        Total_manager_needed_mass_rearing,
        Admin_assistant_needed_mass_rearing,
        Total_Admin_assistant_needed_mass_rearing,
        ## Release facility
        Staff_needed_every_day_release_facility,
        Team_leaders_needed_release_facility,
        Total_rearing_labourers_release_facility,
        Total_team_leaders_release_facility,
        QC_managers_needed_release_facility,
        Total_QC_managers_release_facility,
        QC_technicians_needed_release_facility,
        Total_QC_technicians_needed_release_facility,
        Maintenance_manager_needed_release_facility,
        Total_Maintenance_manager_needed_release_facility,
        Maintenance_officer_needed_release_facility,
        Total_Maintenance_officer_needed_release_facility,
        Manager_needed_release_facility,
        Total_manager_needed_release_facility,
        Admin_assistant_needed_release_facility,
        Total_Admin_assistant_needed_release_facility,
        Total_rearing_labourers_both_facilities,
        Total_team_leaders_both_facilities,
        Total_QC_managers_both_facilities,
        Total_QC_technicians_both_facilities,
        Total_Maintenance_manager_both_facilities,
        Total_Maintenance_officer_both_facilities,
        Total_manager_both_facilities,
        Total_Admin_assistant_both_facilities,
        Total_staff_both_facilities
      )},
      
      cost = list(
        contruction.cost = {data.frame(
          Weekly_goal = Weekly_pupal_production,
          Cost_office_labs_wc_irradiation_corridor,
          Cost_rearing_rooms,
          Cost_storage_warehouse,
          Construction_cost_mass_rearing_facility,
          Yearly_depreciation_mass_rearing_facility,
          # Release facility
          Cost__office_labs_wc_irradiation_corridor_MO,
          Cost_chilling_room_MO,
          Cost_rearing_rooms_MO,
          Cost_storage_warehouse_MO,
          Construction_cost_release_facility,
          Yearly_depreciation_release_facility
        )},
        
        equipement.cost = {data.frame(
          Weekly_goal = Weekly_pupal_production,
          # Mass rearing facility
          Larval_trays_total_cost,
          Racks_for_larval_trays_total_cost,
          Cages_for_Colonies_total_cost,
          Irradiator_total_cost,
          L1_Sex_sorter_total_cost,
          Pupal_sex_sorter_total_cost,
          L1_counter_total_cost,
          Larval_diet_mixer_total_cost,
          Adult_diet_mixer_total_cost,
          Larval_diet_feeder_total_cost,
          Blood_feeders_total_cost,
          Tray_washing_machine_in_mass_rearing_facility_total_cost,
          Cage_washing_machine_in_mass_rearing_facility_total_cost,
          Equipment_for_basic_QC_lab_total_cost,
          Workshop_equipment_total_cost,
          Blood_storage_total_cost,
          Mass_rearing_facility_equipment_cost,
          Mass_rearing_facility_equipment_yearly_depreciation,
          # Release facility
          Cages_for_Release_Males_total_cost,
          Cage_washing_machine_in_release_facility_total_cost,
          Equipment_for_basic_QC_lab_MO_total_cost,
          Workshop_equipment_MO_total_cost,
          Release_facility_equipment_cost,
          Release_facility_equipment_yearly_depreciation,
          # Total
          Total_equipment_cost,
          Total_equipment_yearly_depreciation
        )},
        
        consumable.cost = {data.frame(
          Weekly_goal = Weekly_pupal_production,
          # Larval diet
          t(Ingredient_yearly_cost),
          Water_including_the_initial_load_of_trays_yearly_cost,
          #  Adult diet
          Sugar_for_adult_colony_yearly_cost,
          Blood_for_adult_diet_yearly_cost,
          Total_diet_yearly_cost,
          # Other consumables
          Radiation_dosimeters_yearly_cost,
          Consumables_without_inventoring_yearly_cost,
          Total_other_consumables_yearly_cost,
          Yearly_cost_of_diet_and_consumables
        )}
      ), 
      
      initial.parameters = parameter.lists,
      
      all.parameters = list(
        
        production.parameters = {data.frame(
          Survival_eggs_to_pupae,
          overall_male_pupae_recovery,
          overall_female_pupae_recovery,
          Oviposition_period,
          Average_oviposition_rate_during_oviposition_period,
          Duration_of_cage,
          volume_of_colony_larval_trays,
          L1_per_colony_tray,
          Number_of_larval_trays_per_rack__Colony,
          Vertical_net_in_colony_cages,
          Males_per_MO_cage,
          pupae_load_per_MO_cage,
          Vertical_resting_in_colony_cages,
          Adults_in_colony_cages,
          female_per_male,
          females_in_colony_cages,
          female_pupae_load_per_colony_cage
        )},
        
        male.only.production = {data.frame(
          Weekly_production_of_flying_males_for_release,
          MO_cages_loaded_per_day,
          Total_number_of_cages_permanently_in_use_in_the_emergence_center,
          Number_of_irradiation_operations_per_day,
          Male_L1__to_be_seeded_per_day_for_MO,
          Larval_trays_to_be_loaded_with_L1_per_day_for_MO,
          Larval_racks_to_be_loaded_with_L1_per_day_for_MO,
          Number_of_larval_racks_to_be_loaded_after_the_1st_sorting_for_MO,
          Number_of_larval_trays_to_be_loaded_after_the_2nd_sorting_for_MO,
          Number_of_larval_racks_to_be_loaded_after_the_2nd_sorting_for_MO,
          Total_number_of_larval_trays_to_be_loaded_everyday_for_MO,
          Total_number_of_larval_trays_to_be_fed_everyday_for_MO,
          Total_number_of_larval_trays_permanently_in_use_for_MO,
          Total_number_of_larval_racks_permanently_in_use_for_MO
        )},
        
        mass.rearing = {data.frame(
          number.of.rearing.colony,
          eggs_to_be_hatched_per_day_for_male_only_production,
          eggs_to_be_hatched_per_week_for_male_only_production,
          both_sex_L1_to_be_sorted_per_day_for_male_only,
          volume_eggs_to_be_hatched_per_day_for_male_only_production,
          Ovipositing_females_permanently_in_the_colony,
          Pre_ovipositing_females_in_the_colony,
          Number_of_ovipositing_females_to_be_replaced_everyday,
          Number_of_pupae_needed_to_replace_females_in_the_rearing_colony,
          Cage_units_to_be_loaded_per_day_to_produce_the_eggs_for_stockpiling,
          Number_of_colony_cages_to_be_blood_fed_per_day_in_the_rearing_colony,
          Number_of_colony_cages_to_be_collected_for_eggs_per_day_in_the_rearing_colony,
          Number_of_eggs_for_female_replacement_needed_from_each_filter_colony_everyday,
          Number_of_L1_both_sex_to_be_sex_sorted_per_day_for_female_replacement,
          Number_of_larval_trays_to_be_loaded_per_day_for_female_replacement,
          Number_of_larval_trays_to_be_reloaded_after_the_first_sorting_for_female_replacement,
          Number_of_larval_trays_to_be_reloaded_after_the_second_sorting_for_female_replacement,
          Number_of_larval_trays_to_be_fed_everyday,
          Total_number_of_trays_permanently_in_use_in_the_larval_room,
          Total_number_of_racks_permanently_in_use_in_the_larval_room,
          Pre_oviposition_cages_permanently_in_use_for_egg_production,
          Oviposition_cages_permanently_in_use_for_egg_production,
          Total_number_of_cages_permanently_in_use_for_egg_production__Preoviposition_Oviposition
        )},
        
        filter.colony = {data.frame(
          Number_of_eggs_for_female_replacement_needed_from_each_filter_colony_week,
          Number_eggs_for_rearing_colony_and_filter_colony_per_week,
          Number_eggs_for_rearing_colony_and_filter_colony_per_day,
          Number_of_ovipositing_females_in_each_filter,
          Number_of_preovipositing_females_in_each_filter,
          Number_of_females_to_be_replaced_everyday_in_each_filter,
          Number_of_colony_cages_to_be_bloodfed_per_day_in_both_filters,
          Number_of_colony_cages_to_be_collected_for_eggs_per_day_in_both_filters,
          Number_of_colony_cages_to_be_loaded_per_day_in_both_filters,
          Preoviposition_cages_permanently_in_use_for_egg_production_in_both_filters,
          Oviposition_cages_permanently_in_use_for_egg_production_in_both_filters,
          Total_number_of_cages_permanently_in_use_for_egg_production_in_both_filters,
          Eggs_to_be_hatched_per_day_to_replace_the_females_in_each_filter,
          Number_of_L1_both_sex_to_be_sex_sorted_per_day_for_both_filters,
          Number_of_larval_trays_to_be_loaded_with_L1_per_day_in_both_filters,
          Number_of_larval_trays_to_be_loaded_after_the_first_sorting_per_day_in_both_filters,
          Number_of_larval_trays_to_be_loaded_after_the_second_sorting_per_day_in_both_filters,
          Number_of_larval_trays_to_be_fed_everyday_in_both_filters,
          Number_of_trays_to_be_sorted_every_day_in_both_filters,
          Number_of_trays_to_be_loaded_every_day_in_both_filters,
          Total_number_of_trays_permanently_in_use_in_the_larval_room_in_both_filters,
          Number_of_larval_racks_to_be_loaded_with_L1_per_day_in_both_filters,
          Number_of_larval_racks_to_be_loaded_after_the_first_sorting_per_day_in_both_filters,
          Number_of_larval_racks_to_be_loaded_after_the_second_sorting_per_day_in_both_filters,
          Total_number_of_racks_permanently_in_use_in_the_larval_room_in_both_filters
        )},
        
        diet.formula = {data.frame(
          Total_compo_larval_diet,
          t(Volume_of_larval_diet_added_on_day_i),
          t(Concentration_of_larval_diet_added_on_day_i),
          Water_percentage_in_adult_diets,
          Volume_of_water_per_colony_cage,
          Volume_of_water_per_MO_cage,
          Volume_of_blood_per_casing,
          Blood_for_colony_females_per_day
        )},
        
        diet.requirements = {data.frame(
          Total_volume_added_per_day,
          t(daily_ingredients),
          Larval_diet_solution_daily,
          Water_larval_diet_daily,
          t(Weekly_ingredients),
          Larval_diet_solution_weekly,
          Water_larval_diet_weekly,
          Water_for_adult_colony_daily,
          Water_for_release_males_daily,
          Total_water_for_adult_diet_daily,
          Sugar_for_adult_colony_daily,
          Sugar_for_release_males_daily,
          Total_sugar_for_adult_diet_daily,
          Blood_for_adult_diet_daily,
          Water_for_adult_colony_weekly,
          Water_for_release_males_weekly,
          Total_water_for_adult_diet_weekly, 
          Sugar_for_adult_colony_weekly,
          Sugar_for_release_males_weekly,
          Total_sugar_for_adult_diet_weekly,
          Blood_for_adult_diet_weekly,
          t(Ingredients_volume),
          t(Ingredients_height),
          t(Ingredients_area),
          Total_sugar_for_adult_diet_volume,
          Total_sugar_for_adult_diet_area,
          Blood_for_storage,
          Water_for_storage,
          size_of_store_for_diet_ingredients)},
        
        rearing.equipment = {data.frame(
          Total_larval_trays,
          Total_number_of_larval_trays_required,
          Total_racks,
          Total_number_of_racks_required,
          Total_colony_cages,
          Total_number_of_cages_required,
          Total_RM_cages,
          Total_number_of_RM_cages_required,
          Number_of_insects_to_be_irradiated_per_day,
          Irradiator_workload,
          Irradiator_number_of_units,
          Irradiator_workload_per_unit,
          L1_to_be_sexed_per_day,
          L1_sex_sorter_workload,
          L1_sex_sorter_number_of_units,
          L1_sex_sorter_workload_per_unit,
          Number_of_pupae_to_be_sexed_per_day,
          Pupal_sorter_workload,
          Pupal_sorter_number_of_units,
          Pupal_sorter_workload_per_units,
          Number_of_trays_to_be_seeded_per_day,
          L1_counter_workload,
          L1_counter_number_of_units,
          L1_counter_workload_per_units,
          Larval_diet_mixer_daily_batches,
          Larval_diet_mixer_workload,
          Larval_diet_mixer_number_of_units,
          Larval_diet_mixer_workload_per_unit,
          Adult_diet_mixer_daily_batches,
          Adult_diet_mixer_workload,
          Adult_diet_mixer_number_of_units,
          Adult_diet_mixer_workload_per_unit,
          Total_number_of_larval_trays_to_be_fed_everyday,
          Larval_feeder_workload,
          Larval_feeder_number_of_units,
          Larval_feeder_workload_per_unit,
          Total_number_of_cages_to_be_blood_fed_per_day,
          Blood_feeder_workload ,
          Blood_feeder_number_of_units,
          Blood_feeder_workload_per_unit,
          Trays_to_be_washed_per_day,
          Tray_washer_workload,
          Tray_washer_number_of_units,
          Tray_washer_workload_per_unit,
          Cages_to_be_washed_per_day,
          Cage_washer_workload,
          Cage_washer_number_of_units,
          Cage_washer_workload_per_unit,
          MO_cages_to_be_washed_per_day,
          MO_cage_washer_workload,
          MO_cage_washer_number_of_units,
          MO_cage_washer_workload_per_unit)},
        
        water.requirements = {data.frame(
          Water_for_larval_trays_initial_loading_daily,
          Water_for_larval_trays_initial_loading_weekly,
          Water_for_tray_washing_daily,
          Water_for_tray_washing_weekly,
          Water_for_colony_cage_washing_daily,
          Water_for_colony_cage_washing_weekly,
          Water_for_MO_cage_washing_daily,
          Water_for_MO_cage_washing_weekly,
          Water_for_room_cleaning_daily,
          Water_for_room_cleaning_weekly,
          Total_water_required_daily,
          Total_water_required_weekly)},
        
        area.calculation = {data.frame(
          Rack_unit_footprint,
          Larval_development_room_area,
          Tray_loading_room_area,
          Larval_pupal_sorting_room_area,
          Sex_sorting_room_area,
          Colony_cage_unit_footprint,
          Adult_room_area,
          Cage_loading_room_area,
          Irradiation_room_area,
          Storage_area,
          Offices_area,
          WC_area,
          Corridor_area,
          Mass_rearing_facility_area,
          MO_cage_footprint,
          MO_room_area,
          Chilling_room_area,
          MO_Offices_area,
          MO_WC_area,
          MO_Corridor_area,
          Release_facility_area)}, 
        
        construction.cost = {data.frame(
          Area_office_labs_wc_irradiation_corridor,
          Cost_office_labs_wc_irradiation_corridor,
          Area_rearing_rooms,
          Cost_rearing_rooms,
          Area_storage_warehouse,
          Cost_storage_warehouse,
          Construction_cost_mass_rearing_facility,
          Yearly_depreciation_mass_rearing_facility,
          Area_office_labs_wc_irradiation_corridor_MO,
          Cost__office_labs_wc_irradiation_corridor_MO,
          Cost_chilling_room_MO,
          Area_rearing_rooms_MO,
          Cost_rearing_rooms_MO,
          Cost_storage_warehouse_MO,
          Construction_cost_release_facility,
          Yearly_depreciation_release_facility)}, 
        
        workload = {data.frame(
          Egg_hatching_amount,
          Egg_hatching_workload,
          Tray_hanging_amount,
          Tray_hanging_workload,
          L1_dosage_amount,
          L1_dosage_workload,
          L4_loading_amount,
          L4_loading_workload,
          Larval_feeding_amount,
          Larval_feeding_workload,
          Tray_tilting_amount,
          Tray_tilting_workload,
          L1_sex_sorting_work_rate,
          L1_sex_sorting_workload,
          Tray_washing_workload,
          Irradiation_workload,
          Insect_packing_for_irradiation_workload,
          Colony_cage_loading_amount,
          Colony_cage_loading_workload,
          Colony_cage_bloodfeeding_amount,
          Colony_cage_bloodfeeding_workload,
          Egg_collection_amount,
          Egg_collection_workload,
          Egg_storage_amount,
          Egg_storage_workload,
          Colony_cage_washing_amount,
          Colony_cage_washing_workload,
          Larval_diet_prep_batches,
          Larval_diet_prep_workload,
          Adult_diet_prep_batches,
          Adult_diet_prep_workload,
          Blood_collection_workload,
          Blood_doses_prep_amount,
          Blood_doses_prep_workload,
          Workload_mass_rearing_facility,
          Staff_needed_every_day_mass_rearing,
          Team_leaders_needed_mass_rearing,
          MO_cage_loading_workload,
          MO_adult_diet_prep_batches,
          MO_adult_diet_prep_work_rate,
          MO_adult_diet_prep_workload,
          MO_cage_chilling_workload,
          MO_adult_collection_workload,
          MO_adult_packing_for_release_workload,
          MO_cage_washing_amount,
          MO_cage_washing_work_rate,
          MO_cage_washing_workload,
          Workload_release_facility,
          Staff_needed_every_day_release_facility,
          Team_leaders_needed_release_facility,
          Total_rearing_labourers_mass_rearing,
          Total_team_leaders_mass_rearing,
          Total_QC_managers_mass_rearing,
          QC_technicians_needed_mass_rearing,
          Maintenance_manager_needed_mass_rearing,
          Total_Maintenance_manager_needed_mass_rearing,
          Maintenance_officer_needed_mass_rearing,
          Total_Maintenance_officer_needed_mass_rearing,
          Total_manager_needed_mass_rearing,
          Admin_assistant_needed_mass_rearing,
          Total_Admin_assistant_needed_mass_rearing,
          Total_rearing_labourers_release_facility,
          Total_team_leaders_release_facility,
          QC_managers_needed_release_facility,
          Total_QC_managers_release_facility,
          QC_technicians_needed_release_facility,
          Total_QC_technicians_needed_release_facility,
          Maintenance_manager_needed_release_facility,
          Total_Maintenance_manager_needed_release_facility,
          Maintenance_officer_needed_release_facility,
          Total_Maintenance_officer_needed_release_facility,
          Manager_needed_release_facility,
          Total_manager_needed_release_facility,
          Admin_assistant_needed_release_facility,
          Total_Admin_assistant_needed_release_facility,
          Total_rearing_labourers_both_facilities,
          Total_team_leaders_both_facilities,
          Total_QC_managers_both_facilities,
          Total_QC_technicians_both_facilities,
          Total_Maintenance_manager_both_facilities,
          Total_Maintenance_officer_both_facilities,
          Total_manager_both_facilities,
          Total_Admin_assistant_both_facilities,
          Total_staff_both_facilities)},
        
        equipment.budget = {data.frame(
          Larval_trays_total_cost,
          Racks_for_larval_trays_total_cost,
          Cages_for_Colonies_total_cost,
          Irradiator_total_cost,
          L1_Sex_sorter_total_cost,
          Pupal_sex_sorter_total_cost,
          L1_counter_total_cost,
          Larval_diet_mixer_total_cost ,
          Adult_diet_mixer_total_cost,
          Larval_diet_feeder_total_cost,
          Blood_feeders_total_cost,
          Tray_washing_machine_in_mass_rearing_facility_total_cost,
          Cage_washing_machine_in_mass_rearing_facility_total_cost,
          Equipment_for_basic_QC_lab_total_cost,
          Workshop_equipment_total_cost,
          Blood_storage_total_cost,
          Mass_rearing_facility_equipment_cost,
          Mass_rearing_facility_equipment_yearly_depreciation,
          Cages_for_Release_Males_total_cost,
          Cage_washing_machine_in_release_facility_total_cost,
          Equipment_for_basic_QC_lab_MO_total_cost,
          Workshop_equipment_MO_total_cost,
          Release_facility_equipment_cost,
          Release_facility_equipment_yearly_depreciation,
          Total_equipment_cost,
          Total_equipment_yearly_depreciation)},
        
        consumable.cost = {data.frame(
          t(Ingredient_quantity),
          Water_including_the_initial_load_of_trays_quantity,
          t(Ingredient_yearly_cost),
          Water_including_the_initial_load_of_trays_yearly_cost,
          Sugar_for_adult_colony_quantity,
          Blood_for_adult_diet_quantity,
          Sugar_for_adult_colony_yearly_cost,
          Blood_for_adult_diet_yearly_cost,
          Total_diet_yearly_cost,
          Radiation_dosimeters_quantity,
          Radiation_dosimeters_yearly_cost,
          Total_other_consumables_yearly_cost,
          Yearly_cost_of_diet_and_consumables)}
      )
    )
    
    return(results)
    
  }
#### END FUNCTION ####
#### ~~~~~~~~~~~~ ####
#### TEST ####
tic()

result.simul = model.function(method = 'Size.manual', 
                              parameter.lists = parameter.lists)
toc()

#### ~~~~~~~~~~~ ####
#### SIMULATIONS ####
range.methods = c('Size.manual', 'Size.auto','GSS', 'GSS-CS')
range.production = c(5,10,20,50,100)
date.simul = 'date.of.your.simulation'

for(i in range.methods){
  for(j in range.production){
    parm = parameter.lists
    parm$production.goals$Weekly_pupal_production = j / parm$biological.parm$Survival_pupae_to_flying_males
    parm$biological.parm$Number_of_tilting_or_sex_sorting_operations_for_colony =
      if(i %in% c('GSS', 'GSS-CS')){1}else{2}

    parm$rearing.equipment$Pupal_sex_sorter_male_recovery =
      if(i == 'Size.manual'){.4273}else{.4030}

    parm$equipment.budget$Pupal_sex_sorter_unit_price =
      if(i == 'Size.manual'){2000}else{40000}
    
    simul = model.function(method = i, parameter.lists = parm)
    
    saveRDS(object = simul, 
            file = paste0('simulations/', date.simul,
                          '_simul_method-',
                          i,'_prod-',
                          j,'.RDS'))
  }
}
#### ~~~~~~~~~~~ ####