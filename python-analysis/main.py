"""End-to-end employment trend analysis; uses MySQL when DATABASE_URL is configured, else CSV exports."""
from pathlib import Path
import os, warnings
import numpy as np, pandas as pd
import matplotlib.pyplot as plt, seaborn as sns
from dotenv import load_dotenv
from sklearn.linear_model import LinearRegression
warnings.filterwarnings("ignore"); ROOT=Path(__file__).resolve().parent; OUT=ROOT/'output'; EXPORTS=ROOT.parent/'data'/'exports'; OUT.mkdir(exist_ok=True)

def load_data():
    load_dotenv(ROOT/'.env'); url=os.getenv('DATABASE_URL')
    tables=['student','vacancy','application','company','department']
    if url:
        try:
            from sqlalchemy import create_engine
            engine=create_engine(url); print('Loading from MySQL')
            return {t:pd.read_sql(f'SELECT * FROM {t}',engine) for t in tables}
        except Exception as e: print(f'MySQL unavailable ({e}); attempting CSV fallback.')
    result={}
    for t in tables:
        f=EXPORTS/f'{t}.csv'
        if not f.exists(): raise FileNotFoundError(f'Missing {f}. Set DATABASE_URL or export the required CSV files.')
        result[t]=pd.read_csv(f)
    print('Loading from CSV exports'); return result

def clean(d):
    for k,df in d.items(): d[k]=df.drop_duplicates().replace(r'^\s*$',np.nan,regex=True)
    s,v,a=d['student'],d['vacancy'],d['application']
    s['skills']=s['skills'].fillna('').str.lower().str.replace(r'\s*,\s*',',',regex=True); s['skill_count']=s.skills.str.count(',')+1
    for col in ['cgpa']: s[col]=pd.to_numeric(s[col],errors='coerce')
    for col in ['min_salary','max_salary']: v[col]=pd.to_numeric(v[col],errors='coerce')
    v['salary_midpoint']=(v.min_salary+v.max_salary)/2
    lo,hi=v.salary_midpoint.quantile([.01,.99]); v.loc[~v.salary_midpoint.between(lo,hi),'salary_midpoint']=np.nan
    for col in ['application_date','decision_date']: a[col]=pd.to_datetime(a[col],errors='coerce')
    a['application_year']=a.application_date.dt.year; a['application_month']=a.application_date.dt.to_period('M').astype(str); a['days_to_decision']=(a.decision_date-a.application_date).dt.days
    return d

def save(fig,name): fig.tight_layout(); fig.savefig(OUT/f'{name}.png',dpi=150); plt.close(fig)
def charts(d):
    s,v,a,c,dep=d['student'],d['vacancy'],d['application'],d['company'],d['department']; dep=dep.rename(columns={'name':'department'}); c=c.rename(columns={'name':'company'}); x=a.merge(s[['student_id','department_id','cgpa','skills']],on='student_id').merge(dep,on='department_id').merge(v[['vacancy_id','company_id','salary_midpoint','location']],on='vacancy_id').merge(c[['company_id','company','industry']],on='company_id')
    dept= x.groupby('department').agg(applications=('application_id','size'),selections=('status',lambda z:(z=='SELECTED').sum())); save(dept.plot.bar(figsize=(9,5)).get_figure(),'01_department_applications_selections')
    trend=x.groupby('application_month').size(); save(trend.plot(figsize=(10,4),marker='o',title='Monthly applications').get_figure(),'02_application_trend')
    eligible=s.groupby('department_id').size(); placed=x[x.status=='SELECTED'].groupby('department_id').student_id.nunique(); pct=(placed/eligible*100).fillna(0); save(pct.plot.bar(figsize=(8,4),title='Placement percentage').get_figure(),'03_placement_percentage')
    top=x[x.status=='SELECTED'].groupby('company').size().sort_values().tail(10); save(top.plot.barh(figsize=(8,5),title='Top recruiting companies').get_figure(),'04_top_companies')
    fig,ax=plt.subplots(figsize=(9,5));sns.boxplot(data=x,x='department',y='salary_midpoint',ax=ax);ax.tick_params(axis='x',rotation=35);save(fig,'05_salary_department')
    fig,ax=plt.subplots(figsize=(8,5));sns.histplot(x.salary_midpoint.dropna(),bins=15,ax=ax);save(fig,'06_salary_distribution')
    funnel=a.status.value_counts().reindex(['APPLIED','SHORTLISTED','SELECTED']).fillna(0);save(funnel.plot.bar(figsize=(6,4),title='Application funnel').get_figure(),'07_status_funnel')
    skills=s.skills.str.split(',').explode().value_counts().head(10);save(skills.plot.bar(figsize=(8,4),title='In-demand skills').get_figure(),'08_skills')
    fig,ax=plt.subplots(figsize=(7,5));sns.boxplot(data=x,x='status',y='cgpa',ax=ax);save(fig,'09_cgpa_selection')
    fig,ax=plt.subplots(figsize=(6,5));sns.heatmap(x[['cgpa','salary_midpoint','days_to_decision']].corr(),annot=True,cmap='Blues',ax=ax);save(fig,'10_correlation')
    save(x.industry.value_counts().plot.bar(figsize=(8,4),title='Vacancies by industry').get_figure(),'11_industry')
    t=trend.reset_index(name='applications'); t['index']=np.arange(len(t)); model=LinearRegression().fit(t[['index']],t.applications); future=pd.DataFrame({'index':np.arange(len(t),len(t)+3)}); forecast=model.predict(future); fig,ax=plt.subplots(figsize=(9,4));ax.plot(t['index'],t.applications,label='actual');ax.plot(future['index'],forecast,'--',label='forecast');ax.legend();save(fig,'12_forecast')
    return x,forecast
def main():
    d=clean(load_data()); x,forecast=charts(d); print('\nSummary statistics\n',x[['cgpa','salary_midpoint','days_to_decision']].describe().T); print('\nForecast next 3 periods:',np.round(forecast,1));
    insights=[f"{len(x)} applications were analysed across {x.department.nunique()} departments.",f"Highest selected-company count: {x[x.status=='SELECTED'].company.value_counts().idxmax() if (x.status=='SELECTED').any() else 'N/A'}.",f"Median CGPA is {x.cgpa.median():.2f}.",f"Median salary midpoint is {x.salary_midpoint.median():.0f}.",f"Most common skill is {d['student'].skills.str.split(',').explode().mode().iat[0] if len(d['student']) else 'N/A'}."]
    (OUT/'insights.txt').write_text('\n'.join('- '+i for i in insights),encoding='utf8'); print('\nInsights\n'+'\n'.join(insights))
if __name__=='__main__': main()
