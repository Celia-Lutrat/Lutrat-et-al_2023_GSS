rm(list = ls())

#### Packages ####
library(tidyverse)
library(purrr)
library(ggpubr)

#### Combining simulations ####
range.methods = c('Size.manual', 'Size.auto','GSS', 'GSS-CS')
gss.col = c("#000000", "#808080", "#42ff03", "#219676")
gss.lty = c('dashed','dashed','solid','solid')
range.production = c(5,10,20,50,100)
date.simul = 'date.of.your.simulation'

results = 
  map_df(
    .x = range.methods, 
    .f = function(i){
      data.frame(
        method = i, 
        map_df(.x = range.production,
               .f = function(j){
                 simul = readRDS(
                   paste0('simulations/',
                          date.simul,
                          '_simul_method-',
                          i,'_prod-',
                          j,'.RDS'))
                 c(pupae.production = j, 
                   simul$production,
                   simul$area[-1],
                   simul$workload[-1],
                   simul$cost$contruction.cost[-1],
                   simul$cost$equipement.cost[-1],
                   simul$cost$consumable.cost[-1], 
                   simul$all.parameters$water.requirements
                 )
               })
      )
    }
    
  )

results$method = factor(results$method, 
                        levels = c('Size.manual', 'Size.auto',
                                   'GSS', 'GSS-CS'))

#### Saving results ####
write.csv(results, 
          paste0('simulations/simulations-output',
                 date.simul,'.csv'), 
          row.names = F)

#### Plots ####
p1 = 
  ggplot(data = results, 
         aes(x = pupae.production, 
             y = Number_of_adults,
             color = method, lty = method)
  ) + 
  geom_point(data = results, 
             aes(x = pupae.production, 
                 y = Number_of_larvae,
                 color = method, lty = method),
             size = 1) +
  geom_line(data = results, 
            aes(x = pupae.production, 
                y = Number_of_larvae,
                color = method, lty = method)) + 
  labs(x = "Flying male production (M males / week)", 
       y = "Number of larvae in the mass-rearing facility") +
  scale_x_continuous(breaks=c(0, 5, 10 , 20 ,50,100), 
                     minor_breaks = seq(0,100,10)) +
  scale_color_manual(values=gss.col) +
  scale_y_continuous(labels = scales::label_number_si()) +
  expand_limits(y = 0, x = 0) +
  scale_linetype_manual(values = gss.lty) + 
  theme_bw() + 
  theme(legend.position = "none")
p1

p2 = 
  ggplot(data = results, 
         aes(x = pupae.production, 
             y = Construction_cost_mass_rearing_facility + 
               Construction_cost_release_facility,
             color = method, lty = method)) + 
  geom_point(size = 1) +
  geom_line() + 
  labs(x = "Flying male production (M males / week)", 
       y = "Construction cost for both facilities ($)") +
  scale_y_continuous(labels = scales::label_number_si()) +
  expand_limits(y = 0, x = 0) +
  scale_x_continuous(breaks=c(0, 5, 10 , 20 ,50,100), 
                     minor_breaks = seq(0,100,10)) +  
  scale_color_manual(values=gss.col) +
  scale_linetype_manual(values = gss.lty) + 
  theme_bw() +
  theme(legend.position = "none")
p2

p3 = 
  ggplot(data = results, 
         aes(x = pupae.production, 
             y = Yearly_cost_of_diet_and_consumables,
             color = method, lty = method)
  ) + 
  geom_point(size = 1) +
  geom_line() + 
  labs(x = "Flying male production (M males / week)", 
       y = "Diet and consumable\nyearly cost ($/year)") + 
  scale_y_continuous(labels = scales::label_number_si()) +
  expand_limits(y = 0, x = 0) +
  scale_x_continuous(breaks=c(0, 5, 10 , 20 ,50,100), 
                     minor_breaks = seq(0,100,10)) +
  scale_color_manual(values=gss.col) +
  scale_linetype_manual(values = gss.lty) + 
  theme_bw() +
  theme(legend.position = "none")

p4 = 
  ggplot(data = results, 
         aes(x = pupae.production, 
             y = Total_equipment_yearly_depreciation,
             color = method, lty = method)) + 
  geom_point(size = 1) +
  geom_line() + 
  scale_y_continuous(labels = scales::label_number_si()) +
  expand_limits(y = 0, x = 0) +
  scale_x_continuous(breaks=c(0, 5, 10 , 20 ,50,100), 
                     minor_breaks = seq(0,100,10)) +
  scale_color_manual(values=gss.col) +
  scale_linetype_manual(values = gss.lty) + 
  labs(x = "Flying male production (M males / week)", 
       y = "Equipment cost for both facilities \n(yearly cost, $/year)") +
  theme_bw() +
  theme(legend.position = "none")

