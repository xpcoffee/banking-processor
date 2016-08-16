## Bank Account Visualizer
This project provides a collection of tools for storing, processing and visualizing transaction data from a bank-account.<br>
The output is given on a webpage (report.html), which draws a line graph of balance over time and a stacked column graph showing the breakdown of monthly expenses.

### State of the world
Below is a flow of the current project state.

        BANKING PROCESSOR                                       REPORT WEBSITE
                                               +
                                               |
        +--------------+                       |
        | Bank website |                       |
        +------+-------+                       |
            |                                  |
            |Download                          |
            |                                  |
            |                                  |
            v                                  +
         +--+--+
         | CSV |                            AWS DynamoDB
         +--+--+                      +--------------------+
            |                         +                    +            +----------------------+
            |                            +--------------+   query       |                      |
            |                     +------> Transactions <----------------+ Spending Breakdown  |
            |execute_processor.rb |      +--------------+               |  Plot                |
            |                     |                                     |                      |
            +---------------------+      +---------+       query        |                      |
                                  +------> Balance <---------------------+ Balance Over Time   |
                                         +---------+                    |  Plot                |
                                                                        |                      |
                                               +                        +----------------------+
                                               |
                                               |
                                               +



### Work still to do:
 * Get processor to get new data from email, rather than from the manually downloaded file
