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