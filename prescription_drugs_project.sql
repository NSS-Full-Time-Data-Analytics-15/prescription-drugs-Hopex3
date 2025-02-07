--Duplication in the drugs table
SELECT COUNT (drug_name)
FROM drug;
--6850 
SELECT COUNT (DISTINCT drug_name)
FROM drug;
--3253
--1a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT DISTINCT npi,total_claim_count
FROM prescription
ORDER BY total_claim_count DESC
LIMIT 1;
--ANSWER: prescriber 1912011792 had the highest total of claims with 4,538 claims

--1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
SELECT p2.nppes_provider_first_name,p2.nppes_provider_last_org_name,p2.specialty_description,p1.total_claim_count
FROM prescription AS p1
LEFT JOIN prescriber AS p2
USING(npi)
ORDER BY total_claim_count DESC
LIMIT 2;
--ANSWER: DAVID COFFEY Family Practice with 4538 claims 

--2a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT p2.specialty_description, SUM (p1.total_claim_count) AS total_claim
FROM prescription AS p1
INNER JOIN prescriber AS p2
USING (npi)
GROUP BY p2.specialty_description
ORDER BY total_claim  DESC;
--Family Practice has the most total_claim_count with 9752347 claims

--2b.Which specialty had the most total number of claims for opioids?
SELECT p2.specialty_description, COUNT(d.opioid_drug_flag) AS opioid_total_claim
FROM prescription AS p1
INNER JOIN prescriber AS p2
USING (npi)
INNER JOIN drug AS d
USING (drug_name)
WHERE opioid_drug_flag = 'Y'
GROUP BY p2.specialty_description
ORDER BY opioid_total_claim DESC;
--Nurse Practitioner had the most opioid claims with 9551 opioid claims

--3a.  Which drug (generic_name) had the highest total drug cost?
SELECT d.generic_name,SUM (p1.total_drug_cost) AS generic_drug_cost
FROM prescription AS p1
LEFT JOIN drug AS d
USING (drug_name)
GROUP BY d.generic_name
ORDER BY generic_drug_cost DESC;
--INSULIN GLARGINE, HUM.REC.ANLOG with a drug cost of $104,264,066.35

--4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/
SELECT drug_name, 
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
     WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
ELSE 'neither'
END AS drug_type
FROM drug;

--4b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT  
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
     WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
ELSE 'neither'
END AS drug_type ,  SUM(p.total_drug_cost)::money AS total_cost
FROM drug AS d1
INNER JOIN prescription AS p
ON d1.drug_name=p.drug_name
GROUP BY drug_type;

--5a.  How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
SELECT fc.state, COUNT (c1.cbsa)
FROM cbsa as c1
LEFT JOIN fips_county AS fc
USING (fipscounty)
WHERE fc.state = 'TN'
GROUP BY fc.state;

--42 CBSAs in TN

--5b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
SELECT c1.cbsaname, SUM(p3.population) AS pop
FROM cbsa as c1
LEFT JOIN population AS p3
USING (fipscounty)
WHERE population IS NOT NULL 
GROUP BY c1.cbsaname
ORDER BY pop DESC;
--ANSWER: Largest: Nashville-Davidson-Murfreesboro-Franklin,TN with a combined population of 1,830,410 
SELECT c1.cbsaname, SUM(p3.population) AS pop
FROM cbsa as c1
LEFT JOIN population AS p3
USING (fipscounty)
WHERE population IS NOT NULL 
GROUP BY c1.cbsaname
ORDER BY pop;
--Smallest: Morristown with a combined population of 116,352

--5c.  What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
SELECT county, population 
FROM fips_county
LEFT JOIN population 
USING (fipscounty)
WHERE fipscounty NOT IN 
(SELECT fipscounty
FROM cbsa)
ORDER BY population DESC NULLS LAST;
--ANSWER: Sevier with 95,523
SELECT *
FROM cbsa;

--6a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count
SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >=3000
ORDER BY total_claim_count DESC;

--6b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT drug_name, total_claim_count,opioid_drug_flag
FROM prescription
LEFT JOIN drug 
USING (drug_name)
WHERE total_claim_count >=3000
ORDER BY opioid_drug_flag , drug_name;

--6c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT drug_name, total_claim_count,opioid_drug_flag,nppes_provider_last_org_name, nppes_provider_first_name
FROM prescription
LEFT JOIN drug 
USING (drug_name)
WHERE total_claim_count >=3000
ORDER BY opioid_drug_flag , drug_name;

SELECT *
FROM prescription 
INNER JOIN prescriber
USING (npi);

--7a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT drug_name
FROM prescription;