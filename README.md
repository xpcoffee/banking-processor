## Bank Account Visualizer
This project provides a collection of tools for storing, processing and visualizing transaction data from a bank-account.<br>
The output is given on a webpage (report.html), which draws a line graph of balance over time and a stacked column graph showing the breakdown of monthly expenses.

### State of the world
Below is a flow of the current project state.

     SCRIPTS TO STORE & PROCESS DATA                            HTML REPORT TO VISUALIZE DATA

            +---------------+
            | Bank  Website |
            +---------------+                                 +---------------------------------------------------------+
                     |                                        |                                                         |
                     |  download from Bank website            |                                                         |
                     |                                        |                                           CSV files in  |
     +---------------|-- execute-processor.rb -----+          |    report.html              Google Auth   AWS S3        |
     |          +----v-----+                       |          |       +                          +           +          |
     |          | CSV file |                       |          |       |   authenticate user      |           |          |
     |          +----------+                       |          |       +-------------------------->           |          |
     |               |                             |          |       |                          |           |          |
     |               |  insert_from_file.rb        |          |       |                          |           |          |
     |               |                             |          |       |   get data to graph      |           |          |
     |          +----v-----+                       |          |       +-------------------------------------->          |
     |          | MySQL DB |                       |          |       |                          |           |          |
     |          +----------+                       |          |       +------+                   |           |          |
     |               |                             |          |       |      | draw graphs       |           |          |
     |               |  export_report.rb           |          |       <------+                   |           |          |
     |               |                             |          |       |                          |           |          |
     |     +---------v-------------+               |          |       +                          +           +          |
     |     | Balance.csv           |               |          |                                                         |
     |     | Monthly-Breakdown.csv |               |          |                                              ^          |
     |     +-----------------------+               |          +----------------------------------------------|----------+
     |               |                             |                                                         |
     +---------------|-----------------------------+                                                         |
                     |                                                                                       |
                     |                export_report.rb also uploads csv files to S3                          |
                     +---------------------------------------------------------------------------------------+

### Work still to do:
 * Change the report workflow to become serverless<br>
 Currently, report.html needs to make calls to both GAPI and AWS-S3, so needs a server to run.<br>
 I want to change this to be serverless - current thoughts are AWS-API-Gateway + AWS-Lambda.
 * Get processor to get new data from email, rather than from the manually downloaded file
