import time
import fastjsonl  # your module

start = time.perf_counter()
count = sum(1 for _ in fastjsonl.load("huge_file.jsonl.gz", limit=10_000_000))
print(f"Read {count} lines in {time.perf_counter() - start:.2f}s")
# In FastJSONL class
@staticmethod
def dump(
    iterable: Iterable[Any],
    path: str | Path | BinaryIO,
    *,
    option: int | None = None,  # orjson options
    compress: str | None = None,
    level: int = 6,
    batch_size_bytes: int = 1024 * 1024,
) -> None:
    # ... existing code ...
    for item in iterable:
        buffer.write(orjson.dumps(item, option=option))
        buffer.write(b"\n")
        if buffer.tell() >= batch_size_bytes:
            f.write(buffer.getvalue())
            buffer.seek(0)
            buffer.truncate(0)
    # Final flush...
