import json
from pathlib import Path
from datetime import datetime, timezone

from firebase_admin import credentials, firestore, initialize_app


def parse_iso_timestamp(s: str):
    # Accepts ISO like 2024-08-23T10:15:38Z
    if s.endswith("Z"):
        s = s[:-1] + "+00:00"
    return datetime.fromisoformat(s)


def import_products(db=None, data_path: Path | None = None):
    root = Path(__file__).parent
    # allow custom data path for testing
    data_file = Path(data_path) if data_path else (root / "product_spices.json")
    if not data_file.exists():
        raise SystemExit("product_spices.json not found.")

    # If no Firestore client provided, initialize using local service account
    if db is None:
        cred_file = root / "serviceAccountKey.json"
        if not cred_file.exists():
            raise SystemExit("serviceAccountKey.json not found in project root.")

        cred = credentials.Certificate(str(cred_file))
        # initialize_app may be called elsewhere; avoid double-init
        try:
            initialize_app(cred)
        except Exception:
            # already initialized
            pass
        db = firestore.client()

    with open(data_file, "r", encoding="utf-8") as f:
        items = json.load(f)

    for item in items:
        doc_id = item.get("id")
        payload = item.copy()
        if "id" in payload:
            del payload["id"]

        # Convert date string to python datetime for Firestore
        if isinstance(payload.get("date"), str) and payload.get("date"):
            try:
                payload["date"] = parse_iso_timestamp(payload["date"]) 
            except Exception:
                # leave as-is if parsing fails
                pass

        coll = db.collection("products")
        if doc_id:
            doc_ref = coll.document(doc_id)
            doc_ref.set(payload)
            print(f"Written document with id={doc_id}")
        else:
            doc_ref = coll.add(payload)
            print(f"Added document: {doc_ref}")


def import_categories(db=None, data_path: Path | None = None):
    root = Path(__file__).parent
    # allow custom data path for testing
    data_file = Path(data_path) if data_path else (root / "category_master.json")
    if not data_file.exists():
        raise SystemExit("category_master.json not found.")

    # If no Firestore client provided, initialize using local service account
    if db is None:
        cred_file = root / "serviceAccountKey.json"
        if not cred_file.exists():
            raise SystemExit("serviceAccountKey.json not found in project root.")

        cred = credentials.Certificate(str(cred_file))
        # initialize_app may be called elsewhere; avoid double-init
        try:
            initialize_app(cred)
        except Exception:
            # already initialized
            pass
        db = firestore.client()

    with open(data_file, "r", encoding="utf-8") as f:
        items = json.load(f)

    for item in items:
        doc_id = item.get("id")
        payload = item.copy()
        if "id" in payload:
            del payload["id"]

        coll = db.collection("category_master")
        if doc_id:
            doc_ref = coll.document(doc_id)
            doc_ref.set(payload)
            print(f"Written category with id={doc_id}")
        else:
            doc_ref = coll.add(payload)
            print(f"Added category: {doc_ref}")


def import_sub_categories(db=None, data_path: Path | None = None):
    root = Path(__file__).parent
    # allow custom data path for testing
    data_file = Path(data_path) if data_path else (root / "sub_category_master.json")
    if not data_file.exists():
        raise SystemExit("sub_category_master.json not found.")

    # If no Firestore client provided, initialize using local service account
    if db is None:
        cred_file = root / "serviceAccountKey.json"
        if not cred_file.exists():
            raise SystemExit("serviceAccountKey.json not found in project root.")

        cred = credentials.Certificate(str(cred_file))
        # initialize_app may be called elsewhere; avoid double-init
        try:
            initialize_app(cred)
        except Exception:
            # already initialized
            pass
        db = firestore.client()

    with open(data_file, "r", encoding="utf-8") as f:
        items = json.load(f)

    for item in items:
        doc_id = item.get("id")
        payload = item.copy()
        if "id" in payload:
            del payload["id"]

        coll = db.collection("sub_category_master")
        if doc_id:
            doc_ref = coll.document(doc_id)
            doc_ref.set(payload)
            print(f"Written sub category with id={doc_id}")
        else:
            doc_ref = coll.add(payload)
            print(f"Added sub category: {doc_ref}")


def import_banners(db=None, data_path: Path | None = None):
    root = Path(__file__).parent
    # allow custom data path for testing
    data_file = Path(data_path) if data_path else (root / "banner.json")
    if not data_file.exists():
        raise SystemExit("banner.json not found.")

    # If no Firestore client provided, initialize using local service account
    if db is None:
        cred_file = root / "serviceAccountKey.json"
        if not cred_file.exists():
            raise SystemExit("serviceAccountKey.json not found in project root.")

        cred = credentials.Certificate(str(cred_file))
        # initialize_app may be called elsewhere; avoid double-init
        try:
            initialize_app(cred)
        except Exception:
            # already initialized
            pass
        db = firestore.client()

    with open(data_file, "r", encoding="utf-8") as f:
        items = json.load(f)

    for item in items:
        doc_id = item.get("id")
        payload = item.copy()
        if "id" in payload:
            del payload["id"]

        coll = db.collection("banner")
        if doc_id:
            doc_ref = coll.document(doc_id)
            doc_ref.set(payload)
            print(f"Written banner with id={doc_id}")
        else:
            doc_ref = coll.add(payload)
            print(f"Added banner: {doc_ref}")


