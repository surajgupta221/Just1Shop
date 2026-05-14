import os
import requests
from flask import Flask, render_template, request, jsonify, redirect, url_for
from dotenv import load_dotenv
import json
from datetime import datetime
import base64

# Load environment variables
load_dotenv()

app = Flask(__name__)

# Configuration
BACKEND_URL = os.getenv("BACKEND_URL", "http://127.0.0.1:8000")

# Helper function to make API requests
def api_request(method, endpoint, data=None):
    """Make HTTP request to backend API"""
    url = f"{BACKEND_URL}{endpoint}"
    try:
        if method == "GET":
            response = requests.get(url, timeout=5)
        elif method == "POST":
            response = requests.post(url, json=data, timeout=5)
        elif method == "DELETE":
            response = requests.delete(url, timeout=5)

        # Raise for HTTP error codes
        response.raise_for_status()

        # Try to parse JSON, otherwise return raw text
        if response.text:
            try:
                return response.json()
            except ValueError:
                return {"text": response.text}
        return {}
    except requests.exceptions.RequestException as e:
        print(f"API Error calling {url}: {e}")
        return {"error": f"{e}"}


# Routes
@app.route("/")
def index():
    """Dashboard home page"""
    return render_template("index.html")


# --- PRODUCTS ENDPOINTS ---
@app.route("/products")
def products():
    """Display all products"""
    products_data = api_request("GET", "/products")
    return render_template("products.html", products=products_data, BACKEND_URL=BACKEND_URL)


@app.route("/add-product", methods=["GET", "POST"])
def add_product():
    """Add new product"""
    if request.method == "POST":
        product_data = request.form.to_dict()
        
        # Handle numeric fields
        product_data["min_price"] = int(product_data.get("min_price", 0))
        product_data["stocks"] = int(product_data.get("stocks", 0))
        product_data["featured"] = request.form.get("featured") == "on"
        
        # handle uploaded image file (multipart form)
        image = request.files.get("image")
        if image and image.filename:
            data = image.read()
            b64 = base64.b64encode(data).decode('utf-8')
            product_data["imageData"] = b64
            product_data["imageFilename"] = image.filename

        result = api_request("POST", "/add-product", product_data)
        
        if "error" not in result:
            return render_template("add_product.html", message="Product added successfully!")
        else:
            return render_template("add_product.html", error=result.get("error"))
    
    # if editing an existing product (query param ?id=...), prefill form
    product_id = request.args.get('id')
    if product_id and request.method == 'GET':
        products = api_request("GET", "/products")
        existing = None
        if isinstance(products, list):
            for p in products:
                if p.get('id') == product_id:
                    existing = p
                    break
        return render_template("add_product.html", product=existing)

    return render_template("add_product.html")


@app.route("/delete-product/<product_id>", methods=["DELETE"])
def delete_product(product_id):
    """Delete product"""
    result = api_request("DELETE", f"/delete-product/{product_id}")
    return jsonify(result)


# --- CATEGORIES ENDPOINTS ---
@app.route("/categories")
def categories():
    """Display all categories"""
    categories_data = api_request("GET", "/category_master")
    return render_template("categories.html", categories=categories_data, BACKEND_URL=BACKEND_URL)


@app.route("/add-category", methods=["GET", "POST"])
def add_category():
    """Add new category"""
    if request.method == "POST":
        category_data = request.form.to_dict()
        # handle uploaded image file
        image = request.files.get("image")
        if image and image.filename:
            data = image.read()
            b64 = base64.b64encode(data).decode('utf-8')
            category_data["imageData"] = b64
            category_data["imageFilename"] = image.filename
        result = api_request("POST", "/add-category", category_data)
        if "error" not in result:
            return redirect(url_for('categories'))
        else:
            return render_template("add_category.html", error=result.get("error"))
    
    # support edit prefill when ?id=<category_id>
    category_id = request.args.get('id')
    if category_id and request.method == 'GET':
        categories = api_request("GET", "/category_master")
        existing = None
        if isinstance(categories, list):
            for c in categories:
                if c.get('id') == category_id:
                    existing = c
                    break
        return render_template("add_category.html", category=existing)

    return render_template("add_category.html")


@app.route("/delete-category/<category_id>", methods=["DELETE"])
def delete_category(category_id):
    """Delete category"""
    result = api_request("DELETE", f"/delete-category/{category_id}")
    return jsonify(result)


