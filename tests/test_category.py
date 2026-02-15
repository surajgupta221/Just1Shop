import requests
import uuid


def make_sample_category():
    return {
        # omit `id` to let Firestore generate one, or set an id string
        # "id": "cat-" + str(uuid.uuid4()),
        "category": "Skin & Face Care",
        "imgUrl": "https://firebasestorage.googleapis.com/v0/b/just1shop.appspot.com/o/categories%2Fskin-care.jpg"
    }


def test_get_categories():
    url = "http://127.0.0.1:8000/category_master"
    r = requests.get(url)
    print("GET /category_master")
    print("status:", r.status_code)
    print("response:", r.text)
    print()


def test_post_category():
    url = "http://127.0.0.1:8000/add-category"
    payload = make_sample_category()
    r = requests.post(url, json=payload)
    print("POST /add-category")
    print("status:", r.status_code)
    print("response:", r.text)
    print()


def test_delete_category(category_id: str):
    url = f"http://127.0.0.1:8000/delete-category/{category_id}"
    r = requests.delete(url)
    print(f"DELETE /delete-category/{category_id}")
    print("status:", r.status_code)
    print("response:", r.text)
    print()


if __name__ == "__main__":
    # Test GET
    test_get_categories()
    
    # Test POST
    test_post_category()
    
    # Test GET again to see the new category
    test_get_categories()

