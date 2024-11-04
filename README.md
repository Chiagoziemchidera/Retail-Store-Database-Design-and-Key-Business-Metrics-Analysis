# Retail-Store-Database-Design-and-Key-Business-Metrics-Analysis
---
## Project Overview
BrightMart is a fictitious retail chain with stores across multiple regions, offering a wide selection of products including electronics, fashion, groceries, and home essentials. Although BrightMart has built a strong customer base, it identified a significant opportunity to leverage its rich transaction and customer data for more strategic decision-making. To unlock this potential, BrightMart embarked on a data analysis project aimed at transforming its raw sales data into actionable insights.

Through this project, BrightMart organized its data into a structured relational database, analyzed revenue trends, product profitability, customer demographics, and store performance. By understanding its top-selling products, high-performing store locations, and customer purchasing patterns, BrightMart is now equipped to optimize inventory management, tailor marketing efforts, and improve the customer experience. This data-driven approach positions BrightMart to enhance operational efficiency, drive profitability, and foster deeper customer loyalty across its expanding network.

### Project Workflow
1. **Database Creation**: Created a MySQL database to store the data.
2. **Data Loading and Cleaning**: Imported data from CSV, ensured date columns were formatted correctly, removed duplicates, and replaced empty cells with `NULL`.
3. **Data Normalization**: Normalized the data into multiple tables to improve data organization and minimize redundancy.
4.  **Data Model and ERD Diagram**: Designed a relational model to structure data and visualize relationships between entities. Created an ERD diagram to outline the tables, keys, and relationships.
5. **Querying and Analysis**: Used SQL queries to generate business insights.
6. **Data Visualization**: Loaded data from database into Power BI to visualized metrics and insights.

## Data Structure Overview

The database is designed to capture and manage key transactional data across orders, customers, stores, and products. The structure is normalized to ensure efficient data storage, reduce redundancy, and maintain data integrity.

* Original Dataset
An initial table, `SalesData`, was created with columns mirroring the structure of the CSV file.
`TransactionID`, `OrderNumber`, `LineItem`, `OrderDate`, `DeliveryDate`, `Quantity`, `CustomerID`, `CustomerGender`, `CustomerName`, `CustomerCity`, `CustomerStateCode`, `CustomerState`, `CustomerZip`, `CustomerCountry`, `CustomerContinent`, `CustomerDOB`, `StoreID`, `StoreCountry`, `StoreState`, `StoreSqMeters`, `StoreOpenDate`, `ProductID`, `ProductName`, `ProductBrand`, `ProductColor`, `ProductCost`, `ProductPrice`, `ProductCategoryID`, `ProductCategory`, `ProductSubcategoryID`, `ProductSubcategory`

* Normalized Structure

![ERD transaction](https://github.com/user-attachments/assets/15e227ac-b76a-41a7-b1c0-a5cac2fe39ac)

*The Entity-Relationship Diagram (ERD) illustrates the tables, fields, primary keys, and relationships within the database. This visual guide provides a high-level overview of the entire data model.*

### Relationships

The database has several key relationships to support detailed analytics and ensure consistency:

- **Customers ↔ Orders**: Each customer can have multiple orders, allowing for analysis of customer lifetime value, new customers and repeat purchases.
- **Stores ↔ Orders**: Orders are linked to stores to analyze store-level performance by region.
- **Products ↔ Orders**: Each order contains product details, which enables revenue analysis by product and category.
- **ProductCategories ↔ ProductSubcategories ↔ Products**: The categories and subcategories help categorize products, supporting profit margin analysis by category.