# --- SUB-CATEGORIES ENDPOINTS ---
@app.route("/sub-categories")
def sub_categories():
    """Display all sub-categories"""
    sub_categories_data = api_request("GET", "/sub_category_master")
    # If the backend returned an error dict, show an empty list to avoid template errors
    if isinstance(sub_categories_data, dict) and sub_categories_data.get("error"):
        sub_categories_data = []

    # Try to fetch categories to resolve parent names for display
    categories_data = api_request("GET", "/category_master")
    categories_map = {}
    if isinstance(categories_data, list):
        for c in categories_data:
            cid = c.get('id')
            # common name fields: 'category' or 'name' or 'title'
            name = c.get('category') or c.get('name') or c.get('title') or cid
            categories_map[cid] = name

    return render_template("sub_categories.html", sub_categories=sub_categories_data, categories_map=categories_map, BACKEND_URL=BACKEND_URL)


@app.route("/add-sub-category", methods=["GET", "POST"])
def add_sub_category():
    """Add new sub-category"""
    if request.method == "POST":
        sub_category_data = request.form.to_dict()
        sub_category_data["sub_index"] = int(sub_category_data.get("sub_index", 1))
        
        result = api_request("POST", "/add-sub-category", sub_category_data)
        
        if "error" not in result:
            return render_template("add_sub_category.html", message="Sub-category added successfully!")
        else:
            return render_template("add_sub_category.html", error=result.get("error"))
    
    return render_template("add_sub_category.html")


@app.route("/delete-sub-category/<sub_category_id>", methods=["DELETE"])
def delete_sub_category(sub_category_id):
    """Delete sub-category"""
    result = api_request("DELETE", f"/delete-sub-category/{sub_category_id}")
    return jsonify(result)


# --- BANNERS ENDPOINTS ---
@app.route("/banners")
def banners():
    """Display all banners"""
    banners_data = api_request("GET", "/banner")
    # If backend returned an error, pass it to the template so it's visible to the user
    if isinstance(banners_data, dict) and banners_data.get('error'):
        error_msg = banners_data.get('error')
        return render_template("banners.html", banners=[], error=error_msg, BACKEND_URL=BACKEND_URL)

    return render_template("banners.html", banners=banners_data, BACKEND_URL=BACKEND_URL)


@app.route("/add-banner", methods=["GET", "POST"])
def add_banner():
    """Add new banner"""
    if request.method == "POST":
        banner_data = request.form.to_dict()
        # Parse relatedProducts as array
        raw_related = request.form.get("relatedProducts", "")
        # support either a JSON-like array or comma-separated string
        related_products = []
        if raw_related:
            raw_related = raw_related.strip()
            # if looks like JSON array, try to parse
            if raw_related.startswith("[") and raw_related.endswith("]"):
                try:
                    parsed = json.loads(raw_related)
                    if isinstance(parsed, list):
                        related_products = parsed
                except Exception:
                    # fall back to comma-split
                    pass
            if not related_products:
                parts = raw_related.split(",")
                for p in parts:
                    v = p.strip()
                    if not v:
                        continue
                    # coerce numeric ids to int if possible
                    if v.isdigit():
                        related_products.append(int(v))
                    else:
                        # try to parse numeric-like strings (e.g., '123.0')
                        try:
                            if "." in v:
                                fv = float(v)
                                # if whole number, convert to int
                                if fv.is_integer():
                                    related_products.append(int(fv))
                                else:
                                    related_products.append(fv)
                            else:
                                related_products.append(v)
                        except Exception:
                            related_products.append(v)

        banner_data["relatedProducts"] = related_products
        
        result = api_request("POST", "/add-banner", banner_data)
        
        if "error" not in result:
            return render_template("add_banner.html", message="Banner added successfully!")
        else:
            return render_template("add_banner.html", error=result.get("error"))
    
    return render_template("add_banner.html")


@app.route("/delete-banner/<banner_id>", methods=["DELETE"])
def delete_banner(banner_id):
    """Delete banner"""
    result = api_request("DELETE", f"/delete-banner/{banner_id}")
    return jsonify(result)


# --- OFFERS ENDPOINTS ---
@app.route("/offers")
def offers():
    """Display all offers"""
    offers_data = api_request("GET", "/offer")
    return render_template("offers.html", offers=offers_data)


