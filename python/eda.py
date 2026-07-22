import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import warnings
import os
warnings.filterwarnings('ignore')

df = pd.read_csv(r'C:\Users\ARUN\Desktop\banking-analytics\data\bank_loan_cleaned.csv')
df.columns = df.columns.str.lower().str.replace(' ', '_')

os.makedirs('outputs', exist_ok=True)

print("=== BASIC INFO ===")
print(f"Shape: {df.shape}")
print(f"\nLoan Status Distribution:\n{df['loan_status'].value_counts()}")
print(f"Missing Values: {df.isnull().sum().sum()}")

sns.set_theme(style='whitegrid', palette='muted')
COLORS = {'Y': '#2ecc71', 'N': '#e74c3c'}
COLORS2 = {'Approved': '#2ecc71', 'Rejected': '#e74c3c'}

# ─────────────────────────────────────────
# PLOT 1 — Loan Status Overview
# ─────────────────────────────────────────
fig, axes = plt.subplots(1, 2, figsize=(12, 5))
fig.suptitle('Loan Approval Overview', fontsize=16, fontweight='bold')

counts = df['loan_status'].value_counts()
axes[0].pie(counts, labels=['Approved','Rejected'], autopct='%1.1f%%',
            colors=['#2ecc71','#e74c3c'], startangle=90)
axes[0].set_title('Approval Split')

sns.countplot(data=df, x='loan_status', palette=COLORS, ax=axes[1])
axes[1].set_title('Approval Count')
axes[1].set_xlabel('Loan Status (Y=Approved, N=Rejected)')
for p in axes[1].patches:
    axes[1].annotate(f'{int(p.get_height())}',
                     (p.get_x()+p.get_width()/2, p.get_height()),
                     ha='center', va='bottom', fontweight='bold')
plt.tight_layout()
plt.savefig('outputs/01_loan_overview.png', dpi=150)
plt.close()
print("✓ Plot 1 saved")

# ─────────────────────────────────────────
# PLOT 2 — Approval by Property Area & Education
# ─────────────────────────────────────────
fig, axes = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Approval by Property Area & Education', fontsize=16, fontweight='bold')

area_attr = df.groupby('property_area')['loan_status'].apply(
    lambda x: (x=='Y').sum()/len(x)*100).sort_values(ascending=False)
area_attr.plot(kind='bar', ax=axes[0], color='#3498db', edgecolor='white')
axes[0].set_title('Approval Rate % by Property Area')
axes[0].set_ylabel('Approval Rate %')
axes[0].tick_params(axis='x', rotation=15)
for p in axes[0].patches:
    axes[0].annotate(f'{p.get_height():.1f}%',
                     (p.get_x()+p.get_width()/2, p.get_height()),
                     ha='center', va='bottom')

edu_attr = df.groupby('education')['loan_status'].apply(
    lambda x: (x=='Y').sum()/len(x)*100).sort_values(ascending=False)
edu_attr.plot(kind='bar', ax=axes[1], color='#9b59b6', edgecolor='white')
axes[1].set_title('Approval Rate % by Education')
axes[1].set_ylabel('Approval Rate %')
axes[1].tick_params(axis='x', rotation=15)
for p in axes[1].patches:
    axes[1].annotate(f'{p.get_height():.1f}%',
                     (p.get_x()+p.get_width()/2, p.get_height()),
                     ha='center', va='bottom')
plt.tight_layout()
plt.savefig('outputs/02_area_education.png', dpi=150)
plt.close()
print("✓ Plot 2 saved")

# ─────────────────────────────────────────
# PLOT 3 — Income Distribution
# ─────────────────────────────────────────
fig, axes = plt.subplots(1, 2, figsize=(14, 5))
fig.suptitle('Income Distribution Analysis', fontsize=16, fontweight='bold')

for label, grp in df.groupby('loan_status'):
    axes[0].hist(grp['applicantincome'], bins=30, alpha=0.6,
                 label='Approved' if label=='Y' else 'Rejected',
                 color=COLORS[label])
axes[0].set_title('Applicant Income Distribution')
axes[0].set_xlabel('Applicant Income')
axes[0].set_ylabel('Count')
axes[0].legend()
axes[0].set_xlim(0, 30000)

sns.boxplot(data=df, x='loan_status', y='applicantincome',
            palette=COLORS, ax=axes[1])
