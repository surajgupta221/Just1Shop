from fastapi import FastAPI, HTTPException, UploadFile, File, Form
from datetime import datetime
from import_product import parse_iso_timestamp
import import_product
from ai_catalog_tools import (
    banner_from_prompt,
    delivery_zone_payload,
    normalize_product,
    product_from_text,
    product_from_upload,
    products_from_bill_text,
    products_from_csv_bytes,
)
import firebase_admin
from firebase_admin import credentials, firestore
import os
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Initialize Firebase with path from .env or use default
cred_path = os.getenv("FIREBASE_CREDENTIALS_PATH", "serviceAccountKey.json")

# Check if credentials file exists
if not Path(cred_path).exists():
    raise FileNotFoundError(
        f"\n❌ Firebase credentials file not found: {cred_path}\n"
        f"Please ensure serviceAccountKey.json is in the project root.\n"
        f"You can download it from Firebase Console > Project Settings > Service Accounts > Generate New Private Key\n"
        f"Then place it in: {Path('.').resolve() / cred_path}"
    )

cred = credentials.Certificate(cred_path)
firebase_admin.initialize_app(cred)

db = firestore.client()

app = FastAPI()


# Import products on startup (will use existing initialized `db`)
@app.on_event("startup")
def import_on_startup():
    try:
        import_product.import_products(db=db)
        print("Product import completed on startup.")
    except Exception as e:
        # Log but do not prevent app from starting
        print(f"Product import failed on startup: {e}")
    
    try:
        import_product.import_categories(db=db)
        print("Category import completed on startup.")
    except Exception as e:
        # Log but do not prevent app from starting
        print(f"Category import failed on startup: {e}")
    
    try:
        import_product.import_sub_categories(db=db)
        print("Sub category import completed on startup.")
    except Exception as e:
        # Log but do not prevent app from starting
        print(f"Sub category import failed on startup: {e}")
    
    try:
        import_product.import_banners(db=db)
        print("Banner import completed on startup.")
    except Exception as e:
        # Log but do not prevent app from starting
        print(f"Banner import failed on startup: {e}")
    
    try:
        import_product.import_offers(db=db)
        print("Offer import completed on startup.")
    except Exception as e:
        # Log but do not prevent app from starting
        print(f"Offer import failed on startup: {e}")
    
    try:
        import_product.import_festival_offers(db=db)
        print("Festival offer import completed on startup.")
    except Exception as e:
        # Log but do not prevent app from starting
        print(f"Festival offer import failed on startup: {e}")
    
    try:
        import_product.import_addresses(db=db)
        print("Address import completed on startup.")
    except Exception as e:
        # Log but do not prevent app from starting
        print(f"Address import failed on startup: {e}")

# ----------------------------
# GET ALL PRODUCTS
# ----------------------------
@app.get("/products")
def get_products():
    products_ref = db.collection("products")
    docs = products_ref.stream()

    product_list = []
    for doc in docs:
        data = doc.to_dict()
        data["id"] = doc.id

        def _sanitize(v):
            if v is None:
                return None
            if isinstance(v, (str, int, float, bool)):
                return v
            if isinstance(v, datetime):
                return v.isoformat()
            if isinstance(v, dict):
                return {k: _sanitize(val) for k, val in v.items()}
            if isinstance(v, (list, tuple)):
                return [_sanitize(x) for x in v]
            try:
                return str(v)
            except Exception:
                return None

        safe_data = {k: _sanitize(val) for k, val in data.items()}
        product_list.append(safe_data)

    return product_list


# ----------------------------
# ADD PRODUCT
# ----------------------------
@app.post("/add-product")
def add_product(product: dict):
    payload = product.copy()
    # allow client to provide an `id` to use as document id
    doc_id = payload.pop("id", None)

    # convert ISO date strings to datetime so Firestore stores timestamps
    if isinstance(payload.get("date"), str) and payload.get("date"):
        try:
            payload["date"] = parse_iso_timestamp(payload["date"])
        except Exception:
            pass

    coll = db.collection("products")
    if doc_id:
        coll.document(doc_id).set(payload)
        return {"message": "Product added successfully", "id": doc_id}
    else:
        doc_ref, _ = coll.add(payload)
        return {"message": "Product added successfully", "id": doc_ref.id}


