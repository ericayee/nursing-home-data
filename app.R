#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(DT)
library(rsconnect)

# read in facilities data
data_facilities <- read.csv("data/healthcare_facility_locations.csv")
# rename data
colnames(data_facilities)[1] <- "FACID"

# alphabetize facility type and county options for select menus
fac_alpha <- sort(unique(as.character(data_facilities$FAC_FDR)))
county_alpha <- sort(unique(as.character(data_facilities$COUNTY_NAME)))

# read in facilities data dictionary
# data_dict <- read.csv("data/datadictionary_facilities_rev20200108.csv")
# colnames(data_dict)[1] <- "COL"
# data_dict_skinnier <- data_dict[c("COL", "DEFINITION")]

# set initial shown columns
init_cols <- c("FACID", "FACNAME", "FAC_FDR", "CAPACITY", "ADDRESS", "CITY", "ZIP", "FACADMIN", "CONTACT_EMAIL", "CONTACT_PHONE_NUMBER", "COUNTY_NAME")

# Define UI for application
ui <- fluidPage(

    # Application title
    titlePanel("Licensed and Certified Healthcare Facility Listing"),

    # data source
    p("data from ", tags$a(href="https://data.ca.gov/dataset/licensed-and-certified-healthcare-facility-listing", "California Department of Public Health")),
    
    # main table
    DT::dataTableOutput("mytable"),
    
    sidebarLayout(
        sidebarPanel(
            width = 3,
            # sidebar with checkboxes to choose columns to show
            checkboxGroupInput("show_vars",
                               "Columns to show:",
                               names(data_facilities),
                               selected = init_cols)
            
            # DT::dataTableOutput("dict_table")

            # lapply(1:40, function(i) {
            #     # p("hello")
            #     paste(data_dict_skinnier$COL[i], ": ", data_dict_skinnier$DEFINITION[i], sep = "\n")
            # 
            # })
            
        ),
        
        mainPanel(
            # create row for selectInputs
            fluidRow(
                column(4,
                       selectInput("FAC_FDR",
                                   "Facility Type",
                                   c("All",
                                     fac_alpha)
                                   # selected = "All",
                                   # multiple = TRUE
                       )
                ),
                column(4,
                       selectInput("COUNTY_NAME",
                                   "County",
                                   c("All",
                                     county_alpha)
                                   # selected = "All",
                                   # multiple = TRUE
                       )
                ),
            ),
            # Create a new row for the table.
            DT::dataTableOutput("table")
            
        )
        
    )
)

# Define server logic
server <- function(input, output) {
    
    # copy data to new df for filtering
    data_facilities2 = data_facilities[sample(nrow(data_facilities), 11856), ]
    
    # output$dict_table = DT::renderDataTable({
    #     data_dict_skinnier
    # })
    
    output$table = DT::renderDataTable({
        
        # filter by facility type
        if (input$FAC_FDR != "All") {
            data_facilities2 <- data_facilities2[data_facilities2$FAC_FDR == input$FAC_FDR,]
        }
        
        # filter by counties
        if (input$COUNTY_NAME != "All") {
            data_facilities2 <- data_facilities2[data_facilities2$COUNTY_NAME == input$COUNTY_NAME,]
        }
        
        # show only selected columns
        DT::datatable(
            data_facilities2[, input$show_vars, drop = FALSE],
            rownames = FALSE
            )
        
        # uncomment line below and comment out function above if not using checkboxes for columns
        # data_facilities
    })

}

# Run the application 
shinyApp(ui = ui, server = server)
