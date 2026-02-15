import requests
import uuid


def make_sample_offer():
    return {
        # omit `id` to let Firestore generate one, or set an id string
        # "id": "offer-" + str(uuid.uuid4()),
        "productId": "prod_12345",
        "title": "Summer Sale - 30% Off",
        "discountPercent": 30,
        "validTill": "2026-03-31",
        "createdAt": "2026-02-15T10:00:00Z"
    }


def test_get_offers():
    url = "http://127.0.0.1:8000/offer"
    r = requests.get(url)
    print("GET /offer")
    print("status:", r.status_code)
    print("response:", r.text)
    print()


def test_post_offer():
    url = "http://127.0.0.1:8000/add-offer"
    payload = make_sample_offer()
    r = requests.post(url, json=payload)
    print("POST /add-offer")
    print("status:", r.status_code)
    print("response:", r.text)
    print()


def test_delete_offer(offer_id: str):
    url = f"http://127.0.0.1:8000/delete-offer/{offer_id}"
    r = requests.delete(url)
    print(f"DELETE /delete-offer/{offer_id}")
    print("status:", r.status_code)
    print("response:", r.text)
    print()


if __name__ == "__main__":
    # Test GET
    test_get_offers()
    
    # Test POST
    test_post_offer()
    
    # Test GET again to see the new offer
    test_get_offers()