# ----------------------------
# DELETE PRODUCT
# ----------------------------
@app.delete("/delete-product/{product_id}")
def delete_product(product_id: str):
    db.collection("products").document(product_id).delete()
    return {"message": "Product deleted successfully"}


# ----------------------------
# GET ALL CATEGORIES
# ----------------------------
@app.get("/category_master")
def get_categories():
    categories_ref = db.collection("category_master")
    docs = categories_ref.stream()

    category_list = []
    for doc in docs:
        data = doc.to_dict()
        data["id"] = doc.id

        def _sanitize(v):
            if v is None:
                return None
            if isinstance(v, (str, int, float, bool)):
                return v
            if isinstance(v, datetime):
                return v.isoformat()
            if isinstance(v, dict):
                return {k: _sanitize(val) for k, val in v.items()}
            if isinstance(v, (list, tuple)):
                return [_sanitize(x) for x in v]
            try:
                return str(v)
            except Exception:
                return None

        safe_data = {k: _sanitize(val) for k, val in data.items()}
        category_list.append(safe_data)

    return category_list


# ----------------------------
# ADD CATEGORY
# ----------------------------
@app.post("/add-category")
def add_category(category: dict):
    payload = category.copy()
    doc_id = payload.pop("id", None)

    coll = db.collection("category_master")
    if doc_id:
        coll.document(doc_id).set(payload)
        return {"message": "Category added successfully", "id": doc_id}
    else:
        res = coll.add(payload)
        # Handle Firestore return format
        doc_ref = None
        if isinstance(res, tuple) or isinstance(res, list):
            for part in res:
                if hasattr(part, "id"):
                    doc_ref = part
                    break
        else:
            if hasattr(res, "id"):
                doc_ref = res

        doc_id_out = getattr(doc_ref, "id", None)
        return {"message": "Category added successfully", "id": doc_id_out}


# ----------------------------
# DELETE CATEGORY
# ----------------------------
@app.delete("/delete-category/{category_id}")
def delete_category(category_id: str):
    db.collection("category_master").document(category_id).delete()
    return {"message": "Category deleted successfully"}


# ----------------------------
# GET ALL SUB CATEGORIES
# ----------------------------
@app.get("/sub_category_master")
def get_sub_categories():
    sub_categories_ref = db.collection("sub_category_master")
    docs = sub_categories_ref.stream()

    sub_category_list = []
    for doc in docs:
        data = doc.to_dict()
        data["id"] = doc.id

        def _sanitize(v):
            if v is None:
                return None
            if isinstance(v, (str, int, float, bool)):
                return v
            if isinstance(v, datetime):
                return v.isoformat()
            if isinstance(v, dict):
                return {k: _sanitize(val) for k, val in v.items()}
            if isinstance(v, (list, tuple)):
                return [_sanitize(x) for x in v]
            try:
                return str(v)
            except Exception:
                return None

        safe_data = {k: _sanitize(val) for k, val in data.items()}
        sub_category_list.append(safe_data)

    return sub_category_list


# ----------------------------
# ADD SUB CATEGORY
# ----------------------------
@app.post("/add-sub-category")
def add_sub_category(sub_category: dict):
    payload = sub_category.copy()
    doc_id = payload.pop("id", None)

    coll = db.collection("sub_category_master")
    if doc_id:
        coll.document(doc_id).set(payload)
        return {"message": "Sub category added successfully", "id": doc_id}
    else:
        res = coll.add(payload)
        # Handle Firestore return format
        doc_ref = None
        if isinstance(res, tuple) or isinstance(res, list):
            for part in res:
                if hasattr(part, "id"):
                    doc_ref = part
                    break
        else:
            if hasattr(res, "id"):
                doc_ref = res

        doc_id_out = getattr(doc_ref, "id", None)
        return {"message": "Sub category added successfully", "id": doc_id_out}


# ----------------------------
# DELETE SUB CATEGORY
# ----------------------------
@app.delete("/delete-sub-category/{sub_category_id}")
def delete_sub_category(sub_category_id: str):
    db.collection("sub_category_master").document(sub_category_id).delete()
    return {"message": "Sub category deleted successfully"}


