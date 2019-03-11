library(glue)
library(tidyverse)
library(gmailr)
template <- readr::read_file("./template.Rmd")
data <- tibble::tibble(qui = c("joel", "cecile", "samuel", "sylvain"),
                       opening = c("Cher Joël,", "Chère Cécile,", "Cher Samuel,", "Cher Sylvain,"),
                       adress = c("- Joël Gombin\n- ", "- Cécile Le Guen", "- Samuel Goëta", "- Sylvain Lapoix"),
                       date = rep("11 mars 2019", 4),
                       montant = c("xxx", "xxx", "xxx", "xxx"))

data %>% 
  mutate(lettre = glue(template), 
         path = paste0("./lettre", qui, ".Rmd"), 
         path_out = paste0("./lettre", qui, ".pdf"), 
         email = paste0(qui, "@datactivist.coop")) %>% 
  #  slice(1) %>%  for testing
  pwalk(~ readr::write_file(..6, ..7)) %>% 
  pwalk(~ rmarkdown::render(..7)) %>% 
  pmap( ~ mime(To = ..9, 
               From = "joel@datactivist.coop",
               Subject = "Participation 2017", 
               body = paste0(..2, "\n Je te prie de trouver ci-joint le courrier d'information concernant la participation acquise au titre de l'exercice 2017.\n Amitiés coopératives,\n Joël")) %>% 
          attach_part(paste0(..2, "\n Je te prie de trouver ci-joint le courrier d'information concernant la participation acquise au titre de l'exercice 2017.\n Amitiés coopératives,\n Joël")) %>% 
          attach_file(..8)) %>% 
  map(~ send_message(.))

