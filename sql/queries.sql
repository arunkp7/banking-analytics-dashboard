-- ─────────────────────────────────────────
-- Banking_Ananlytics — SQL Queries
-- Database: banking_analytics_db
-- ─────────────────────────────────────────

-- Query 1: Approval Rate by Property Area
SELECT
    property_area,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END) AS approved,
    SUM(CASE WHEN loan_status = 'N' THEN 1 ELSE 0 END) AS rejected,
    ROUND(SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2) AS approval_rate_pct
FROM bank_loans
GROUP BY property_area
ORDER BY approval_rate_pct DESC;

-- Query 2: Approval Rate by Education
SELECT
    education,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END) AS approved,
    ROUND(SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2) AS approval_rate_pct,
    ROUND(AVG(loan_amount), 2) AS avg_loan_amount,
    ROUND(AVG(applicant_income), 2) AS avg_income
FROM bank_loans
GROUP BY education
ORDER BY approval_rate_pct DESC;

-- Query 3: Credit History Impact
SELECT
    credit_history,
    credit_risk,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END) AS approved,
    ROUND(SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2) AS approval_rate_pct,
    ROUND(AVG(loan_amount), 2) AS avg_loan_amount
FROM bank_loans
GROUP BY credit_history, credit_risk
ORDER BY approval_rate_pct DESC;

-- Query 4: Income Group Analysis (CASE + GROUP BY)
SELECT
    income_group,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END) AS approved,
    ROUND(SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2) AS approval_rate_pct,
    ROUND(AVG(loan_amount), 2) AS avg_loan_amount,
    ROUND(AVG(total_income), 2) AS avg_total_income
FROM bank_loans
GROUP BY income_group
ORDER BY avg_total_income DESC;

-- Query 5: Self Employed vs Salaried Analysis
SELECT
    self_employed,
    gender,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END) AS approved,
    ROUND(SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2) AS approval_rate_pct,
    ROUND(AVG(applicant_income), 2) AS avg_income,
    ROUND(AVG(loan_amount), 2) AS avg_loan_amount
FROM bank_loans
GROUP BY self_employed, gender
ORDER BY approval_rate_pct DESC;

-- Query 6: Loan Amount Distribution (Window Function)
SELECT
    loan_status_label,
    COUNT(*) AS total,
    ROUND(AVG(loan_amount), 2) AS avg_loan,
    ROUND(MIN(loan_amount), 2) AS min_loan,
    ROUND(MAX(loan_amount), 2) AS max_loan,
    ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP
          (ORDER BY loan_amount)::NUMERIC, 2) AS q1,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP
          (ORDER BY loan_amount)::NUMERIC, 2) AS median_loan,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP
          (ORDER BY loan_amount)::NUMERIC, 2) AS q3
FROM bank_loans
GROUP BY loan_status_label;

-- Query 7: Risk Segmentation using CTE
WITH risk_segments AS (
    SELECT
        loan_id,
        gender,
        education,
        property_area,
        applicant_income,
        loan_amount,
        credit_history,
        loan_status,
        CASE
            WHEN credit_history = 0
             AND total_income < 3000  THEN 'High Risk'
            WHEN credit_history = 0
             OR  total_income < 3000  THEN 'Medium Risk'
            ELSE 'Low Risk'
        END AS risk_segment
    FROM bank_loans
)
SELECT
    risk_segment,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END) AS approved,
    SUM(CASE WHEN loan_status = 'N' THEN 1 ELSE 0 END) AS rejected,
    ROUND(SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2) AS approval_rate_pct,
    ROUND(AVG(loan_amount), 2) AS avg_loan_amount
FROM risk_segments
GROUP BY risk_segment
ORDER BY approval_rate_pct DESC;

-- Query 8: Ranking Applicants by Income (Window Function)
SELECT
    loan_id,
    gender,
    education,
    property_area,
    applicant_income,
    loan_amount,
    loan_status_label,
    credit_risk,
    RANK() OVER(ORDER BY applicant_income DESC) AS income_rank,
    ROUND(AVG(applicant_income) OVER(PARTITION BY property_area), 2) AS avg_area_income,
    ROUND(AVG(loan_amount) OVER(PARTITION BY property_area), 2) AS avg_area_loan
FROM bank_loans
ORDER BY income_rank
LIMIT 20;

-- Query 9: Dependents Impact on Approval
SELECT
    dependents,
    married,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END) AS approved,
    ROUND(SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2) AS approval_rate_pct,
    ROUND(AVG(loan_amount), 2) AS avg_loan_amount,
    ROUND(AVG(total_income), 2) AS avg_total_income
FROM bank_loans
GROUP BY dependents, married
ORDER BY dependents, married;

-- Query 10: Create View for Power BI
CREATE OR REPLACE VIEW vw_loan_summary AS
SELECT
    loan_id,
    gender,
    married,
    dependents,
    education,
    self_employed,
    applicant_income,
    coapplicant_income,
    loan_amount,
    loan_amount_term,
    credit_history,
    property_area,
    loan_status,
    total_income,
    income_group,
    loan_status_label,
    credit_risk,
    CASE
        WHEN credit_history = 0
         AND total_income < 3000  THEN 'High Risk'
        WHEN credit_history = 0
         OR  total_income < 3000  THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_segment,
    CASE
        WHEN loan_amount < 100   THEN 'Small'
        WHEN loan_amount < 200   THEN 'Medium'
        WHEN loan_amount < 400   THEN 'Large'
        ELSE 'Very Large'
    END AS loan_size_category
FROM bank_loans;