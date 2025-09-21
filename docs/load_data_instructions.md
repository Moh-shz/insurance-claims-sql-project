# Load Data Instructions

This project includes a CSV file called **Insurance claims data.csv** that needs to be loaded into the staging table (`stage_claims_raw`).  
Follow the steps below to import the data into PostgreSQL using **pgAdmin 4**.

---

## 1. Create the Schema
1. In pgAdmin, right-click on your database (e.g., `insurance_analytics`) and open the **Query Tool**.  
2. Run the following command:

```sql
CREATE SCHEMA IF NOT EXISTS insurance;
```

---

## 2. Create the Staging Table
1. Open the **Query Tool**.  
2. Copy and execute the SQL code from [`schema.sql`](./sql/schema.sql).  
   - This will create the table `insurance.stage_claims_raw` with all columns matching the CSV file.

---

## 3. Import the CSV into PostgreSQL
1. In the left panel, right-click on `insurance.stage_claims_raw`.  
2. Select **Import/Export Data…**.  
3. Configure the options as follows:
   - **Import**: Selected  
   - **Filename**: Path to `Insurance claims data.csv` on your computer  
   - **Format**: CSV  
   - **Encoding**: UTF8  
   - **Header**: Yes  
   - **Delimiter**: `,`  
   - **Quote**: `"`  

4. Go to the **Columns** tab and make sure all CSV columns are mapped correctly.  
5. Click **OK** to load the data.

---

## 4. Verify the Data
Run the following query to check that the data was imported successfully:

```sql
SELECT * FROM insurance.stage_claims_raw LIMIT 10;
```

---

## 5. Populate the Base Tables
After the raw data is loaded into the staging table, run the script [`populate.sql`](./sql/populate.sql) to populate the main tables:

- `vehicles`  
- `policyholders`  

This script will insert the data from `stage_claims_raw` into the base tables.

---

## Once these steps are done, you can move on to executing the analytical queries in [`queries.sql`](./sql/queries.sql).
