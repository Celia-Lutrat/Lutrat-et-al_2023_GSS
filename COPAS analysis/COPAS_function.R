rm(list = ls())

#### Function ####
COPAScluster = function (file.name, output.name = "count") {
  options(warn = -1)
  
  ####> 0. Settings ####
  # Packages 
  libs <- c(
    'tidyverse', 'factoextra',
    'ggplot2', 'ggpubr'
  )
  
  invisible(lapply(libs, library, character.only = T))
  
  # Define colors
  filt.names = c('in', 'out.neg', 'out.size', 'out.pca.size', 
                 'out.fluo', 'out.pca.fluo', 'out.bubbles')
  filt.cols = c('in' = '#000000', 'out.neg'='#ec123e', 
                'out.size'='#e8df3f', 'out.pca.size'='#dd5866', 
                'out.fluo'='#2c90a6', 'out.pca.fluo'='#3a0388', 'out.bubbles' ='grey')
  
  
  ####> 1. Data import  ####
  df = read.delim(file.name)
  # Removing NAs
  df = df[!is.na(df$TOF)&!is.na(df$EXT),]
  
  # Set filtering levels
  df$filtering = 'in'
  print(colnames(df))
  
  # Select fluorescence
  fluo1 = readline (
    "Enter the name of the abscissa fluorescence axis as written in the above list: ")
  ifelse(fluo1 %in% colnames(df), "" , return(paste(fluo1,"not in the list")))
  fluo2 = readline (
    "Enter the name of the ordinate fluorescence axis as written in the above list: ")
  
  # Check entree
  ifelse(fluo2 %in% colnames(df),"" , return(paste(fluo2,"not in the list")))
  
  ####> 2. Data handling ####    
  
  # Set fluo
  df$fluo1 = df[, fluo1]
  df$fluo2 = df[, fluo2]
  
  # Remove NAs
  df = df[!is.na(df$fluo1)&!is.na(df$fluo2),]
  
  # Log transformation
  df$log.fluo1 = log(df$fluo1) 
  df$log.fluo2 = log(df$fluo2)
  
  # Filter on minimum fluorescence
  df$filtering[!(df$fluo1 > 0 &
                   df$fluo2  > 0)] = "out.neg"
  
  # Visualization
  raw.size = ggplot(df, aes(TOF, EXT, color = filtering)) + 
    geom_point(size=.5) + 
    scale_color_manual(breaks = filt.names, values = filt.cols) +
    theme_classic()
  
  raw.fluo = ggplot(df, aes(log.fluo1, log.fluo2, color = filtering)) + 
    geom_point(size=.5) + 
    labs(x = paste("log(",fluo1,")"), y = paste("log(",fluo2,")")) +
    scale_color_manual(breaks = filt.names, values = filt.cols) +
    theme_classic()
  
  print(ggarrange(raw.size, raw.fluo))

  ####> 3. Bubble filtering####    
  bubbles = NA
  
  # Need to remove bubbles
  while(!(bubbles %in% c('Y', 'N'))){
    bubbles = 
      readline ("Are there other bubbles in the sample?\n(Answer must be 'Y' for yes or 'N' for no): ")
  }
  
  if(bubbles == "Y") {
    param = NA 
    while(!(param %in% colnames(df))){
      param = 
        readline (
        "What main parameter must be used for filtering bubbles?\n Use the name of one of the axes. \n Values below a given threshold on this axis will be removed. ")
    }
    
    bubbles.ok = "N"
    while (bubbles.ok != "Y") { 
      value = as.numeric(readline ("What value is the threshold for eliminating bubbles on this axis?\n Enter a number: "))
      
      df$filtering[df$filtering=="out.bubbles"] = "in"
      df$filtering[df[,param] < value] = "out.bubbles"
      
      # Visualization
      raw.size.2 = ggplot(df, aes(TOF, EXT, color = filtering)) + 
        geom_point(size=.5) + 
        scale_color_manual(breaks = filt.names, values = filt.cols) +
        theme_classic()
      
      raw.fluo.2 = ggplot(df, aes(log.fluo1, log.fluo2, color = filtering)) + 
        geom_point(size=.5) + 
        scale_color_manual(breaks = filt.names, values = filt.cols) +
        labs(x = paste("log(",fluo1,")"), y = paste("log(",fluo2,")")) +
        theme_classic()
      
      print(ggarrange(raw.size.2, raw.fluo.2, align = "hv"))
      
      bubbles.ok = readline ("Is this filtering of bubbles correct? (Write 'Y' for yes, 'N' for no.) ")
    }
    
  }
  
  #### > 4. Size filtering on size (EXT/TOF) ####
  # Visualization
  raw.size.2 = ggplot(df[df$filtering=="in",], aes(TOF, EXT, color = filtering)) + 
    geom_point(size=.5) + 
    scale_color_manual(breaks = filt.names, values = filt.cols) +
    theme_classic()
  print (raw.size.2)
  
  size.ok = "N"
  while(size.ok != "Y") {
    # Limits
    min.TOF = as.numeric(readline("Enter minimum value on TOF axis: "))
    max.TOF = as.numeric(readline("Enter maximum value on TOF axis: "))
    min.EXT = as.numeric(readline("Enter minimum value on EXT axis: "))
    max.EXT = as.numeric(readline("Enter maximum value on EXT axis: "))
    
    # Filtering
    df$filtering[df$filtering=="out.size"] = "in"
    df$filtering[df$filtering == "in" & 
                   !(df$TOF >= min.TOF & df$TOF <= max.TOF & 
                       df$EXT >= min.EXT & df$EXT <= max.EXT)] = "out.size"
    
    raw.size.3 = ggplot(df, aes(TOF, EXT, color = filtering)) + 
      geom_point(size=.5) + 
      scale_color_manual(breaks = filt.names, values = filt.cols) +
      theme_classic()
    
    print(raw.size.3)
    
    # Quality check
    size.ok = readline ("Are you satisfied by this outlier removing ? Y for yes, N for no. ")
  }
  
  # Filtering after PCA transformation
  pca.size = prcomp(df %>% filter(filtering == "in") %>% 
                      dplyr::select(TOF,EXT))
  
  # PCA on size
  df$pca.ind.1 = NA
  df$pca.ind.1[df$filtering == "in"] = get_pca_ind(pca.size)$coord[,1]
  df$pca.ind.2 = NA
  df$pca.ind.2[df$filtering == "in"] = get_pca_ind(pca.size)$coord[,2]
  
  # Visualization
  pca.size.ini = ggplot(df[df$filtering=="in",], aes(pca.ind.1, pca.ind.2, color = filtering)) + 
    geom_point(size=.5) + 
    scale_color_manual(breaks = filt.names, values = filt.cols) +
    theme_classic()
  
  pca.size.ok = "N"
  
  while (pca.size.ok != "Y") {
    print(pca.size.ini)
    
    # Set limits
    min.pca.ind.1 = as.numeric(readline ("Enter minimum value on pca.ind.1 axis "))
    max.pca.ind.1 = as.numeric(readline ("Enter maximum value on pca.ind.1 axis "))
    min.pca.ind.2 = as.numeric(readline ("Enter minimum value on pca.ind.2 axis "))
    max.pca.ind.2 = as.numeric(readline ("Enter maximum value on pca.ind.2 axis "))
    
    # Filtering
    df$filtering[df$filtering == "out.pca.size"] = "in"
    df$filtering[df$filtering == "in" & 
                   !(df$pca.ind.1 >= min.pca.ind.1 & df$pca.ind.1 <= max.pca.ind.1 & 
                       df$pca.ind.2 >= min.pca.ind.2 & df$pca.ind.2 <= max.pca.ind.2)] = "out.pca.size"
    
    #  Visualization
    size.pca = ggplot(df, aes(pca.ind.1, pca.ind.2, color = filtering)) + 
      geom_point(size=.5) + 
      scale_color_manual(breaks = filt.names, values = filt.cols) +
      theme_classic()+
      theme(legend.position = "none")
    
    raw.size.4 = ggplot(df, aes(TOF, EXT, color = filtering)) + 
      geom_point(size=.5) + 
      scale_color_manual(breaks = filt.names, values = filt.cols) +
      theme_classic()
    
    # Quality check
    size.filtering = ggarrange(size.pca, raw.size.4, widths = c(3,5)) 
    print(size.filtering)
    
    pca.size.ok = readline("Is size filtering ok?\n ('Y' for yes, 'N' for no): ") }
  
  ####> 5. Filtering on fluo graph ####
  # Visualization
  raw.fluo.2 = ggplot(df, aes(log.fluo1, log.fluo2, color = filtering)) + 
    geom_point(size=.5) + 
    scale_color_manual(breaks = filt.names, values = filt.cols) +
    labs(x = paste("log(",fluo1,")"), y = paste("log(",fluo2,")")) +
    theme_classic()
  fluo.filtered.1 = ggplot(df[df$filtering=="in",], aes(log.fluo1, log.fluo2)) + 
    geom_point(size=.5) + 
    scale_color_manual(breaks = filt.names, values = filt.cols) +
    labs(x = paste("log(",fluo1,")"), y = paste("log(",fluo2,")")) +
    theme_classic()
  
  print (ggarrange(raw.fluo.2, fluo.filtered.1))
  
  fluo.filt = readline("Do you want to filter particules from the fluorescence graph?\n ('Y' for yes, 'N' for no): ")
  if (fluo.filt == 'Y') {
    pca.fluo.ok = 'N'
    fluo.ok = 'N'
    
    while(fluo.ok != "Y") {
      # Set limits
      min.log.fluo1 = as.numeric(readline(paste("Enter minimum value on log(",fluo1,") axis ")))
      max.log.fluo1 = as.numeric(readline(paste("Enter maximum value on log(",fluo1,") axis ")))
      min.log.fluo2 = as.numeric(readline(paste("Enter minimum value on log(",fluo2,") axis ")))
      max.log.fluo2 = as.numeric(readline(paste("Enter maximum value on log(",fluo2,") axis ")))
      
      # Filtering
      df$filtering[df$filtering=="out.size"] = "in"
      df$filtering[df$filtering == "in" & 
                     !(df$log.fluo1 >= min.log.fluo1 & df$log.fluo1 <= max.log.fluo1 & 
                         df$log.fluo2 >= min.log.fluo2 & df$log.fluo2 <= max.log.fluo2)] = "out.size"
      
      # Visualization
      raw.fluo.3 = ggplot(df, aes(log.fluo1, log.fluo2, color = filtering)) + 
        geom_point(size=.5) + 
        scale_color_manual(breaks = filt.names, values = filt.cols) +
        labs(x = paste("log(",fluo1,")"), y = paste("log(",fluo2,")")) +
        theme_classic()
      
      # Quality check
      print(raw.fluo.3)
      fluo.ok = readline ("Are you satisfied with this fluorescence filtering? ('Y' for yes, 'N' for no): ")
    }
    
    # Filtering on fluorescence PCA
    # PCA
    pca.fluo = prcomp(df %>% filter(filtering == "in") %>% 
                        dplyr::select(log.fluo1,log.fluo2))
    
    df$pca.ind.1 = NA
    df$pca.ind.1[df$filtering == "in"] = get_pca_ind(pca.fluo)$coord[,1]
    df$pca.ind.2 = NA
    df$pca.ind.2[df$filtering == "in"] = get_pca_ind(pca.fluo)$coord[,2]
    
    # Visualization
    pca.fluo.ini = ggplot(df, aes(pca.ind.1, pca.ind.2, color = filtering)) +
      scale_color_manual(breaks = filt.names, values = filt.cols) +
      geom_point(size=.5) + 
      theme_classic()
    
    while (pca.fluo.ok != "Y") {
      print(pca.fluo.ini)
      # Set limits
      min.pca.ind.1 = as.numeric(readline ("Enter minimum value on pca.ind.1 axis "))
      max.pca.ind.1 = as.numeric(readline ("Enter maximum value on pca.ind.1 axis "))
      min.pca.ind.2 = as.numeric(readline ("Enter minimum value on pca.ind.2 axis "))
      max.pca.ind.2 = as.numeric(readline ("Enter maximum value on pca.ind.2 axis "))
      
      # Filtering
      df$filtering[df$filtering == "out.pca.fluo"] = "in"
      df$filtering[df$filtering == "in" & 
                     !(df$pca.ind.1 >= min.pca.ind.1 & df$pca.ind.1 <= max.pca.ind.1 & 
                         df$pca.ind.2 >= min.pca.ind.2 & df$pca.ind.2 <= max.pca.ind.2)] = "out.pca.fluo"
      
      # Visualization
      fluo.pca = ggplot(df, aes(pca.ind.1, pca.ind.2, color = filtering)) + 
        geom_point(size=.5) + 
        scale_color_manual(breaks = filt.names, values = filt.cols) +
        theme_classic()
      
      raw.fluo.4 = ggplot(df, aes(log.fluo1, log.fluo2, color = filtering )) + 
        geom_point(size=.5) + 
        scale_color_manual(breaks = filt.names, values = filt.cols) +
        labs(x = paste("log(",fluo1,")"), y = paste("log(",fluo2,")")) +
        theme_classic()
      
      fluo.filtering = ggarrange(fluo.pca, raw.fluo.4)
      
      # Quality check
      print (fluo.filtering)
      pca.fluo.ok = readline("Are you satisfied with this fluorescence filtering ? Y for yes, N for no. ") }
  }
  
  # Final visualization of filters 
  raw.size.4 = ggplot(df, aes(TOF, EXT, color = filtering)) + 
    geom_point(size=.5) + 
    scale_color_manual(breaks = filt.names, values = filt.cols) +
    theme_classic()
  
  raw.fluo.4 = ggplot(df, aes(log.fluo1, log.fluo2, color = filtering )) + 
    geom_point(size=.5) + 
    scale_color_manual(breaks = filt.names, values = filt.cols) +
    labs(x = paste("log(",fluo1,")"), y = paste("log(",fluo2,")")) +
    theme_classic()
  
  size.filtered = ggplot(df[df$filtering=="in",], aes(TOF, EXT, color = filtering)) + 
    geom_point(size=.5) + 
    scale_color_manual(breaks = filt.names, values = filt.cols) +
    theme_classic()
  
  fluo.filtered = ggplot(df[df$filtering=="in",], aes(log.fluo1, log.fluo2, color = filtering)) + 
    geom_point(size=.5) + 
    scale_color_manual(breaks = filt.names, values = filt.cols) +
    labs(x = paste("log(",fluo1,")"), y = paste("log(",fluo2,")")) +
    theme_classic()
  
  filtering.plot = ggarrange(
    ggarrange(raw.size.4, size.filtered, legend = 'none', labels = c("A", "B")), 
    ggarrange(raw.fluo.4, fluo.filtered, common.legend = TRUE, legend="bottom", 
              labels = c("C", "D")), nrow=2, align = "v") %>%
    annotate_figure(.,top = text_grob( paste("Filtering plots of",output.name)))
  
  print(filtering.plot)
  
  ####> 6. Clustering by fluorescence####
  nb = readline ("Enter number of fluorescence clusters (integer): ")
  
  # Clustering analysis
  clust = kmeans(df %>%
                   dplyr::filter(filtering == "in") %>% 
                   dplyr::select(log.fluo1, log.fluo2), 
                 centers = nb)
  df$clust = NA
  df$clust[df$filtering == "in"] = clust$cluster %>% as.factor()
  
  # Visualization
  plot.clustering = ggplot(df[df$filtering == "in",], 
                           aes(jitter(log.fluo1, factor = 0), 
                               jitter(log.fluo2, factor = 0))) + 
    
    geom_point(aes(color = factor(clust)), size = .5) +
    labs(colour = "Clustering", 
         x = paste('log(', fluo1,')'), 
         y = paste('log(', fluo2,')'), subtitle = paste('Clustering plot of',output.name)) + 
    coord_fixed() +
    theme_classic()
  
  
  pal = c("#000000", "#004949","#009292","#ff6db6","#ffb6db",
          "#490092","#006ddb","#b66dff","#6db6ff","#b6dbff",
          "#920000","#924900","#db6d00","#24ff24","#ffff6d")
  names(pal) = 1:15
  
  pie.pal = ggplot(data = NULL, aes(x = '', y = 1, fill = names(pal))) +
    geom_bar(stat = 'identity', width=1, color="white") +
    scale_fill_manual(values = pal, breaks = names(pal), labels = names(pal)) +
    labs(fill = "Color code") + 
    coord_polar(theta = "y") + 
    theme_void()
  
  print(ggarrange(plot.clustering, pie.pal))
  
  # Information clusters
  names.cluster = data.frame(
    cluster=1:nb,
    name = NA, 
    color.nb = NA, 
    color.name = NA
  )
  for (i in 1:nb) {
    names.cluster[i,2] = readline(paste("Enter name of the cluster named", i, ": "))
    names.cluster[i,3] = as.numeric(readline(paste("Enter number of the color you want for cluster ", i, ": ")))
    names.cluster[i,4] = pal[names.cluster[i,3]]
  }
  
  ask.sub = readline("Enter graph title: ")
  
  ####> 7. Saving data ####
  # Handling output table
  df.output = clust$cluster %>%
    factor %>%
    summary() %>%
    data.frame() %>%
    mutate(cluster = names.cluster$name) %>%
    mutate(input.file = file.name) %>%
    dplyr::select(input.file, cluster, individuals = '.')
  
  # Visualization 
  plot.clustering.clean = ggplot(df[df$filtering == "in",], 
                                 aes(jitter(log.fluo1, factor = 0), 
                                     jitter(log.fluo2, factor = 0))) + 
    
    geom_point(aes(color = factor(clust)), size = .5) + 
    scale_color_manual(breaks = 1:nb, values = names.cluster$color.name, labels = names.cluster$name) + 
    labs(colour = "Fluorescence groups", x = paste('log(', fluo1,')'), y = paste('log(', fluo2,')'), 
         subtitle = ask.sub) + 
    scale_y_continuous(limits = c(0, 8)) +
    scale_x_continuous(limits = c(0, 8)) +
    coord_fixed() +
    theme_classic() + 
    theme(panel.background = element_rect(fill = "#D3D3D3"))
  
  print(plot.clustering.clean)
  
  # Saving data 
  write.csv(df.output, file = paste0(output.name,".csv"), row.names = F)
  
  write.csv(data.frame(df), file = paste0(output.name,"-COPAS-data-filtered.csv"), row.names = F)
  
  ggsave(filtering.plot, filename = paste0(output.name,"-filtering.png"), 
         height=15, width = 20, unit="cm")
  
  ggsave(plot.clustering, filename = paste0(output.name,"-clustering.png"), 
         height=15, width = 20, unit="cm")
  
  ggsave(plot.clustering.clean, filename = paste0(output.name,"-clustering-clean.png"), 
         height=15, width = 20, unit="cm")
  
  options(warn = 0)
  
  
}


# Trial on dummy data
COPAScluster(file.name = 'dummy.txt',
             output.name = 'dummy')