p5 = 
  ggplot(data = results, 
         aes(x = pupae.production, 
             y = Total_equipment_yearly_depreciation + 
               Yearly_cost_of_diet_and_consumables + 
               Yearly_depreciation_mass_rearing_facility + 
               Yearly_depreciation_release_facility,
             color = method, lty = method)
  ) + 
  geom_point(size = 1) +
  geom_line() + 
  labs(x = "Flying male production (M males / week)", 
       y = "Estimate of total yearly \ncosts excluding staff ($/year)") +
  scale_y_continuous(labels = scales::label_number_si()) +
  expand_limits(y = 0, x = 0) +
  scale_x_continuous(breaks=c(0, 5, 10 , 20 ,50,100), 
                     minor_breaks = seq(0,100,10)) +
  scale_color_manual(values=gss.col) +
  scale_linetype_manual(values = gss.lty) + 
  theme_bw() +
  theme(legend.position = "none")

p7 = 
  ggplot(data = results,
         aes(x = pupae.production,
             y = (Total_equipment_yearly_depreciation + 
                    Yearly_cost_of_diet_and_consumables + 
                    Yearly_depreciation_mass_rearing_facility + 
                    Yearly_depreciation_release_facility)/
               (pupae.production*52*1000000),
             color = method)
  ) +
  geom_point(size = 1) +
  geom_line() +
  labs(x = "Flying male production (M males / week)",
       y = "Estimate of non-staff cost \nper flying male produced ($)") +
  scale_y_continuous(labels = scales::label_number_si()) +
  expand_limits(y = 0, x = 0) +
  scale_x_continuous(breaks=c(0, 5, 10 , 20 ,50,100), 
                     minor_breaks = seq(0,100,10)) +
  scale_color_manual(values=gss.col) +
  theme_bw() +
  theme(legend.position = "none")

p6 = 
  ggplot(data = results, 
         aes(x = pupae.production, 
             y = Total_staff_both_facilities,
             color = method, lty = method)
  ) + 
  geom_point(size = 1) +
  geom_line() + 
  labs(x = "Flying male production (M males / week)", 
       y = "Total number of staff \nneeded for both facilities") +
  scale_x_continuous(breaks=c(0, 5, 10 , 20 ,50,100), 
                     minor_breaks = seq(0,100,10)) +
  scale_y_continuous(labels = scales::label_number_si()) +
  expand_limits(y = 0, x = 0) +
  scale_color_manual(values=gss.col) +
  scale_linetype_manual(values = gss.lty) + 
  theme_bw()+
  theme(legend.position = "none")

p = 
  ggpubr::ggarrange(
    p1 + theme(axis.title.x = element_blank()),
    p2 + theme(axis.title.x = element_blank()),
    p3 + theme(axis.title.x = element_blank()),
    p4 + theme(axis.title.x = element_blank()),
    p5 + theme(axis.title.x = element_blank()),
    p6 + theme(axis.title.x = element_blank()),
    common.legend = T,
    align = 'hv'
  ) |>
  annotate_figure(
    bottom = grid::textGrob("Flying male production (M males / week)")
    )

#### Saving plots ####
ggsave(plot = p, 
       filename = 'Simulation-results.png',
       bg = 'white',
       width = 24, height = 15, units = 'cm', dpi = 600)

ggsave(plot = p1, 
       filename = 'Simulation-number-larvae.png',
       bg = 'white',
       width = 10, height = 10, units = 'cm', dpi = 600)

ggsave(plot = p2, 
       filename = 'Simulation-construction-costs.png',
       bg = 'white',
       width = 10, height = 10, units = 'cm', dpi = 600)

ggsave(plot = p3, 
       filename = 'Simulation-consumable-costs.png',
       bg = 'white',
       width = 10, height = 10, units = 'cm', dpi = 600)

ggsave(plot = p4, 
       filename = 'Simulation-equipment-costs.png',
       bg = 'white',
       width = 10, height = 10, units = 'cm', dpi = 600)

ggsave(plot = p5, 
       filename = 'Simulation-total-cost.png',
       bg = 'white',
       width = 10, height = 10, units = 'cm', dpi = 600)

ggsave(plot = p6, 
       filename = 'Simulation-staff.png',
       bg = 'white',
       width = 10, height = 10, units = 'cm', dpi = 600)

