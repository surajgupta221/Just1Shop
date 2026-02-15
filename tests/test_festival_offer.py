import requests
import uuid


def make_sample_festival_offer():
    return {
        # omit `id` to let Firestore generate one, or set an id string
        # "id": "festival-" + str(uuid.uuid4()),
        "createdAt": "2024-12-01T10:00:00.000Z",
        "festivalDetail": [
            {
                "createdAt": "2024-12-01T10:30:00.000Z",
                "imgUrl": "https://firebasestorage.googleapis.com/v0/b/just1shop.appspot.com/o/festivals%2Fyear-end-sale.jpg",
                "name": "Electronics",
                "relatedProducts": [
                    "prod_12345",
                    "prod_67890"
                ]
            }
        ]
    }


def test_get_festival_offers():
    url = "http://127.0.0.1:8000/festivalOffers"
    r = requests.get(url)
    print("GET /festivalOffers")
    print("status:", r.status_code)
    print("response:", r.text)
    print()


def test_post_festival_offer():
    url = "http://127.0.0.1:8000/add-festivalOffer"
    payload = make_sample_festival_offer()
    r = requests.post(url, json=payload)
    print("POST /add-festivalOffer")
    print("status:", r.status_code)
    print("response:", r.text)
    print()


def test_delete_festival_offer(festival_offer_id: str):
    url = f"http://127.0.0.1:8000/delete-festivalOffer/{festival_offer_id}"
    r = requests.delete(url)
    print(f"DELETE /delete-festivalOffer/{festival_offer_id}")
    print("status:", r.status_code)
    print("response:", r.text)
    print()


if __name__ == "__main__":
    # Test GET
    test_get_festival_offers()
    
    # Test POST
    test_post_festival_offer()
    
    # Test GET again to see the new festival offer
    test_get_festival_offers()

