import orjson 
import gzip
import bz2
import lzma
try:
    import zstandard as zstd
    HAS_ZSTD = True
except ImportError:
    HAS_ZSTD = False

from typing import Iterable, Any, Iterator, BinaryIO, TextIO
from pathlib import Path
import io
import os

class FastJSONL:
    """Ultra-fast JSONL reader/writer powered by orjson."""

    @staticmethod
    def _open_read(path: str | Path | BinaryIO) -> BinaryIO:
        if isinstance(path, (str, Path)):
            path = Path(path)
            ext = path.suffix.lower()
            f = open(path, "rb")
            if ext == ".gz":
                return gzip.GzipFile(fileobj=f, mode="rb")
            elif ext == ".bz2":
                return bz2.BZ2File(f, mode="rb")
            elif ext in (".xz", ".lzma"):
                return lzma.LZMAFile(f, mode="rb")
            elif ext == ".zst" and HAS_ZSTD:
                dctx = zstd.ZstdDecompressor()
                return dctx.stream_reader(f)
            else:
                return f
        return path  # already a file-like

    @staticmethod
    def load(
        path: str | Path | BinaryIO,
        *,
        skip_invalid: bool = False,
        limit: int | None = None
    ) -> Iterator[dict]:
        """Stream JSONL records as dicts. Extremely memory-efficient."""
        f = FastJSONL._open_read(path)
        count = 0
        try:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    yield orjson.loads(line)
                    count += 1
                    if limit is not None and count >= limit:
                        break
                except orjson.JSONDecodeError:
                    if not skip_invalid:
                        raise
        finally:
            if hasattr(f, "close") and f is not path:
                f.close()

    @staticmethod
    def dump(
        iterable: Iterable[Any],
        path: str | Path | BinaryIO,
        *,
        compress: str | None = None,   # "gz", "bz2", "xz", "zst"
        level: int = 6,                 # compression level
        batch_size: int = 8192          # buffer writes in batches
    ) -> None:
        """Write iterable of objects as JSONL. Batched for speed."""
        if isinstance(path, (str, Path)):
            path = Path(path)
            if compress:
                ext = f".{compress}"
                if not path.name.endswith(ext):
                    path = path.with_suffix(path.suffix + ext)
            f_raw = open(path, "wb")
        else:
            f_raw = path

        try:
            if compress == "gz":
                f = gzip.GzipFile(fileobj=f_raw, mode="wb", compresslevel=level)
            elif compress == "bz2":
                f = bz2.BZ2File(f_raw, mode="wb", compresslevel=level)
            elif compress in ("xz", "lzma"):
                f = lzma.LZMAFile(f_raw, mode="wb", preset=level)
            elif compress == "zst" and HAS_ZSTD:
                cctx = zstd.ZstdCompressor(level=level)
                f = cctx.write_to(f_raw)
            else:
                f = f_raw

            buffer = io.BytesIO()
            for item in iterable:
                buffer.write(orjson.dumps(item))
                buffer.write(b"\n")
                if buffer.tell() > 1024 * 1024:  # 1 MB flush threshold
                    f.write(buffer.getvalue())
                    buffer.seek(0)
                    buffer.truncate(0)
            # Final flush
            if buffer.tell():
                f.write(buffer.getvalue())
            f.flush()
        finally:
            if f is not f_raw:
                f.close()
            if f_raw is not path and hasattr(f_raw, "close"):
                f_raw.close()