def import_offers(db=None, data_path: Path | None = None):
    root = Path(__file__).parent
    # allow custom data path for testing
    data_file = Path(data_path) if data_path else (root / "offer.json")
    if not data_file.exists():
        raise SystemExit("offer.json not found.")

    # If no Firestore client provided, initialize using local service account
    if db is None:
        cred_file = root / "serviceAccountKey.json"
        if not cred_file.exists():
            raise SystemExit("serviceAccountKey.json not found in project root.")

        cred = credentials.Certificate(str(cred_file))
        # initialize_app may be called elsewhere; avoid double-init
        try:
            initialize_app(cred)
        except Exception:
            # already initialized
            pass
        db = firestore.client()

    with open(data_file, "r", encoding="utf-8") as f:
        items = json.load(f)

    for item in items:
        doc_id = item.get("id")
        payload = item.copy()
        if "id" in payload:
            del payload["id"]

        # Convert ISO date/datetime strings to datetime for Firestore timestamps
        for date_field in ["createdAt", "validTill"]:
            if isinstance(payload.get(date_field), str) and payload.get(date_field):
                try:
                    payload[date_field] = parse_iso_timestamp(payload[date_field])
                except Exception:
                    pass

        coll = db.collection("offer")
        if doc_id:
            doc_ref = coll.document(doc_id)
            doc_ref.set(payload)
            print(f"Written offer with id={doc_id}")
        else:
            doc_ref = coll.add(payload)
            print(f"Added offer: {doc_ref}")


def import_festival_offers(db=None, data_path: Path | None = None):
    root = Path(__file__).parent
    # allow custom data path for testing
    data_file = Path(data_path) if data_path else (root / "festivalOffer.json")
    if not data_file.exists():
        raise SystemExit("festivalOffer.json not found.")

    # If no Firestore client provided, initialize using local service account
    if db is None:
        cred_file = root / "serviceAccountKey.json"
        if not cred_file.exists():
            raise SystemExit("serviceAccountKey.json not found in project root.")

        cred = credentials.Certificate(str(cred_file))
        # initialize_app may be called elsewhere; avoid double-init
        try:
            initialize_app(cred)
        except Exception:
            # already initialized
            pass
        db = firestore.client()

    with open(data_file, "r", encoding="utf-8") as f:
        items = json.load(f)

    for item in items:
        doc_id = item.get("id")
        payload = item.copy()
        if "id" in payload:
            del payload["id"]

        # Convert createdAt timestamp at root level
        if isinstance(payload.get("createdAt"), str) and payload.get("createdAt"):
            try:
                payload["createdAt"] = parse_iso_timestamp(payload["createdAt"])
            except Exception:
                pass

        # Convert createdAt timestamps in festivalDetail array
        if "festivalDetail" in payload and isinstance(payload["festivalDetail"], list):
            for detail in payload["festivalDetail"]:
                if isinstance(detail, dict) and isinstance(detail.get("createdAt"), str):
                    try:
                        detail["createdAt"] = parse_iso_timestamp(detail["createdAt"])
                    except Exception:
                        pass

        coll = db.collection("festivalOffers")
        if doc_id:
            doc_ref = coll.document(doc_id)
            doc_ref.set(payload)
            print(f"Written festival offer with id={doc_id}")
        else:
            doc_ref = coll.add(payload)
            print(f"Added festival offer: {doc_ref}")


def import_addresses(db=None, data_path: Path | None = None):
    root = Path(__file__).parent
    # allow custom data path for testing
    data_file = Path(data_path) if data_path else (root / "address.json")
    if not data_file.exists():
        raise SystemExit("address.json not found.")

    # If no Firestore client provided, initialize using local service account
    if db is None:
        cred_file = root / "serviceAccountKey.json"
        if not cred_file.exists():
            raise SystemExit("serviceAccountKey.json not found in project root.")

        cred = credentials.Certificate(str(cred_file))
        # initialize_app may be called elsewhere; avoid double-init
        try:
            initialize_app(cred)
        except Exception:
            # already initialized
            pass
        db = firestore.client()

    with open(data_file, "r", encoding="utf-8") as f:
        items = json.load(f)

    for item in items:
        doc_id = item.get("id")
        payload = item.copy()
        if "id" in payload:
            del payload["id"]

        # Convert createdAt timestamp
        if isinstance(payload.get("createdAt"), str) and payload.get("createdAt"):
            try:
                payload["createdAt"] = parse_iso_timestamp(payload["createdAt"])
            except Exception:
                pass

        coll = db.collection("address")
        if doc_id:
            doc_ref = coll.document(doc_id)
            doc_ref.set(payload)
            print(f"Written address with id={doc_id}")
        else:
            doc_ref = coll.add(payload)
            print(f"Added address: {doc_ref}")


def main():
    import_products()
    import_categories()
    import_sub_categories()
    import_banners()
    import_offers()
    import_festival_offers()
    import_addresses()


if __name__ == "__main__":
    main()
