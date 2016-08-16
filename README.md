## Bank Account Visualizer
This project provides a collection of tools for processing and storing transaction data from a bank-account.<br>
This data is inserted into 2 AWS DynamoDB tables.

In a separate project (currently work-in-progress), these tables are queried by a reporting website in order to generate charts.

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