# ----------------------------
# GET ALL BANNERS
# ----------------------------
@app.get("/banner")
def get_banners():
    docs = list(db.collection("banner").stream()) + list(db.collection("banners").stream())

    banner_list = []
    seen_ids = set()
    for doc in docs:
        data = doc.to_dict()
        data["id"] = doc.id
        if data["id"] in seen_ids:
            continue
        seen_ids.add(data["id"])

        def _sanitize(v):
            if v is None:
                return None
            if isinstance(v, (str, int, float, bool)):
                return v
            if isinstance(v, datetime):
                return v.isoformat()
            if isinstance(v, dict):
                return {k: _sanitize(val) for k, val in v.items()}
            if isinstance(v, (list, tuple)):
                return [_sanitize(x) for x in v]
            try:
                return str(v)
            except Exception:
                return None

        safe_data = {k: _sanitize(val) for k, val in data.items()}
        banner_list.append(safe_data)

    return banner_list


# ----------------------------
# ADD BANNER
# ----------------------------
@app.post("/add-banner")
def add_banner(banner: dict):
    payload = banner.copy()
    doc_id = payload.pop("id", None)

    coll = db.collection("banner")
    app_coll = db.collection("banners")
    if doc_id:
        coll.document(doc_id).set(payload)
        app_coll.document(doc_id).set(payload)
        return {"message": "Banner added successfully", "id": doc_id}
    else:
        res = coll.add(payload)
        # Handle Firestore return format
        doc_ref = None
        if isinstance(res, tuple) or isinstance(res, list):
            for part in res:
                if hasattr(part, "id"):
                    doc_ref = part
                    break
        else:
            if hasattr(res, "id"):
                doc_ref = res

        doc_id_out = getattr(doc_ref, "id", None)
        if doc_id_out:
            app_coll.document(doc_id_out).set(payload)
        return {"message": "Banner added successfully", "id": doc_id_out}


@app.post("/ai/banner-draft")
def ai_banner_draft(prompt: dict):
    try:
        return banner_from_prompt(prompt)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc))


# ----------------------------
# DELETE BANNER
# ----------------------------
@app.delete("/delete-banner/{banner_id}")
def delete_banner(banner_id: str):
    db.collection("banner").document(banner_id).delete()
    db.collection("banners").document(banner_id).delete()
    return {"message": "Banner deleted successfully"}


# ----------------------------
# GET ALL OFFERS
# ----------------------------
@app.get("/offer")
def get_offers():
    offers_ref = db.collection("offer")
    docs = offers_ref.stream()

    offer_list = []
    for doc in docs:
        data = doc.to_dict()
        data["id"] = doc.id

        def _sanitize(v):
            if v is None:
                return None
            if isinstance(v, (str, int, float, bool)):
                return v
            if isinstance(v, datetime):
                return v.isoformat()
            if isinstance(v, dict):
                return {k: _sanitize(val) for k, val in v.items()}
            if isinstance(v, (list, tuple)):
                return [_sanitize(x) for x in v]
            try:
                return str(v)
            except Exception:
                return None

        safe_data = {k: _sanitize(val) for k, val in data.items()}
        offer_list.append(safe_data)

    return offer_list


# ----------------------------
# ADD OFFER
# ----------------------------
@app.post("/add-offer")
def add_offer(offer: dict):
    payload = offer.copy()
    doc_id = payload.pop("id", None)

    # convert ISO date/datetime strings to datetime so Firestore stores timestamps
    for date_field in ["createdAt", "validTill"]:
        if isinstance(payload.get(date_field), str) and payload.get(date_field):
            try:
                payload[date_field] = parse_iso_timestamp(payload[date_field])
            except Exception:
                pass

    coll = db.collection("offer")
    if doc_id:
        coll.document(doc_id).set(payload)
        return {"message": "Offer added successfully", "id": doc_id}
    else:
        res = coll.add(payload)
        # Handle Firestore return format
        doc_ref = None
        if isinstance(res, tuple) or isinstance(res, list):
            for part in res:
                if hasattr(part, "id"):
                    doc_ref = part
                    break
        else:
            if hasattr(res, "id"):
                doc_ref = res

        doc_id_out = getattr(doc_ref, "id", None)
        return {"message": "Offer added successfully", "id": doc_id_out}


