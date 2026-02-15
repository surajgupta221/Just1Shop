import requests
import uuid


def make_sample():
    return {
        # omit `id` to let Firestore generate one, or set an id string
        # "id": "test-" + str(uuid.uuid4()),
        "category": "Spices",
        "date": "2024-08-23T10:15:38Z",
        "description": "",
        "featured": False,
        "imageUrl": [
            "https://firebasestorage.googleapis.com/v0/b/just1shop.appspot.com/..."
        ],
        "min_price": 800,
        "productname": "Badi Eliechi (test)",
        "sku": "garam-test",
        "stocks": 500,
        "sub_category": "Spices & Seasonings"
    }


def test_post():
    url = "http://127.0.0.1:8000/add-product"
    payload = make_sample()
    r = requests.post(url, json=payload)
    print("status:", r.status_code)
    print("response:", r.text)


if __name__ == "__main__":
    test_post()
