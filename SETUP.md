# Just1Shop Backend - Setup Guide

## Prerequisites

- Python 3.10+
- pip (Python package manager)

## Installation

### 1. Clone and setup virtual environment

```bash
cd just1shop-backend
python -m venv venv

# On Windows
venv\Scripts\activate

# On macOS/Linux
source venv/bin/activate
```

### 2. Install dependencies

```bash
pip install -r requirements.txt
```

### 3. Get Firebase credentials

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project (Just1Shop)
3. Click **Project Settings** (gear icon)
4. Go to **Service Accounts** tab
5. Click **Generate New Private Key**
6. Save the downloaded JSON file as `serviceAccountKey.json` in the project root

⚠️ **Important:** Never commit `serviceAccountKey.json` to git. It's already in `.gitignore`.

### 4. Configure environment (optional)

Edit `.env` if you need custom settings:

```bash
FIREBASE_CREDENTIALS_PATH=serviceAccountKey.json
API_HOST=127.0.0.1
API_PORT=8000
API_RELOAD=true
ENVIRONMENT=development
```

### 5. Run the server

```bash
uvicorn main:app --reload
```

Server will start at `http://127.0.0.1:8000`

### 6. Test the API

Visit http://127.0.0.1:8000/docs for interactive API documentation (Swagger UI)

## API Endpoints

### Products
- `GET /products` — Get all products
- `POST /add-product` — Add new product
- `DELETE /delete-product/{product_id}` — Delete product

### Categories
- `GET /category_master` — Get all categories
- `POST /add-category` — Add new category
- `DELETE /delete-category/{category_id}` — Delete category

### Sub-Categories
- `GET /sub_category_master` — Get all sub-categories
- `POST /add-sub-category` — Add new sub-category
- `DELETE /delete-sub-category/{sub_category_id}` — Delete sub-category

### Banners
- `GET /banner` — Get all banners
- `POST /add-banner` — Add new banner
- `DELETE /delete-banner/{banner_id}` — Delete banner

### Offers
- `GET /offer` — Get all offers
- `POST /add-offer` — Add new offer
- `DELETE /delete-offer/{offer_id}` — Delete offer

### Festival Offers
- `GET /festivalOffers` — Get all festival offers
- `POST /add-festivalOffer` — Add new festival offer
- `DELETE /delete-festivalOffer/{festival_offer_id}` — Delete festival offer

### Addresses
- `GET /address` — Get all addresses
- `POST /add-address` — Add new address
- `DELETE /delete-address/{address_id}` — Delete address

## Troubleshooting

**Error: FileNotFoundError: serviceAccountKey.json not found**

→ Download your Firebase credentials and save as `serviceAccountKey.json` in project root (see step 3 above)

**Error: ModuleNotFoundError: No module named 'firebase_admin'**

→ Run `pip install -r requirements.txt` to install all dependencies

**Error on import: "kivy_deps.sdl2_dev not found"**

→ This is not needed for the backend. You can safely ignore.

## Project Structure

```
just1shop-backend/
├── main.py                    # FastAPI app and endpoints
├── import_product.py          # Data import functions
├── requirements.txt           # Python dependencies
├── .env                       # Environment variables (create after credentials)
├── .gitignore                 # Git ignore rules
├── SETUP.md                   # This file
├── serviceAccountKey.json     # Firebase credentials (DO NOT COMMIT)
├── product_spices.json        # Sample products
├── category_master.json       # Sample categories
├── sub_category_master.json   # Sample sub-categories
├── banner.json                # Sample banners
├── offer.json                 # Sample offers
├── festivalOffer.json         # Sample festival offers
├── address.json               # Sample addresses
└── tests/                     # Test scripts
    ├── test_add_product.py
    ├── test_category.py
    ├── test_sub_category.py
    ├── test_banner.py
    ├── test_offer.py
    ├── test_festival_offer.py
    └── test_address.py
```

## Development

To test endpoints manually:

```bash
# Test products endpoint
curl http://127.0.0.1:8000/products

# Add a new product
curl -X POST http://127.0.0.1:8000/add-product \
  -H "Content-Type: application/json" \
  -d '{"category":"Spices","productname":"Test","min_price":100,"stocks":50}'
```

Or run the test scripts:

```bash
python tests/test_add_product.py
python tests/test_category.py
python tests/test_banner.py
```

## Support

For issues or questions, check the API docs at `http://localhost:8000/docs`
