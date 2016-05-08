## Bank Account Visualizer
This project provides a series of scripts which automate steps needed to visualize data from bank-account transactions.

### State of the world
Below is a flow of the current project state.

     SCRIPTS TO STORE & PROCESS DATA
     +---------------------------------------------+
     |                                             |
     |           +------+                          |            HTML REPORT TO VISUALIZE DATA
     |           | Bank |                          |          +---------------------------------------------------------+
     |           +------+                          |          |                                                         |
     |               |                             |          |                                                         |
     |               |  download from Bank website |          |                                           CSV files in  |
     |               |                             |          |    report.html              Google Auth   AWS S3        |
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
     |               |  export_report_to_csv.rb    |          |       <------+                   |           |          |
     |               |                             |          |       |                          |           |          |
     |     +---------v-------------+               |          |       +                          +           +          |
     |     | Balance.csv           |               |          |                                                         |
     |     | Monthly-Breakdown.csv |               |          |                                              ^          |
     |     +-----------------------+               |          +----------------------------------------------|----------+
     |               |                             |                                                         |
     +---------------|-----------------------------+                                                         |
                     |                                                                                       |
                     |                currently a manual upload to S3 (to add S3 API)                        |
                     +---------------------------------------------------------------------------------------+

### Work still to do:
 * Add script to upload output .csv files to S3
 * Change the report workflow to become HTML<br>
 Currently, report.html needs to make calls to both GAPI and AWS-S3, so needs a server to run.<br>
 I want to change this to be serverless - current thoughts are AWS-API-Gateway + AWS-Lambda.