axes[1].set_title('Income Boxplot by Loan Status')
axes[1].set_xlabel('Loan Status')
axes[1].set_ylabel('Applicant Income')
axes[1].set_ylim(0, 30000)
plt.tight_layout()
plt.savefig('outputs/03_income_distribution.png', dpi=150)
plt.close()
print("✓ Plot 3 saved")

# ─────────────────────────────────────────
# PLOT 4 — Loan Amount Analysis
# ─────────────────────────────────────────
fig, axes = plt.subplots(1, 2, figsize=(14, 5))
fig.suptitle('Loan Amount Analysis', fontsize=16, fontweight='bold')

sns.boxplot(data=df, x='loan_status', y='loanamount',
            palette=COLORS, ax=axes[0])
axes[0].set_title('Loan Amount by Status')
axes[0].set_xlabel('Loan Status')
axes[0].set_ylabel('Loan Amount')

area_loan = df.groupby('property_area')['loanamount'].mean().sort_values(ascending=False)
area_loan.plot(kind='bar', ax=axes[1], color='#e67e22', edgecolor='white')
axes[1].set_title('Avg Loan Amount by Property Area')
axes[1].set_ylabel('Avg Loan Amount')
axes[1].tick_params(axis='x', rotation=15)
for p in axes[1].patches:
    axes[1].annotate(f'{p.get_height():.0f}',
                     (p.get_x()+p.get_width()/2, p.get_height()),
                     ha='center', va='bottom')
plt.tight_layout()
plt.savefig('outputs/04_loan_amount.png', dpi=150)
plt.close()
print("✓ Plot 4 saved")

# ─────────────────────────────────────────
# PLOT 5 — Credit History Impact
# ─────────────────────────────────────────
fig, axes = plt.subplots(1, 2, figsize=(12, 5))
fig.suptitle('Credit History Impact', fontsize=16, fontweight='bold')

credit_attr = df.groupby(['credit_history','loan_status']).size().unstack()
credit_attr.plot(kind='bar', ax=axes[0],
                 color=['#e74c3c','#2ecc71'], edgecolor='white')
axes[0].set_title('Loan Status by Credit History')
axes[0].set_xlabel('Credit History (0=Bad, 1=Good)')
axes[0].tick_params(axis='x', rotation=0)
axes[0].legend(['Rejected','Approved'])

credit_rate = df.groupby('credit_history')['loan_status'].apply(
    lambda x: (x=='Y').sum()/len(x)*100)
credit_rate.plot(kind='bar', ax=axes[1],
                 color=['#c0392b','#27ae60'], edgecolor='white')
axes[1].set_title('Approval Rate % by Credit History')
axes[1].set_ylabel('Approval Rate %')
axes[1].set_xlabel('Credit History (0=Bad, 1=Good)')
axes[1].tick_params(axis='x', rotation=0)
for p in axes[1].patches:
    axes[1].annotate(f'{p.get_height():.1f}%',
                     (p.get_x()+p.get_width()/2, p.get_height()),
                     ha='center', va='bottom', fontweight='bold')
plt.tight_layout()
plt.savefig('outputs/05_credit_history.png', dpi=150)
plt.close()
print("✓ Plot 5 saved")

# ─────────────────────────────────────────
# PLOT 6 — Correlation Heatmap
# ─────────────────────────────────────────
fig, ax = plt.subplots(figsize=(10, 7))
numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
corr = df[numeric_cols].corr()
mask = np.triu(np.ones_like(corr, dtype=bool))
sns.heatmap(corr, mask=mask, annot=True, fmt='.2f', cmap='RdYlGn',
            center=0, linewidths=0.5, ax=ax, annot_kws={'size': 9})
