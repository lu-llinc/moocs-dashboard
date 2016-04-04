library(shinydashboard)
library(googleVis)

# Server

function(input, output) { 
  # Source helper script
  source(paste0(getwd(), "/helpers.R"))
  # Get postgresql data as input
  psql_host <- reactive({
    input$psqlhostname
  }) 
  psql_user <- reactive({
    input$psqlusername
  }) 
  psql_pwd <- reactive({
    input$psqlpassword
  }) 
  psql_db <- reactive({
    input$psqldatabase
  }) 
  psql_port <- reactive({
    input$psqlport
  }) 
  
  # Dates on which users join ----
  
  usrJoin <- reactive({
    con <- psql(psql_host(), psql_port(), psql_user(), psql_pwd(), psql_db())
    # Get user join
    uJD <- userJoinData(con) # This function can be found in 'helpers.R'
    # Disconnect
    t <- dbDisconnect(con)
    return(uJD)
  })
  
  # Plot
  output$joinLine <- renderGvis({
    # data
    t <- usrJoin()
    names(t) <- c("date", "count")
    # Return chart
    gvisLineChart(t#,
                  #options=list(legend = "none",
                   #            series="[{targetAxisIndex: 0},
                    #           {targetAxisIndex:1}]",
                     #          vAxes="[{title:'Number of participants'}, {title:'Date'}]"
                  #)
         )
  })
  
  # GET COMPLETION DATA -----
  
  compData <- reactive({
    con <- psql(psql_host(), psql_port(), psql_user(), psql_pwd(), psql_db())
    # Get data
    compData <- passingGr(con)
    # Disconnect
    t <- dbDisconnect(con)
    # Return
    return(compData)
  })
  
  # Visuals completion data
  
  # Create value box (completion rate)
  output$compRate <- renderValueBox({
    # Data
    t <- compData()$passing_data
    # Numb 
    y <- t[t$course_passing_state_id != "Others",]
    # Num
    tnum <- round((sum(y$count) / compData()$total_users$count) * 100, digits=2)
    # Value box
    valueBox(
      format(paste0(tnum,"%"),format="d",big.mark=","), 
      "Overall Completion Rate", icon = icon("area-chart"), color = "green")
  })
  # Create value box (average grade)
  output$avgGr <- renderValueBox({
    # Data
    t <- compData()$course_grade_overall %>%
      filter(., course_passing_state_id != 0)
    # Value box
    valueBox(
      format(round(mean(t$course_grade_overall), digits = 2),format="d",big.mark=","), 
      "Average Grade (of completers)", icon = icon("area-chart"), color = "yellow")
  })
  # Create value box (completed this month)
  output$compTM <- renderValueBox({
    thisMonth <- format(Sys.Date(), "%B")
    thisYear <- format(Sys.Date(), "%Y")
    # Data
    t <- compData()$completed_time %>%
      mutate(., month = format(ts_conv, "%B")) %>%
      mutate(., year = format(ts_conv, "%Y")) %>%
      filter(., month == thisMonth & year == thisYear)
    # Value box
    valueBox(
      format(nrow(t),format="d",big.mark=","), 
      paste0("# Completers in ",thisMonth, " ", thisYear), 
      icon = icon("area-chart"), color = "orange")
  })
  # Pie chart (completers)
  output$barChartComp <- renderGvis({
    t <- compData()$passing_data
    # Plot
    gvisPieChart(t,
                 options = list(title="Overview of Completion Rates")
    )
  })
  # Histogram of Grade Distribution
  output$histGrades <- renderGvis({
    t <- compData()$course_grade_overall %>%
      filter(., course_passing_state_id != 0) %>%
      select(., course_grade_overall)
    # Plot
    gvisHistogram(t,
                  options = list(legend = "none",
                                 title="Distribution of Course Grades (for completers)")
    )
  })
  # Graph of when completed
  output$completersPM <- renderGvis({
    t <- compData()$completed_time %>%
      filter(., course_passing_state_id != 0) %>%
      mutate(., month = format(as.Date(ts_conv), "%B"),
             month_num = format(as.Date(ts_conv), "%m"),
             year = format(as.Date(ts_conv), "%Y")) %>%
      group_by(., month_num, month, year) %>%
      summarize(., count = n()) %>%
      ungroup(.) %>%
      mutate(., month_num = as.numeric(month_num)) %>%
      mutate(., monthyear = paste0(month, " ", year)) %>%
      arrange(., year, month_num) %>%
      select(., monthyear, count)
    # Plot
    gvisColumnChart(t, "monthyear", "count",
                    options = list(legend = "none",
                                   title="Number of Completers, by Month"))
    
  })
  
  # GET GEOGRAPHICAL DATA ----
  
  geoData <- reactive({
    con <- psql(psql_host(), psql_port(), psql_user(), psql_pwd(), psql_db())
    # Get map data
    geoData <- mapData(con)
    # Disconnect
    t <- dbDisconnect(con)
    return(geoData)
  })
  
  # Create map
  output$geoMap <- renderGvis({
    # Return chart
    ch <- gvisGeoChart(geoData(), "country_name", "n",
                       options = list(title="Number of Participants by Country",
                                      legend = 'none',
                                      width = "automatic",
                                      height = "automatic"))
    ch
  })
  # Create value box (number of countries)
  output$numberC <- renderValueBox({
    valueBox(
      format(dim(geoData())[1],format="d",big.mark=","), 
      "Number of Countries", icon = icon("area-chart"), color = "green")
  })
  # Create value box (most frequent country)
  output$mostFreqC <- renderValueBox({
    valueBox(
      format(geoData()[geoData()$n == max(geoData()$n),]$country_name,format="d",big.mark=","), 
      "Most frequent Country", icon = icon("area-chart"), color = "blue")
  })
  # Create value box (total number of learners)
  output$numberLearn <- renderValueBox({
    valueBox(
      format(sum(geoData()$n),format="d",big.mark=","), 
      "Number of Participants", icon = icon("area-chart"), color = "red")
  })
  
  # VIDEO COMPLETION DATA (UNFINISHED) ----
  
  vidData <- reactive({
    connection <- psql(psql_host(), psql_port(), psql_user(), psql_pwd(), psql_db())
    # Get video data
    vidData <- videoCompletion(connection)
    # Disconnect
    t <- dbDisconnect(connection)
    return(vidData)
  })
  # Create visual
  output$vidBar <- renderGvis({
    # Return chart
    plot(gvisColumnChart(vidData, xvar = "course_item_name", yvar = c("count", "completed")))
  })
  
  # Run queries ----
  
  # Create data table when user clicks "execute"
  tab <- eventReactive(input$execute, {
      # Connect
      con <- psql(psql_host(), psql_port(), psql_user(), psql_pwd(), psql_db())
      # Query
      # If query == "show tables", then call dbListables
      if(tolower(input$query) == "show tables;") {
        res <- dbListTables(con) 
        tab <- data.frame(
          "Number" = 1:length(res),
          "Table_name" = res,
          stringsAsFactors = F
        )
      } else {
        res <- dbSendQuery(con, input$query)
        # Fetch
        tab <- fetch(res, n=-1) 
        # Clear result
        cr <- dbClearResult(res)
      }
      #data <- dbReadTable(con, name = input$psqltableInput)
      dbDisconnect(con)
      # Return
      return(tab)
  })
  # Render into data table
  output$psqltable <- renderDataTable(tab())
  # Download data
  output$downloadData <- downloadHandler(
    filename = paste0("download", ".", input$dataset),
    content = function(file) {
      write.table(tab(), file, row.names = F, sep = ifelse(input$dataset == "CSV",
                                                           ",",
                                                           "\t"))
    }
  )
  
}

# RUN ----

#shinyApp(ui, server)