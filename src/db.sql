/* ---------------------------------
Postgres database initialisation DDL
--------------------------------- */

-----------------------------------
-- Databases
-----------------------------------
CREATE DATABASE open_banking;

-----------------------------------
-- Schemas
-----------------------------------
CREATE SCHEMA raw;

-----------------------------------
-- Tables
-----------------------------------
CREATE TABLE raw.products (jsondata json);

-----------------------------------
-- Views
-----------------------------------
CREATE OR REPLACE VIEW public.vw_products as
	select
		  jsondata -> 'data' ->> 'productId' as productId
		, jsondata -> 'data' ->> 'lastUpdated' as lastUpdated
		, jsondata -> 'data' ->> 'productCategory' as productCategory
		, jsondata -> 'data' ->> 'name' as name
		, jsondata -> 'data' ->> 'description' as description
		, jsondata -> 'data' ->> 'brand' as brand
		, jsondata -> 'data' ->> 'brandName' as brandName
		, jsondata -> 'data' ->> 'isTailored' as isTailored
		, jsondata -> 'data' -> 'additionalInformation' ->> 'overviewUri' as overviewUri
		, jsondata -> 'data' -> 'additionalInformation' ->> 'termsUri' as termsUri
		, jsondata -> 'data' -> 'additionalInformation' ->> 'eligibilityUri' as eligibilityUri
		, jsondata -> 'data' -> 'additionalInformation' ->> 'feesAndPricingUri' as feesAndPricingUri
	from 
		raw.products
;

CREATE OR REPLACE VIEW public.vw_product_features as
	-- https://consumerdatastandardsaustralia.github.io/standards/#tocSbankingproductfeature
	select
		  jsondata -> 'data' ->> 'productId' as productId
		, jsondata -> 'data' ->> 'lastUpdated' as lastUpdated
		, f ->> 'featureType' as featureType
		, f ->> 'additionalValue' as additionalValue
		, f ->> 'additionalInfo' as additionalInfo
		, f ->> 'additionalInfoUri' as additionalInfoUri
	from 
		raw.products
		, json_array_elements(jsondata -> 'data' -> 'features') as f
;

CREATE OR REPLACE VIEW public.vw_product_fees as
	-- https://consumerdatastandardsaustralia.github.io/standards/#tocSbankingproductfee
	select
		  jsondata -> 'data' ->> 'productId' as productId
		, jsondata -> 'data' ->> 'lastUpdated' as lastUpdated
		, f ->> 'name' as feeName
		, f ->> 'feeType' as feeType
		, f ->> 'amount' as amount
		, f ->> 'balanceRate' as balanceRate
		, f ->> 'transactionRate' as transactionRate
		, f ->> 'accruedRate' as accruedRate
		, f ->> 'accrualFrequency' as accrualFrequency
		, f ->> 'currency' as currency
		, f ->> 'additionalValue' as additionalValue
		, f ->> 'additionalInfo' as additionalInfo
		, f ->> 'additionalInfoUri' as additionalInfoUri
	from 
		raw.products
		, json_array_elements(jsondata -> 'data' -> 'fees') as f
;

CREATE OR REPLACE VIEW public.vw_product_deposit_rates as
	-- https://consumerdatastandardsaustralia.github.io/standards/#tocSbankingproductdepositrate
	select
		  jsondata -> 'data' ->> 'productId' as productId
		, jsondata -> 'data' ->> 'lastUpdated' as lastUpdated
		, dr ->> 'depositRateType' as depositRateType
		, dr ->> 'rate' as rate
		, dr ->> 'calculationFrequency' as calculationFrequency
		, dr ->> 'additionalValue' as additionalValue
		, dr ->> 'additionalInfo' as additionalInfo
	from 
		raw.products
		, json_array_elements(jsondata -> 'data' -> 'depositRates') as dr
;

