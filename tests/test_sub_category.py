import requests
import uuid


def make_sample_sub_category():
    return {
        # omit `id` to let Firestore generate one, or set an id string
        # "id": "subcat-" + str(uuid.uuid4()),
        "category": "House Hold",
        "imageUrl": "https://firebasestorage.googleapis.com/v0/b/just1shop.appspot.com/o/subcategories%2Fglass-cleaners.jpg",
        "sub_category": "Glass Cleaners",
        "sub_index": 1
    }


def test_get_sub_categories():
    url = "http://127.0.0.1:8000/sub_category_master"
    r = requests.get(url)
    print("GET /sub_category_master")
    print("status:", r.status_code)
    print("response:", r.text)
    print()


def test_post_sub_category():
    url = "http://127.0.0.1:8000/add-sub-category"
    payload = make_sample_sub_category()
    r = requests.post(url, json=payload)
    print("POST /add-sub-category")
    print("status:", r.status_code)
    print("response:", r.text)
    print()


def test_delete_sub_category(sub_category_id: str):
    url = f"http://127.0.0.1:8000/delete-sub-category/{sub_category_id}"
    r = requests.delete(url)
    print(f"DELETE /delete-sub-category/{sub_category_id}")
    print("status:", r.status_code)
    print("response:", r.text)
    print()


if __name__ == "__main__":
    # Test GET
    test_get_sub_categories()
    
    # Test POST
    test_post_sub_category()
    
    # Test GET again to see the new sub category
    test_get_sub_categories()

