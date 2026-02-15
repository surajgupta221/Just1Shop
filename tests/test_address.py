import requests
import uuid


def make_sample_address():
    return {
        # omit `id` to let Firestore generate one, or set an id string
        # "id": "addr-" + str(uuid.uuid4()),
        "receiverName": "John Doe",
        "phoneNumber": "+919999888877",
        "addressType": "home",
        "addressLine1": "Flat 101, Maple Gardens",
        "addressLine2": "Sector 20",
        "landmark": "Near School",
        "city": "Bangalore",
        "state": "Karnataka",
        "pincode": "560001",
        "country": "India",
        "location": {
            "latitude": 12.9716,
            "longitude": 77.5946
        },
        "isDefault": False,
        "createdAt": "2026-02-15T12:00:00Z"
    }


def test_get_addresses():
    url = "http://127.0.0.1:8000/address"
    r = requests.get(url)
    print("GET /address")
    print("status:", r.status_code)
    print("response:", r.text)
    print()


def test_post_address():
    url = "http://127.0.0.1:8000/add-address"
    payload = make_sample_address()
    r = requests.post(url, json=payload)
    print("POST /add-address")
    print("status:", r.status_code)
    print("response:", r.text)
    print()


def test_delete_address(address_id: str):
    url = f"http://127.0.0.1:8000/delete-address/{address_id}"
    r = requests.delete(url)
    print(f"DELETE /delete-address/{address_id}")
    print("status:", r.status_code)
    print("response:", r.text)
    print()


if __name__ == "__main__":
    # Test GET
    test_get_addresses()
    
    # Test POST
    test_post_address()
    
    # Test GET again to see the new address
    test_get_addresses()

