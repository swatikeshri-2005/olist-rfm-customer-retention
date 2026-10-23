# olist-rfm-customer-retention
# Olist E-commerce RFM & Customer Retention Analysis

A portfolio project exploring customer purchasing behavior in the Brazilian Olist e-commerce dataset using Python, Pandas, DuckDB SQL, exploratory data analysis (EDA), RFM segmentation, and repeat-purchase analysis.

## Objectives
- Inspect data quality, missing values, duplicates, and order statuses.
- Explore orders over time and order-value patterns.
- Build a customer-level dataset using the underlying customer identifier.
- Calculate Recency, Frequency, and Monetary (RFM) metrics.
- Segment customers using transparent, quantile-based RFM scores.
- Analyze repeat purchase behavior and monthly customer cohorts.

## Tech stack
- Python
- Pandas and NumPy
- DuckDB SQL
- Matplotlib and Seaborn
- Google Colab / Jupyter Notebook

## Dataset
Download the **Brazilian E-Commerce Public Dataset by Olist** from:
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

Upload the downloaded dataset ZIP in Google Colab when prompted. Raw data is intentionally not included in this repository.

## How to run in Google Colab
1. Open `Olist_RFM_Customer_Retention.ipynb` in Google Colab.
2. Run the cells from top to bottom.
3. Upload the Olist ZIP when prompted, or place the CSV files in the Colab runtime.
4. Review the generated tables and charts.
5. Download `outputs/charts` from the Colab runtime if you want to commit selected charts to GitHub.

## Files
- `Olist_RFM_Customer_Retention.ipynb` — end-to-end analysis notebook.
- `sql/rfm_analysis.sql` — customer-level RFM calculation and segmentation.
- `sql/retention_analysis.sql` — repeat-purchase summary and cohort retention.
- `requirements.txt` — Python dependencies.
- `outputs/charts/` — destination for generated visualizations.

## Definitions and assumptions
- Only orders with `order_status = 'delivered'` are included in the main RFM analysis.
- `customer_unique_id` is used to identify the underlying customer across order-level customer records.
- Monetary value is the sum of item prices (`order_items.price`) per delivered order; freight is excluded from Monetary.
- Frequency is the number of distinct delivered orders per customer.
- Recency is measured in days between the analysis reference date and a customer's most recent delivered order.
- The reference date is one day after the latest purchase timestamp in the dataset. Dataset time coverage and its end boundary should be considered when interpreting results.
- Cohort retention is based on each customer's first observed delivered-order month. The final months may be incomplete.

## Results
Run the notebook before adding conclusions. Record only findings produced by your own run, including the dataset scope and any limitations.

## Responsible repository hygiene
Do not commit raw datasets, Kaggle credentials, API tokens, or other private information. Check notebook outputs before publishing.