# ----------------------------
# DELETE OFFER
# ----------------------------
@app.delete("/delete-offer/{offer_id}")
def delete_offer(offer_id: str):
    db.collection("offer").document(offer_id).delete()
    return {"message": "Offer deleted successfully"}


# ----------------------------
# GET ALL FESTIVAL OFFERS
# ----------------------------
@app.get("/festivalOffers")
def get_festival_offers():
    festival_offers_ref = db.collection("festivalOffers")
    docs = festival_offers_ref.stream()

    festival_offer_list = []
    for doc in docs:
        data = doc.to_dict()
        data["id"] = doc.id

        def _sanitize(v):
            if v is None:
                return None
            if isinstance(v, (str, int, float, bool)):
                return v
            if isinstance(v, datetime):
                return v.isoformat()
            if isinstance(v, dict):
                return {k: _sanitize(val) for k, val in v.items()}
            if isinstance(v, (list, tuple)):
                return [_sanitize(x) for x in v]
            try:
                return str(v)
            except Exception:
                return None

        safe_data = {k: _sanitize(val) for k, val in data.items()}
        festival_offer_list.append(safe_data)

    return festival_offer_list


# ----------------------------
# ADD FESTIVAL OFFER
# ----------------------------
@app.post("/add-festivalOffer")
def add_festival_offer(festival_offer: dict):
    payload = festival_offer.copy()
    doc_id = payload.pop("id", None)

    # convert ISO date/datetime strings to datetime so Firestore stores timestamps
    if isinstance(payload.get("createdAt"), str) and payload.get("createdAt"):
        try:
            payload["createdAt"] = parse_iso_timestamp(payload["createdAt"])
        except Exception:
            pass

    # process festivalDetail array
    if "festivalDetail" in payload and isinstance(payload["festivalDetail"], list):
        for detail in payload["festivalDetail"]:
            if isinstance(detail, dict) and isinstance(detail.get("createdAt"), str):
                try:
                    detail["createdAt"] = parse_iso_timestamp(detail["createdAt"])
                except Exception:
                    pass

    coll = db.collection("festivalOffers")
    if doc_id:
        coll.document(doc_id).set(payload)
        return {"message": "Festival offer added successfully", "id": doc_id}
    else:
        res = coll.add(payload)
        # Handle Firestore return format
        doc_ref = None
        if isinstance(res, tuple) or isinstance(res, list):
            for part in res:
                if hasattr(part, "id"):
                    doc_ref = part
                    break
        else:
            if hasattr(res, "id"):
                doc_ref = res

        doc_id_out = getattr(doc_ref, "id", None)
        return {"message": "Festival offer added successfully", "id": doc_id_out}


# ----------------------------
# DELETE FESTIVAL OFFER
# ----------------------------
@app.delete("/delete-festivalOffer/{festival_offer_id}")
def delete_festival_offer(festival_offer_id: str):
    db.collection("festivalOffers").document(festival_offer_id).delete()
    return {"message": "Festival offer deleted successfully"}


# ----------------------------
# GET ALL ADDRESSES
# ----------------------------
@app.get("/address")
def get_addresses():
    addresses_ref = db.collection("address")
    docs = addresses_ref.stream()

    address_list = []
    for doc in docs:
        data = doc.to_dict()
        data["id"] = doc.id

        def _sanitize(v):
            if v is None:
                return None
            if isinstance(v, (str, int, float, bool)):
                return v
            if isinstance(v, datetime):
                return v.isoformat()
            if isinstance(v, dict):
                return {k: _sanitize(val) for k, val in v.items()}
            if isinstance(v, (list, tuple)):
                return [_sanitize(x) for x in v]
            try:
                return str(v)
            except Exception:
                return None

        safe_data = {k: _sanitize(val) for k, val in data.items()}
        address_list.append(safe_data)

    return address_list


