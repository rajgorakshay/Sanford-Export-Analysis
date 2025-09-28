USE DATABASE sanford_export_analysis;

-- Initialise by truncating tables.

TRUNCATE TABLE SANFORD_EXPORT_ANALYSIS.PUBLIC.EXPORTS_BY_PRODUCT_MERGED;
TRUNCATE TABLE SANFORD_EXPORT_ANALYSIS.PUBLIC.DIM_SPECIES;
TRUNCATE TABLE SANFORD_EXPORT_ANALYSIS.PUBLIC.DIM_PRODUCT;
TRUNCATE TABLE SANFORD_EXPORT_ANALYSIS.PUBLIC.DIM_COUNTRY;
TRUNCATE TABLE SANFORD_EXPORT_ANALYSIS.PUBLIC.DIM_DATE;
TRUNCATE TABLE fact_exports;

-- Data Transformation - Merge data

INSERT INTO SANFORD_EXPORT_ANALYSIS.PUBLIC.EXPORTS_BY_PRODUCT_MERGED
SELECT *, 2023 as reporting_year from SANFORD_EXPORT_ANALYSIS.PUBLIC.EXPORTS_BY_PRODUCT_JUL_23
UNION ALL
SELECT *, 2024 as reporting_year from SANFORD_EXPORT_ANALYSIS.PUBLIC.EXPORTS_BY_PRODUCT_JUL_24
UNION ALL
SELECT *, 2025 as reporting_year from SANFORD_EXPORT_ANALYSIS.PUBLIC.EXPORTS_BY_PRODUCT_JUL_25;

-- Validate Merge
--SELECT * FROM SANFORD_EXPORT_ANALYSIS.PUBLIC.EXPORTS_BY_PRODUCT_MERGED

-- Data Transformation - Setup dim species from merged tables. 
INSERT INTO DIM_SPECIES (SPECIES_NAME)
SELECT DISTINCT species from exports_by_product_merged;

-- Data Transformation - Setup dim_product to merged table
INSERT INTO DIM_PRODUCT (product_name)
SELECT DISTINCT PRODUCT from exports_by_product_merged;

-- Data Transformation - Setup dim counry from merged table. 
INSERT INTO DIM_COUNTRY (country_name)
SELECT DISTINCT Country FROM exports_by_product_merged;

-- Data Transformation - Setup dim date from merged table. 
INSERT INTO DIM_DATE (Reporting_Year)
SELECT DISTINCT Reporting_Year FROM exports_by_product_merged;

-- Data Transformation - Setup fact table for reporting 
INSERT INTO fact_exports (species_id, product_id, country_id, date_id, volume, value)
SELECT 
    s.species_id,
    p.product_id,
    c.country_id,
    d.date_id,
    m.volume,
    m.value
FROM SANFORD_EXPORT_ANALYSIS.PUBLIC.EXPORTS_BY_PRODUCT_MERGED m
JOIN dim_species s 
    ON m.species = s.species_name
JOIN dim_product p 
    ON m.product = p.product_name
JOIN dim_country c 
    ON m.country = c.country_name
JOIN dim_date d 
    ON m.reporting_year = d.reporting_year;