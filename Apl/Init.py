# Core streaming (unchanged)
from fastjsonl import load, dump

# Array mode — APL/BQN/J inspired (new submodule)
from fastjsonl.array import load_array  # returns lazy/chunked ArrayTable proxy

data = load_array("events_2026.jsonl.zst")   # auto-decompress + stream → array view

# J-style terse ops (via aliases or expr builder)
errors     = data['status'] == 500           # verb-like filter (like J =: )
count      = # data['status'] == 500         # J # tally/count
avg_latency = +/ data['latency'] % #data      # J +/ sum, # tally, % divide

# BQN tacit flavor
high       = data ⊏ (data['value'] > 1e6)    # optional symbolic (if you add glyph aliases)

# APL reductions
total      = +/ data['amount']               # +/ reduce-sum
sorted     = data /: data['timestamp']       # /: grade up (sort indices)

# Table ops (J-like key/group)
by_user    = data groupby 'user_id'          # then .sum('score') etc.
