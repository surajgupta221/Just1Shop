import requests
import uuid


def make_sample_banner():
    return {
        # omit `id` to let Firestore generate one, or set an id string
        # "id": "banner-" + str(uuid.uuid4()),
        "heading": "Flash Sale",
        "imgUrl": "https://firebasestorage.googleapis.com/v0/b/just1shop.appspot.com/o/banners%2Fflash-sale.jpg",
        "relatedProducts": [
            "IoEUBSgN9SpOC7S2E1vP",
            "SX4AC3FgJ9xrQRp8sh1Y"
        ]
    }


def test_get_banners():
    url = "http://127.0.0.1:8000/banner"
    r = requests.get(url)
    print("GET /banner")
    print("status:", r.status_code)
    print("response:", r.text)
    print()


def test_post_banner():
    url = "http://127.0.0.1:8000/add-banner"
    payload = make_sample_banner()
    r = requests.post(url, json=payload)
    print("POST /add-banner")
    print("status:", r.status_code)
    print("response:", r.text)
    print()


def test_delete_banner(banner_id: str):
    url = f"http://127.0.0.1:8000/delete-banner/{banner_id}"
    r = requests.delete(url)
    print(f"DELETE /delete-banner/{banner_id}")
    print("status:", r.status_code)
    print("response:", r.text)
    print()


if __name__ == "__main__":
    # Test GET
    test_get_banners()
    
    # Test POST
    test_post_banner()
    
    # Test GET again to see the new banner
    test_get_banners()

