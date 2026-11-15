
-- =====================================================
-- BANKING ANALYTICS - BIGQUERY
-- 10 BUSINESS ANALYTICAL QUERIES
-- Source: vw_bank_loan_google_sheets
-- =====================================================


-- Query 1: Approval Rate by Property Area

SELECT
    Property_Area,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS approved,
    SUM(CASE WHEN Loan_Status = 'N' THEN 1 ELSE 0 END) AS rejected,
    ROUND(
        SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS approval_rate_pct
FROM `banking-analytics-514808.banking_analytics.vw_bank_loan_google_sheets`
GROUP BY Property_Area
ORDER BY approval_rate_pct DESC;


-- Query 2: Approval Rate by Education

SELECT
    Education,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS approved,
    ROUND(
        SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS approval_rate_pct,
    ROUND(AVG(LoanAmount), 2) AS avg_loan_amount,
    ROUND(AVG(ApplicantIncome), 2) AS avg_income
FROM `banking-analytics-514808.banking_analytics.vw_bank_loan_google_sheets`
GROUP BY Education
ORDER BY approval_rate_pct DESC;


-- Query 3: Credit History Impact

SELECT
    Credit_History,
    Credit_Risk,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS approved,
    ROUND(
        SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS approval_rate_pct,
    ROUND(AVG(LoanAmount), 2) AS avg_loan_amount
FROM `banking-analytics-514808.banking_analytics.vw_bank_loan_google_sheets`
GROUP BY Credit_History, Credit_Risk
ORDER BY approval_rate_pct DESC;


-- Query 4: Income Group Analysis

SELECT
    Income_Group,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS approved,
    ROUND(
        SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS approval_rate_pct,
    ROUND(AVG(LoanAmount), 2) AS avg_loan_amount,
    ROUND(AVG(Total_Income), 2) AS avg_total_income
FROM `banking-analytics-514808.banking_analytics.vw_bank_loan_google_sheets`
GROUP BY Income_Group
ORDER BY avg_total_income DESC;


-- Query 5: Self Employed vs Salaried Analysis

SELECT
    Self_Employed,
    Gender,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS approved,
    ROUND(
        SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS approval_rate_pct,
    ROUND(AVG(ApplicantIncome), 2) AS avg_income,
    ROUND(AVG(LoanAmount), 2) AS avg_loan_amount
FROM `banking-analytics-514808.banking_analytics.vw_bank_loan_google_sheets`
GROUP BY Self_Employed, Gender
ORDER BY approval_rate_pct DESC;


-- Query 6: Loan Amount Distribution

SELECT
    Loan_Status_Label,
    COUNT(*) AS total,
    ROUND(AVG(LoanAmount), 2) AS avg_loan,
    MIN(LoanAmount) AS min_loan,
    MAX(LoanAmount) AS max_loan
FROM `banking-analytics-514808.banking_analytics.vw_bank_loan_google_sheets`
GROUP BY Loan_Status_Label;


-- Query 7: Risk Segmentation Using CTE

WITH risk_segments AS (
    SELECT
        Loan_ID,
        LoanAmount,
        Loan_Status,
        CASE
            WHEN Credit_History = 0 AND Total_Income < 3000
                THEN 'High Risk'
            WHEN Credit_History = 0 OR Total_Income < 3000
                THEN 'Medium Risk'
            ELSE 'Low Risk'
        END AS risk_segment
    FROM `banking-analytics-514808.banking_analytics.vw_bank_loan_google_sheets`
)

SELECT
    risk_segment,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS approved,
    SUM(CASE WHEN Loan_Status = 'N' THEN 1 ELSE 0 END) AS rejected,
    ROUND(
        SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS approval_rate_pct,
    ROUND(AVG(LoanAmount), 2) AS avg_loan_amount
FROM risk_segments
GROUP BY risk_segment
ORDER BY approval_rate_pct DESC;


-- Query 8: Ranking Applicants by Income
-- Window Function: RANK()

SELECT
    Loan_ID,
    Gender,
    Education,
    Property_Area,
    ApplicantIncome,
    LoanAmount,
    Loan_Status_Label,
    Credit_Risk,
    RANK() OVER (
        ORDER BY ApplicantIncome DESC
    ) AS income_rank
FROM `banking-analytics-514808.banking_analytics.vw_bank_loan_google_sheets`
ORDER BY income_rank
LIMIT 20;


-- Query 9: Dependents Impact on Approval

SELECT
    Dependents,
    Married,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS approved,
    ROUND(
        SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS approval_rate_pct,
    ROUND(AVG(LoanAmount), 2) AS avg_loan_amount,
    ROUND(AVG(Total_Income), 2) AS avg_total_income
FROM `banking-analytics-514808.banking_analytics.vw_bank_loan_google_sheets`
GROUP BY Dependents, Married
ORDER BY Dependents, Married;


-- Query 10: Create Final Analytical View for Power BI

CREATE OR REPLACE VIEW
`banking-analytics-514808.banking_analytics.vw_loan_summary_google_sheets` AS

SELECT
    Loan_ID,
    Gender,
    Married,
    Dependents,
    Education,
    Self_Employed,
    ApplicantIncome,
    CoapplicantIncome,
    LoanAmount,
    Loan_Amount_Term,
    Credit_History,
    Property_Area,
    Loan_Status,
    Total_Income,
    Income_Group,
    Loan_Status_Label,
    Credit_Risk,

    CASE
        WHEN Credit_History = 0 AND Total_Income < 3000
            THEN 'High Risk'
        WHEN Credit_History = 0 OR Total_Income < 3000
            THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS Risk_Segment,

    CASE
        WHEN LoanAmount < 100 THEN 'Small'
        WHEN LoanAmount < 200 THEN 'Medium'
        WHEN LoanAmount < 400 THEN 'Large'
        ELSE 'Very Large'
    END AS Loan_Size_Category

FROM `banking-analytics-514808.banking_analytics.vw_bank_loan_google_sheets`;
