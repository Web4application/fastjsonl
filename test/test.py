import fastjsonl

# Read (streaming, compressed OK)
for record in fastjsonl.load("huge.jsonl.gz"):
    process(record)

# Write with options
fastjsonl.dump(
    [{"id": i, "data": f"item {i}"} for i in range(1_000_000)],
    "output.jsonl.zst",
    compress="zst",
    option=orjson.OPT_INDENT_2 | orjson.OPT_SORT_KEYS
)
