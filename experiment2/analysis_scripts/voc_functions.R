## Functions for VoC E2 ##
# KN
# 12/13/23


#plotting
# add theme for plotting
voc_theme <- function () {
  theme(
    panel.border = element_rect(fill = "transparent", color="gray75"),
    panel.background  = element_blank(),
    plot.background = element_blank(), 
    legend.background = element_rect(fill="transparent", colour=NA),
    legend.key = element_rect(fill="transparent", colour=NA),
    line = element_blank(),
    axis.ticks = element_line(color="gray75"),
    text=element_text(family="Avenir"),
    axis.text = element_text(size = 12),
    axis.title = element_text(size = 15),
    title = element_text(size = 15),
    strip.background = element_blank(),
    strip.text = element_text(size=12)
  )
}


color1 = "#00b4d8"
color2 = "#0077b6"
color3 = "#03045e"
color4 = "#84347C"
color5 = "#B40424"
color6 = "#EB6D1E"
color7 = "#f5b68f"
color8 = "#80dbb2"



#z-score
scale_this <- function(x) {
  (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)
}


#read in relevant parts of data
read_data <- function(x) {
  
  #read in csv
  sub_data <- read_csv(x)

  # compute the number of browser interactions
  num_interactions = length(str_split(tail(sub_data,1)$interactions, pattern = "\"time")[[1]])
  sub_data$num_interactions <- num_interactions
    
  sub_data <- sub_data %>%
      select(
        subject_id,
        num_interactions,
        phase,
        trial,
        context,
        offer,
        block,
        rt,
        stimulus,
        arcade_id_L,
        arcade_id_R,
        arcade_color_L,
        arcade_color_R,
        reward_prob_L,
        reward_prob_R,
        stage_1_choice,
        stage_1_rt,
        stage_2_choice,
        stage_2_rt,
        stage_3_outcome,
        accuracy,
        response
      ) %>%
      mutate(across(c(stage_1_choice:response), as.numeric))
    
    return(sub_data)
  }
  