# ----------------------------
# ADD ADDRESS
# ----------------------------
@app.post("/add-address")
def add_address(address: dict):
    payload = address.copy()
    doc_id = payload.pop("id", None)

    # convert ISO date/datetime strings to datetime so Firestore stores timestamps
    if isinstance(payload.get("createdAt"), str) and payload.get("createdAt"):
        try:
            payload["createdAt"] = parse_iso_timestamp(payload["createdAt"])
        except Exception:
            pass

    coll = db.collection("address")
    if doc_id:
        coll.document(doc_id).set(payload)
        return {"message": "Address added successfully", "id": doc_id}
    else:
        res = coll.add(payload)
        # Handle Firestore return format
        doc_ref = None
        if isinstance(res, tuple) or isinstance(res, list):
            for part in res:
                if hasattr(part, "id"):
                    doc_ref = part
                    break
        else:
            if hasattr(res, "id"):
                doc_ref = res

        doc_id_out = getattr(doc_ref, "id", None)
        return {"message": "Address added successfully", "id": doc_id_out}


# ----------------------------
# DELETE ADDRESS
# ----------------------------
@app.delete("/delete-address/{address_id}")
def delete_address(address_id: str):
    db.collection("address").document(address_id).delete()
    return {"message": "Address deleted successfully"}


# ----------------------------
# DELIVERY SERVICE PIN CODES
# ----------------------------
@app.get("/delivery-zones")
def get_delivery_zones():
    docs = db.collection("delivery_zones").stream()
    zones = []
    for doc in docs:
        data = doc.to_dict()
        data["id"] = doc.id
        zones.append(data)
    zones.sort(key=lambda item: item.get("pincode", ""))
    return zones


@app.get("/delivery-zones/{pincode}")
def get_delivery_zone(pincode: str):
    doc = db.collection("delivery_zones").document(pincode).get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail="PIN code is not active")
    data = doc.to_dict()
    data["id"] = doc.id
    return data


@app.post("/delivery-zones")
def add_delivery_zone(zone: dict):
    try:
        payload = delivery_zone_payload(zone)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc))
    db.collection("delivery_zones").document(payload["id"]).set(payload)
    return {"message": "Delivery PIN code saved", "id": payload["id"]}


@app.delete("/delivery-zones/{pincode}")
def delete_delivery_zone(pincode: str):
    db.collection("delivery_zones").document(pincode).delete()
    return {"message": "Delivery PIN code deleted", "id": pincode}


@app.get("/delivery/check/{pincode}")
def check_delivery_pincode(pincode: str):
    doc = db.collection("delivery_zones").document(pincode).get()
    if not doc.exists:
        return {
            "pincode": pincode,
            "serviceable": False,
            "message": "Delivery is not active in this PIN code yet.",
        }
    zone = doc.to_dict()
    return {
        "pincode": pincode,
        "serviceable": bool(zone.get("isActive", True)),
        "zone": zone,
        "message": "Delivery is active in this PIN code.",
    }


# ----------------------------
# AI PRODUCT CREATION
# ----------------------------
@app.post("/ai/product-draft")
def ai_product_draft(payload: dict):
    text = payload.get("text") or payload.get("prompt") or ""
    if not text:
        raise HTTPException(status_code=400, detail="text is required")
    return product_from_text(text, source="manual")


@app.post("/ai/product-from-bill")
def ai_product_from_bill(payload: dict):
    text = payload.get("text") or payload.get("billText") or ""
    if not text:
        raise HTTPException(status_code=400, detail="bill text is required")
    products = products_from_bill_text(text)
    return {"count": len(products), "products": products}


@app.post("/ai/product-from-photo")
async def ai_product_from_photo(
    image: UploadFile = File(...),
    notes: str = Form(default=""),
):
    data = await image.read()
    return product_from_upload(image.filename or "product-photo", data, notes)


@app.post("/bulk-products")
def add_bulk_products(payload: dict):
    products = payload.get("products")
    if not isinstance(products, list):
        raise HTTPException(status_code=400, detail="products array is required")

    saved = []
    for item in products:
        product = normalize_product(item)
        doc_id = product.pop("id")
        db.collection("products").document(doc_id).set(product)
        saved.append(doc_id)
    return {"message": "Bulk products saved", "count": len(saved), "ids": saved}


@app.post("/bulk-products/csv")
async def add_bulk_products_csv(file: UploadFile = File(...)):
    data = await file.read()
    products = products_from_csv_bytes(data)
    saved = []
    for product in products:
        doc_id = product.pop("id")
        db.collection("products").document(doc_id).set(product)
        saved.append(doc_id)
    return {"message": "CSV products saved", "count": len(saved), "ids": saved}
