import time
import fastjsonl  # your module

start = time.perf_counter()
count = sum(1 for _ in fastjsonl.load("huge_file.jsonl.gz", limit=10_000_000))
print(f"Read {count} lines in {time.perf_counter() - start:.2f}s")
