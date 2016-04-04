# UI

# Test script

# Testing shiny dashboard

library(shiny)
library(shinydashboard)

# Load json file with defaults
postgres_defaults <- RJSONIO::fromJSON(content = "postgres_defaults.json")

# HEADER ----

header <- dashboardHeader(title = "Shiny MOOCs")

# SIDEBAR ----

sidebar <- dashboardSidebar(
  # Menu pages
  sidebarMenu(
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
    menuItem("Geography", tabName = "geography", icon = icon("map")),
    menuItem("Forum", tabName = "forum", icon = icon("users")),
    menuItem("Video Lectures", tabName = "vidlecs", icon = icon("youtube-play")),
    menuItem("Quiz results", tabName = "quizres", icon = icon("calculator")),
    menuItem("Query", tabName = "query", icon = icon("database")),
    menuItem("Settings", tabName = "settings", icon = icon("exchange")),
    menuItem("Website", href = "http://campusdenhaag.leiden.edu/centre4innovation/", icon = icon("feed")),
    menuItem("Report Issue", href = "https://github.com/LU-C4i/moocs-dashboard/issues", icon = icon("github")),
    menuItem("Contact us!", href = "mailto:j.h.ginn@fgga.leidenuniv.nl", icon = icon("envelope"))
  )
)

# BODY ----

body <- dashboardBody(
  # For each tab, create content
  tabItems(
    # Dashboard
    tabItem(tabName = "dashboard",
            # Title
            titlePanel("Dashboard"),
            # Value boxes
            fluidRow(
              valueBoxOutput("compRate"),
              valueBoxOutput("compTM"),
              valueBoxOutput("avgGr")
            ),
            
            ### Sign-up dates & completion rates
            
            fluidRow(
              # Grade distribution
              column(width = 6,
                     box(title="Grade Distribution",status="primary",solidHeader = TRUE,
                         htmlOutput("histGrades"), width=12, height = NULL, background = "blue")
              ),
              # Completion rates
              column(width = 6,
                     box(title="Completion Rates",status="primary",solidHeader = TRUE,
                         htmlOutput("barChartComp"), width = 12, height = NULL, background = "blue")
              )
            ),
            
            ### Completers per month & grade distribution
            
            fluidRow(
              # Completers per month
              column(width = 6,
                     box(title="Completers per Month",status="primary",solidHeader = TRUE,
                         htmlOutput("completersPM"), width = 12, height = NULL, background = "blue")
              ),
              # Sign-ups
              column(width = 6,
                     box(title="Sign-up dates of MOOC participants over time",status="primary",
                         solidHeader = TRUE,
                         htmlOutput("joinLine"), width = 12, height = NULL, background = "blue")
              )
            )
    ),
    
    # Forum
    tabItem(tabName = "forum",
            titlePanel("Forum Indicators")),
    
    # Geography
    tabItem(tabName = "geography",
            titlePanel("Geographical Indicators"),
            fluidRow(
              valueBoxOutput("numberLearn"),
              valueBoxOutput("numberC"),
              valueBoxOutput("mostFreqC")
            ),
            column(width = 12, offset = 2, 
                   box(title="Number of participants per country",status="primary",solidHeader = TRUE,
                       htmlOutput("geoMap"), width = 8, background = "blue"))
    ),
    
    # Query Editor
    tabItem(tabName = "query",
            titlePanel("Query editor"),
            # Create a new Row in the UI for textInput
            fluidRow(
              # Custom CSS to create multi-line text input field
              tags$style(type="text/css", "textarea {width:40%}"),
              tags$textarea(id = 'query', class = "span5", placeholder = 'SHOW TABLES;', rows = 6, ""),
              # Execute button
              actionButton("execute", "Execute"),
              # Download data button
              sidebarPanel(
                selectInput("dataset", "Export data", 
                            choices = c("CSV", "TAB")),
                downloadButton('downloadData', 'Download')
              ),
              # Output
              dataTableOutput(outputId="psqltable")
              #verbatimTextOutput("output_text"),
              # Create a new row for the table.
              #fluidRow(
               # dataTableOutput(outputId="psqltable")
                #verbatimTextOutput("psqltable")
              #)
            )
    ),
    
    ### Settings ----
    tabItem(tabName = "settings",
            h3("PostgreSQL settings"),
            textInput(inputId="psqlhostname", label="Hostname", value = postgres_defaults$hostname),
            textInput(inputId="psqlport", label="Port", value = postgres_defaults$port),
            textInput(inputId="psqlusername", label="User", value = postgres_defaults$user),
            textInput(inputId="psqlpassword", label="Password", value = postgres_defaults$password),
            textInput(inputId="psqldatabase", label="Database", value = postgres_defaults$database))
    
  )
)

# USER INTERFACE -----

dashboardPage(header,sidebar,body,
                    skin = "blue")