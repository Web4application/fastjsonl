NB. Simulate loaded JSONL data as boxed table (list of dict-like lists)
NB. In real code: parse strings → boxed arrays or use addon
data =: 0 : 0
name  Alice   Bob   Charlie
age   30      25    35
score 90 85   70 95  80 88
)

NB. Cut into table (rows as items)
t =: }: LF cut data           NB. split lines
hdr =: ;: >0{t                NB. header: name age score
rows =: }.t                   NB. data rows

NB. Transpose to columns
cols =: |: > ;: each rows

NB. Select columns by name (J-style "from")
name_col  =: 0 {"1 cols
age_col   =: 1 {"1 cols
score_mat =: 0 1 |: > 2 {"1 cols   NB. score as matrix

NB. Vector ops
old       =: (30&< age_col) # cols   NB. copy rows where age < 30 (no: # is copy)
old       =: (age_col > 29) # cols   NB. select rows age >=30

NB. Reductions
avg_age   =: (+/ % #) age_col
max_score =: >./ , score_mat
sorted    =: /:~ age_col

NB. Group by (keyed aggregate, J foreign or tacit)
NB. Simple sum scores per person
sum_scores=: +/"1 score_mat

echo avg_age
echo sum_scores
