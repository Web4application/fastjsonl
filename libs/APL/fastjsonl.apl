⍝ Example: Parse JSON string → array of records (objects become namespaces or keyed arrays)
json ← '{"name":"Alice","age":30} {"name":"Bob","age":25} {"name":"Charlie","age":35}'

⍝ Split into lines (simulate JSONL), parse each
records ← ⎕JSON¨ ⊃¨ ⎕NGET 'data.jsonl' 1   ⍝ Read lines, parse each to namespace

⍝ Vectorized ops on array of namespaces
names  ← {⍵.name}¨ records                 ⍝ Extract 'name' from each
ages   ← {⍵.age}¨ records                  ⍝ Extract 'age'
old    ← records ⌿ ages ≥ 30               ⍝ Select records where age ≥ 30 (replicate / compress)

⍝ Reductions (APL style)
avg_age ← (+/ages) ÷ ⍴ ages                ⍝ Sum ÷ count
sorted  ← records ⌷ ages ⍋ ages            ⍝ Grade ↑ sort indices, then permute

⍝ Export back to JSON
⎕JSON old                                  ⍝ Array → JSON string
