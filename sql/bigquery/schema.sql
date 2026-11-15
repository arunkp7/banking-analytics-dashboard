
-- =====================================================
-- BANKING ANALYTICS - BIGQUERY
-- TABLE AND VIEW DEFINITIONS
-- =====================================================

-- 1. Create the cleaned banking dataset table
-- IF NOT EXISTS preserves the table already uploaded.

CREATE TABLE IF NOT EXISTS
`banking-analytics-514808.banking_analytics.bank_loan_google_sheets`
(
    Loan_ID STRING,
    Gender STRING,
    Married BOOL,
    Dependents STRING,
    Education STRING,
    Self_Employed BOOL,
    ApplicantIncome INT64,
    CoapplicantIncome FLOAT64,
    LoanAmount INT64,
    Loan_Amount_Term INT64,
    Credit_History INT64,
    Property_Area STRING,
    Loan_Status BOOL,
    Total_Income FLOAT64,
    Income_Group STRING,
    Loan_Status_Label STRING,
    Credit_Risk STRING
);

-- 2. Create a readable analytical view

CREATE OR REPLACE VIEW
`banking-analytics-514808.banking_analytics.vw_bank_loan_google_sheets` AS

SELECT
    Loan_ID,
    Gender,

    CASE
        WHEN Married IS TRUE THEN 'Yes'
        WHEN Married IS FALSE THEN 'No'
        ELSE NULL
    END AS Married,

    Dependents,
    Education,

    CASE
        WHEN Self_Employed IS TRUE THEN 'Yes'
        WHEN Self_Employed IS FALSE THEN 'No'
        ELSE NULL
    END AS Self_Employed,

    ApplicantIncome,
    CoapplicantIncome,
    LoanAmount,
    Loan_Amount_Term,
    Credit_History,
    Property_Area,

    CASE
        WHEN Loan_Status IS TRUE THEN 'Y'
        WHEN Loan_Status IS FALSE THEN 'N'
        ELSE NULL
    END AS Loan_Status,

    Total_Income,
    Income_Group,
    Loan_Status_Label,
    Credit_Risk

FROM
    `banking-analytics-514808.banking_analytics.bank_loan_google_sheets`;