@app.route("/add-offer", methods=["GET", "POST"])
def add_offer():
    """Add new offer"""
    if request.method == "POST":
        offer_data = request.form.to_dict()

        # Safely parse discountPercent (handle empty string or non-numeric)
        dp_raw = offer_data.get("discountPercent", "")
        try:
            if dp_raw is None or str(dp_raw).strip() == "":
                offer_data["discountPercent"] = 0
            else:
                # allow floats like '10.0' but store as int
                offer_data["discountPercent"] = int(float(dp_raw))
        except Exception:
            offer_data["discountPercent"] = 0

        # Created timestamp
        offer_data["createdAt"] = datetime.utcnow().isoformat() + "Z"

        # Offer applicability: 'all' | 'product' | 'category' | 'sub_category'
        offer_data["applyTo"] = request.form.get("applyTo", "all")
        # target id (productId, categoryId, etc.)
        target = request.form.get("targetId") or request.form.get("productId")
        if target:
            offer_data["targetId"] = target

        result = api_request("POST", "/add-offer", offer_data)

        if "error" not in result:
            return render_template("add_offer.html", message="Offer added successfully!")
        else:
            return render_template("add_offer.html", error=result.get("error"))

    # support edit prefill when ?id=... (GET)
    offer_id = request.args.get('id')
    if offer_id and request.method == 'GET':
        offers = api_request("GET", "/offer")
        existing = None
        if isinstance(offers, list):
            for o in offers:
                if o.get('id') == offer_id:
                    existing = o
                    break
        return render_template("add_offer.html", offer=existing)

    return render_template("add_offer.html")


@app.route("/delete-offer/<offer_id>", methods=["DELETE"])
def delete_offer(offer_id):
    """Delete offer"""
    result = api_request("DELETE", f"/delete-offer/{offer_id}")
    return jsonify(result)


# --- FESTIVAL OFFERS ENDPOINTS ---
@app.route("/festival-offers")
def festival_offers():
    """Display all festival offers"""
    festival_offers_data = api_request("GET", "/festivalOffers")
    return render_template("festival_offers.html", festival_offers=festival_offers_data)


@app.route("/add-festival-offer", methods=["GET", "POST"])
def add_festival_offer():
    """Add new festival offer"""
    if request.method == "POST":
        festival_offer_data = request.form.to_dict()
        
        result = api_request("POST", "/add-festivalOffer", festival_offer_data)
        
        if "error" not in result:
            return render_template("add_festival_offer.html", message="Festival offer added successfully!")
        else:
            return render_template("add_festival_offer.html", error=result.get("error"))
    
    return render_template("add_festival_offer.html")


@app.route("/delete-festival-offer/<festival_offer_id>", methods=["DELETE"])
def delete_festival_offer(festival_offer_id):
    """Delete festival offer"""
    result = api_request("DELETE", f"/delete-festivalOffer/{festival_offer_id}")
    return jsonify(result)


# --- ADDRESSES ENDPOINTS ---
@app.route("/addresses")
def addresses():
    """Display all addresses"""
    addresses_data = api_request("GET", "/address")
    return render_template("addresses.html", addresses=addresses_data)


@app.route("/add-address", methods=["GET", "POST"])
def add_address():
    """Add new address"""
    if request.method == "POST":
        address_data = request.form.to_dict()
        
        # Parse location coordinates
        address_data["location"] = {
            "latitude": float(address_data.get("latitude", 0)),
            "longitude": float(address_data.get("longitude", 0))
        }
        
        address_data["isDefault"] = request.form.get("isDefault") == "on"
        address_data["createdAt"] = datetime.utcnow().isoformat() + "Z"
        
        # Remove individual lat/long fields
        address_data.pop("latitude", None)
        address_data.pop("longitude", None)
        
        result = api_request("POST", "/add-address", address_data)
        
        if "error" not in result:
            return render_template("add_address.html", message="Address added successfully!")
        else:
            return render_template("add_address.html", error=result.get("error"))
    
    return render_template("add_address.html")


@app.route("/delete-address/<address_id>", methods=["DELETE"])
def delete_address(address_id):
    """Delete address"""
    result = api_request("DELETE", f"/delete-address/{address_id}")
    return jsonify(result)


# Error handlers
@app.errorhandler(404)
def not_found(error):
    return render_template("404.html"), 404


@app.errorhandler(500)
def server_error(error):
    return render_template("500.html", error=str(error)), 500


if __name__ == "__main__":
    app.run(debug=True, host="127.0.0.1", port=5000)