ax.set_title('Correlation Matrix', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('outputs/06_correlation_heatmap.png', dpi=150)
plt.close()
print("✓ Plot 6 saved")

# ─────────────────────────────────────────
# PLOT 7 — Gender & Marital Status
# ─────────────────────────────────────────
fig, axes = plt.subplots(1, 2, figsize=(12, 5))
fig.suptitle('Gender & Marital Status Analysis', fontsize=16, fontweight='bold')

gender_attr = df.groupby(['gender','loan_status']).size().unstack()
gender_attr.plot(kind='bar', ax=axes[0],
                 color=['#e74c3c','#2ecc71'], edgecolor='white')
axes[0].set_title('Loan Status by Gender')
axes[0].tick_params(axis='x', rotation=0)
axes[0].legend(['Rejected','Approved'])

married_rate = df.groupby('married')['loan_status'].apply(
    lambda x: (x=='Y').sum()/len(x)*100).sort_values(ascending=False)
married_rate.plot(kind='bar', ax=axes[1], color='#8e44ad', edgecolor='white')
axes[1].set_title('Approval Rate % by Marital Status')
axes[1].set_ylabel('Approval Rate %')
axes[1].tick_params(axis='x', rotation=0)
for p in axes[1].patches:
    axes[1].annotate(f'{p.get_height():.1f}%',
                     (p.get_x()+p.get_width()/2, p.get_height()),
                     ha='center', va='bottom', fontweight='bold')
plt.tight_layout()
plt.savefig('outputs/07_gender_marital.png', dpi=150)
plt.close()
print("✓ Plot 7 saved")

# ─────────────────────────────────────────
# PLOT 8 — Risk Segmentation
# ─────────────────────────────────────────
fig, axes = plt.subplots(1, 2, figsize=(12, 5))
fig.suptitle('Risk Segmentation Analysis', fontsize=16, fontweight='bold')

df['risk_segment'] = np.where(
    (df['credit_history']==0) & (df['total_income']<3000), 'High Risk',
    np.where(
        (df['credit_history']==0) | (df['total_income']<3000), 'Medium Risk',
        'Low Risk'
    )
)

risk_counts = df['risk_segment'].value_counts()
axes[0].pie(risk_counts, labels=risk_counts.index, autopct='%1.1f%%',
            colors=['#2ecc71','#f39c12','#e74c3c'], startangle=90)
axes[0].set_title('Risk Segment Distribution')

risk_rate = df.groupby('risk_segment')['loan_status'].apply(
    lambda x: (x=='Y').sum()/len(x)*100)
risk_rate.plot(kind='bar', ax=axes[1],
               color=['#e74c3c','#2ecc71','#f39c12'], edgecolor='white')
axes[1].set_title('Approval Rate % by Risk Segment')
axes[1].set_ylabel('Approval Rate %')
axes[1].tick_params(axis='x', rotation=15)
for p in axes[1].patches:
    axes[1].annotate(f'{p.get_height():.1f}%',
                     (p.get_x()+p.get_width()/2, p.get_height()),
                     ha='center', va='bottom', fontweight='bold')
plt.tight_layout()
plt.savefig('outputs/08_risk_segmentation.png', dpi=150)
plt.close()
print("✓ Plot 8 saved")

# ─────────────────────────────────────────
# KEY BUSINESS INSIGHTS
# ─────────────────────────────────────────
print("\n=== KEY BUSINESS INSIGHTS ===")
print(f"1. Overall approval rate: {(df['loan_status']=='Y').mean()*100:.1f}%")
print(f"2. Good credit approval:  {df[df['credit_history']==1]['loan_status'].eq('Y').mean()*100:.1f}%")
print(f"   Bad credit approval:   {df[df['credit_history']==0]['loan_status'].eq('Y').mean()*100:.1f}%")
print(f"3. Semiurban approval:    {df[df['property_area']=='Semiurban']['loan_status'].eq('Y').mean()*100:.1f}%")
print(f"   Rural approval:        {df[df['property_area']=='Rural']['loan_status'].eq('Y').mean()*100:.1f}%")
print(f"4. Graduate approval:     {df[df['education']=='Graduate']['loan_status'].eq('Y').mean()*100:.1f}%")
print(f"   Non-graduate approval: {df[df['education']=='Not Graduate']['loan_status'].eq('Y').mean()*100:.1f}%")
print(f"5. Married approval rate: {df[df['married']=='Yes']['loan_status'].eq('Y').mean()*100:.1f}%")
print(f"   Single approval rate:  {df[df['married']=='No']['loan_status'].eq('Y').mean()*100:.1f}%")
print(f"6. Avg loan - Approved:   {df[df['loan_status']=='Y']['loanamount'].mean():.0f}")
print(f"   Avg loan - Rejected:   {df[df['loan_status']=='N']['loanamount'].mean():.0f}")
print("\n✓ All 8 plots saved to outputs/ folder!")