import pandas as pd
from sqlalchemy import create_engine, text

PASSWORD = "postgres123"

engine = create_engine(
    f'postgresql://postgres:{PASSWORD}@localhost:5432/banking_analytics_db'
)

df = pd.read_csv(r'C:\Users\ARUN\Desktop\banking-analytics\data\bank_loan_cleaned.csv')

# Clean column names
df.columns = df.columns.str.lower().str.replace(' ', '_')

# Rename columns to match SQL table
df = df.rename(columns={
    'loan_id':             'loan_id',
    'gender':              'gender',
    'married':             'married',
    'dependents':          'dependents',
    'education':           'education',
    'self_employed':       'self_employed',
    'applicantincome':     'applicant_income',
    'coapplicantincome':   'coapplicant_income',
    'loanamount':          'loan_amount',
    'loan_amount_term':    'loan_amount_term',
    'credit_history':      'credit_history',
    'property_area':       'property_area',
    'loan_status':         'loan_status',
    'total_income':        'total_income',
    'income_group':        'income_group',
    'loan_status_label':   'loan_status_label',
    'credit_risk':         'credit_risk',
})

print(f"Loaded {len(df)} rows and {len(df.columns)} columns")
print(f"Columns: {list(df.columns)}")

with engine.connect() as conn:
    conn.execute(text("TRUNCATE TABLE bank_loans CASCADE"))
    conn.commit()

df.to_sql('bank_loans', engine, if_exists='append', index=False)
print(f"\n✓ Successfully loaded {len(df)} rows into bank_loans!")