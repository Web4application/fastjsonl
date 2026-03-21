import orjson
import gzip
import bz2
import lzma
import io
from pathlib import Path
from typing import Iterable, Any, Iterator, BinaryIO, Union

try:
    import zstandard as zstd
    HAS_ZSTD = True
except ImportError:
    HAS_ZSTD = False


def _open_readable(file: Union[str, Path, BinaryIO]) -> BinaryIO:
    if isinstance(file, (str, Path)):
        path = Path(file)
        ext = path.suffix.lower()
        raw = open(path, "rb")
        if ext == ".gz":
            return gzip.GzipFile(raw, mode="rb")
        if ext == ".bz2":
            return bz2.BZ2File(raw, mode="rb")
        if ext in (".xz", ".lzma"):
            return lzma.LZMAFile(raw, mode="rb")
        if ext == ".zst" and HAS_ZSTD:
            return zstd.ZstdDecompressor().stream_reader(raw)
        return raw
    return file


def _open_writable(file: Union[str, Path, BinaryIO], compress: str | None = None, level: int = 6) -> BinaryIO:
    if isinstance(file, (str, Path)):
        path = Path(file)
        if compress:
            ext = f".{compress}"
            if not path.suffix == ext:
                path = path.with_suffix(path.suffix + ext)
        raw = open(path, "wb")
    else:
        raw = file

    if compress == "gz":
        return gzip.GzipFile(raw, mode="wb", compresslevel=level)
    if compress == "bz2":
        return bz2.BZ2File(raw, mode="wb", compresslevel=level)
    if compress in ("xz", "lzma"):
        return lzma.LZMAFile(raw, mode="wb", preset=level)
    if compress == "zst" and HAS_ZSTD:
        return zstd.ZstdCompressor(level=level).write_to(raw)
    return raw


def load(
    file: Union[str, Path, BinaryIO],
    *,
    option: int | None = None,
    skip_invalid: bool = False,
    limit: int | None = None
) -> Iterator[Any]:
    """Stream JSONL records efficiently."""
    f = _open_readable(file)
    count = 0
    try:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                yield orjson.loads(line, option=option)
                count += 1
                if limit is not None and count >= limit:
                    break
            except orjson.JSONDecodeError:
                if not skip_invalid:
                    raise
    finally:
        if f is not file and hasattr(f, "close"):
            f.close()


def dump(
    iterable: Iterable[Any],
    file: Union[str, Path, BinaryIO],
    *,
    option: int | None = None,
    compress: str | None = None,
    level: int = 6,
    batch_size_bytes: int = 1024 * 1024  # 1 MiB
) -> None:
    """Write iterable as JSONL with batching for speed."""
    f = _open_writable(file, compress=compress, level=level)
    buffer = io.BytesIO()
    try:
        for item in iterable:
            buffer.write(orjson.dumps(item, option=option))
            buffer.write(b"\n")
            if buffer.tell() >= batch_size_bytes:
                f.write(buffer.getvalue())
                buffer.seek(0)
                buffer.truncate(0)
        if buffer.tell():
            f.write(buffer.getvalue())
        f.flush()
    finally:
        if f is not file and hasattr(f, "close"):
            f.close()


class FastJSONL:
    load = staticmethod(load)
    dump = staticmethod(dump)
