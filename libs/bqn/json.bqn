# Assume we load the json parser from bqn-libs (or implement similar)
⟨Parse⟩ ← •Import "json.bqn"   # Or inline a simple parser

# Example data (simulate JSONL lines as array of strings)
lines ← ⟨
  "{\"name\":\"Alice\",\"scores\":[90,85]}"
  "{\"name\":\"Bob\",\"scores\":[70,95]}"
  "{\"name\":\"Charlie\",\"scores\":[80,88]}"
⟩

# Parse each line → BQN value (lists, numbers, etc.)
data ← Parse¨ lines

# Extract fields (vectorized)
names  ← {𝕩.name}¨ data
scores ← {𝕩.scores}¨ data

# Vectorized filter (BQN style, using Pick ⊏)
high   ← data ⊏ (⌈´¨ scores) ≥ 90   # Keep where max score ≥ 90

# Tacit reductions / computations
avg_scores ← (+´¨ scores) ÷ ≠¨ scores   # mean per person
total      ← +´ +´¨ scores              # grand total

# Example tacit function (fork-like)
Mean ← (+´ ÷ ≠)

# Apply to all
means ← Mean¨ scores

•Show means   # Output: ⟨ 87.5 82.5 84 ⟩
