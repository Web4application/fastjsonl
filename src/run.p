import fastjsonl
import orjson

# Stream read (compressed OK)
for record in fastjsonl.load("large.jsonl.gz"):
    print(record["id"])

# Write with pretty-print & sorting
fastjsonl.dump(
    [{"id": i, "value": f"item {i}"} for i in range(1000000)],
    "output.jsonl",
    option=orjson.OPT_INDENT_2 | orjson.OPT_SORT_KEYS,
)

# Compressed write
fastjsonl.dump([...], "compressed.jsonl.zst", compress="zst", level=3)
