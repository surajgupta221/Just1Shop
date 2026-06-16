from __future__ import annotations

import csv
import io
import re
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


DEFAULT_PRODUCT_IMAGE = (
    "https://images.unsplash.com/photo-1542838132-92c53300491e"
    "?auto=format&fit=crop&w=600&q=80"
)


CATEGORY_KEYWORDS = {
    "rice": ("rice", "basmati", "usna", "arwa", "grain", "chawal"),
    "grocery": ("atta", "sugar", "salt", "oil", "ghee", "dal", "pulses"),
    "fruits-veg": ("fruit", "banana", "apple", "onion", "potato", "vegetable"),
    "milk-dairy": ("milk", "paneer", "curd", "lassi", "butter", "cheese"),
    "summer": ("drink", "juice", "cold", "soda", "lassi", "water"),
    "personal-care": ("soap", "shampoo", "cream", "toothpaste", "oil"),
}


def now_utc() -> datetime:
    return datetime.now(timezone.utc)


def slugify(value: str) -> str:
    value = value.strip().lower()
    value = re.sub(r"[^a-z0-9]+", "-", value)
    return value.strip("-") or "product"


def infer_category(text: str) -> str:
    haystack = text.lower()
    for category, keywords in CATEGORY_KEYWORDS.items():
        if any(keyword in haystack for keyword in keywords):
            return category
    return "grocery"


def infer_tags(text: str) -> list[str]:
    haystack = text.lower()
    tags = set()
    for category, keywords in CATEGORY_KEYWORDS.items():
        if any(keyword in haystack for keyword in keywords):
            tags.add(category)
    if any(word in haystack for word in ("offer", "discount", "save", "free")):
        tags.add("deals")
    if any(word in haystack for word in ("fresh", "fruit", "vegetable", "milk")):
        tags.add("fresh")
    if any(word in haystack for word in ("family", "monthly", "kirana")):
        tags.add("kirana")
    return sorted(tags or {"grocery"})


def parse_price(text: str, fallback: float = 0) -> float:
    match = re.search(r"(?:rs\.?|₹|inr)?\s*(\d+(?:\.\d{1,2})?)", text, re.I)
    return float(match.group(1)) if match else float(fallback)


def parse_unit(text: str) -> str:
    match = re.search(
        r"(\d+(?:\.\d+)?)\s*(kg|g|gm|ltr|l|ml|pcs|pc|unit|pack)",
        text,
        re.I,
    )
    if not match:
        return "1 unit"
    unit = match.group(2).lower()
    if unit == "l":
        unit = "ltr"
    if unit == "gm":
        unit = "g"
    return f"{match.group(1)} {unit}"


def normalize_product(raw: dict[str, Any]) -> dict[str, Any]:
    name = str(raw.get("name") or raw.get("product") or raw.get("title") or "").strip()
    if not name:
        name = "New Just1Shop Product"
    description = str(raw.get("description") or f"{name} for Just1Shop customers.")
    price = float(raw.get("price") or raw.get("mrp") or raw.get("min_price") or 0)
    discount_price = raw.get("discountPrice") or raw.get("sale_price")
    if discount_price in ("", None):
        discount_price = price
    discount_price = float(discount_price)
    unit = str(raw.get("unit") or parse_unit(name) or "1 unit")
    image = raw.get("image") or raw.get("imageUrl") or raw.get("images") or DEFAULT_PRODUCT_IMAGE
    if isinstance(image, str):
        images = [image]
    else:
        images = list(image or [DEFAULT_PRODUCT_IMAGE])
    text = f"{name} {description} {unit}"
    product_id = str(raw.get("id") or slugify(f"{name}-{unit}"))

    return {
        "id": product_id,
        "name": name,
        "description": description,
        "price": price,
        "discountPrice": min(discount_price, price) if price else discount_price,
        "images": images,
        "imageUrl": images,
        "categoryId": str(raw.get("categoryId") or raw.get("category") or infer_category(text)),
        "unit": unit,
        "stock": int(raw.get("stock") or raw.get("stocks") or 10),
        "stocks": int(raw.get("stock") or raw.get("stocks") or 10),
        "isActive": bool(raw.get("isActive", True)),
        "featured": bool(raw.get("featured", False)),
        "tags": raw.get("tags") if isinstance(raw.get("tags"), list) else infer_tags(text),
        "createdAt": raw.get("createdAt") or now_utc(),
        "updatedAt": now_utc(),
        "ai": {
            "source": raw.get("aiSource", "manual"),
            "categoryConfidence": 0.82,
            "usefulFor": infer_tags(text),
            "generatedAt": now_utc(),
        },
    }


def product_from_text(text: str, source: str = "manual") -> dict[str, Any]:
    compact = " ".join(text.split())
    name = compact.split(" - ")[0].split(",")[0][:80].strip() or "AI Product"
    price = parse_price(compact)
    return normalize_product(
        {
            "name": name,
            "description": compact,
            "price": price,
            "discountPrice": price,
            "unit": parse_unit(compact),
            "aiSource": source,
        }
    )


def products_from_bill_text(text: str) -> list[dict[str, Any]]:
    products: list[dict[str, Any]] = []
    for line in text.splitlines():
        line = line.strip()
        if len(line) < 3:
            continue
        if not re.search(r"\d", line):
            continue
        product = product_from_text(line, source="bill")
        if product["price"] > 0:
            products.append(product)
    return products


def products_from_csv_bytes(data: bytes) -> list[dict[str, Any]]:
    text = data.decode("utf-8-sig")
    reader = csv.DictReader(io.StringIO(text))
    return [normalize_product(row) for row in reader]


def product_from_upload(filename: str, data: bytes, notes: str = "") -> dict[str, Any]:
    stem = Path(filename).stem.replace("_", " ").replace("-", " ")
    text = f"{stem} {notes}".strip()
    product = product_from_text(text, source="photo")
    product["imageData"] = data.hex()
    product["imageFilename"] = filename
    product["ai"]["source"] = "photo"
    product["ai"]["photoHints"] = infer_tags(text)
    return product


def delivery_zone_payload(raw: dict[str, Any]) -> dict[str, Any]:
    pincode = re.sub(r"\D", "", str(raw.get("pincode", "")))
    if len(pincode) != 6:
        raise ValueError("PIN code must be 6 digits")
    areas = raw.get("areas") or raw.get("area") or ""
    if isinstance(areas, str):
        areas = [item.strip() for item in areas.split(",") if item.strip()]
    return {
        "id": pincode,
        "pincode": pincode,
        "city": str(raw.get("city") or "").strip(),
        "state": str(raw.get("state") or "").strip(),
        "areas": areas,
        "isActive": bool(raw.get("isActive", True)),
        "deliveryFee": float(raw.get("deliveryFee") or 0),
        "minimumOrder": float(raw.get("minimumOrder") or 0),
        "estimatedMinutes": int(raw.get("estimatedMinutes") or 60),
        "storeId": str(raw.get("storeId") or ""),
        "createdAt": raw.get("createdAt") or now_utc(),
        "updatedAt": now_utc(),
    }
