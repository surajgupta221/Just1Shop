# ðŸ›ï¸ Just1Shop â€” Full Stack E-Commerce Platform

![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=for-the-badge&logo=python&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-0.100+-009688?style=for-the-badge&logo=fastapi&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-Frontend-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

> A modern, full-stack e-commerce platform with a **Python FastAPI backend** and Flutter mobile frontend. Just1Shop enables seamless online shopping with AI-powered product recommendations, secure payments, and a powerful admin dashboard.

---

## ðŸ“± App Preview

> *(Add screenshots of your app here)*

---

## âœ¨ Features

### ðŸ” User Authentication
- Secure registration and login with JWT token-based authentication
- Password hashing and session management
- Role-based access control (Customer / Admin)

### ðŸ›’ Product Listing & Search
- Browse products by category, price, and ratings
- Full-text search with filters and sorting
- Product detail pages with images and descriptions

### ðŸ§º Cart & Orders
- Add/remove items from cart in real time
- Place orders with order history tracking
- Order status updates (Pending â†’ Processing â†’ Shipped â†’ Delivered)

### ðŸ’³ Payment Integration
- Secure online payment gateway integration
- Payment confirmation and invoice generation
- Transaction history for users

### ðŸ¤– AI-Powered Recommendations
- Personalized product recommendations based on browsing and purchase history
- "Customers also bought" suggestions
- Smart search with relevance ranking

### ðŸ–¥ï¸ Admin Dashboard
- Manage products, categories, and inventory
- View and update order statuses
- User management and analytics overview
- Sales reports and revenue tracking

---

## ðŸ—ï¸ Tech Stack

### Backend (Python)
| Technology | Purpose |
|---|---|
| **FastAPI** | REST API framework |
| **Python 3.10+** | Core backend language |
| **SQLAlchemy** | ORM for database management |
| **PostgreSQL / SQLite** | Database |
| **JWT (jose)** | Authentication tokens |
| **Pydantic** | Data validation and serialization |
| **Uvicorn** | ASGI server |

### Frontend
| Technology | Purpose |
|---|---|
| **Flutter / Dart** | Cross-platform mobile app |
| **Provider / Riverpod** | State management |
| **HTTP Package** | API communication |

---

## ðŸš€ Getting Started

### Prerequisites
- Python 3.10+
- Flutter SDK
- PostgreSQL (or SQLite for local dev)

### Backend Setup

```bash
# Clone the repository
git clone https://github.com/surajgupta221/Just1Shop.git
cd Just1Shop/just1shop-backend

# Create and activate virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Set up environment variables
cp .env.example .env
# Edit .env with your database URL, secret key, payment keys etc.

# Run database migrations
alembic upgrade head

# Start the FastAPI server
uvicorn main:app --reload
```

### API Documentation
Once the server is running, visit:
- **Swagger UI:** `http://localhost:8000/docs`
- **ReDoc:** `http://localhost:8000/redoc`

### Frontend Setup

```bash
cd Just1Shop
flutter pub get
flutter run
```

---

## ðŸ“ Project Structure

```
Just1Shop/
â”‚
â”œâ”€â”€ just1shop-backend/       # Python FastAPI Backend
â”‚   â”œâ”€â”€ main.py              # App entry point
â”‚   â”œâ”€â”€ routers/             # API route handlers
â”‚   â”‚   â”œâ”€â”€ auth.py          # Authentication routes
â”‚   â”‚   â”œâ”€â”€ products.py      # Product routes
â”‚   â”‚   â”œâ”€â”€ orders.py        # Order routes
â”‚   â”‚   â”œâ”€â”€ cart.py          # Cart routes
â”‚   â”‚   â””â”€â”€ admin.py         # Admin routes
â”‚   â”œâ”€â”€ models/              # SQLAlchemy database models
â”‚   â”œâ”€â”€ schemas/             # Pydantic schemas
â”‚   â”œâ”€â”€ services/            # Business logic
â”‚   â”œâ”€â”€ utils/               # Helper functions
â”‚   â””â”€â”€ requirements.txt
â”‚
â”œâ”€â”€ lib/                     # Flutter Frontend
â”‚   â”œâ”€â”€ screens/             # UI screens
â”‚   â”œâ”€â”€ widgets/             # Reusable widgets
â”‚   â”œâ”€â”€ models/              # Data models
â”‚   â””â”€â”€ services/            # API service calls
â”‚
â””â”€â”€ README.md
```

---

## ðŸ”Œ API Endpoints

### Authentication
| Method | Endpoint | Description |
|---|---|---|
| POST | `/api/auth/register` | Register new user |
| POST | `/api/auth/login` | User login |
| POST | `/api/auth/refresh` | Refresh token |

### Products
| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/products` | Get all products |
| GET | `/api/products/{id}` | Get product by ID |
| GET | `/api/products/search` | Search products |
| POST | `/api/products` | Add product (Admin) |

### Orders
| Method | Endpoint | Description |
|---|---|---|
| POST | `/api/orders` | Place new order |
| GET | `/api/orders/my` | Get user orders |
| PUT | `/api/orders/{id}` | Update order status (Admin) |

### Cart
| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/cart` | Get user cart |
| POST | `/api/cart/add` | Add item to cart |
| DELETE | `/api/cart/remove/{id}` | Remove item from cart |

---

## ðŸŒŸ Key Highlights

- âš¡ **High Performance** â€” FastAPI is one of the fastest Python frameworks available
- ðŸ”’ **Secure** â€” JWT authentication, password hashing, and input validation
- ðŸ“¦ **Scalable** â€” Clean architecture with separation of concerns
- ðŸ¤– **AI Ready** â€” Product recommendation engine built in
- ðŸ“± **Cross-Platform** â€” Flutter frontend works on both Android and iOS

---

## ðŸ‘¨â€ðŸ’» Author

**Suraj Kumar Gupta**
- ðŸ”— LinkedIn: [linkedin.com/in/your-profile](https://linkedin.com/in/sk-gupta-821a4965)
- ðŸ™ GitHub: [@surajgupta221](https://github.com/surajgupta221)
- ðŸ“§ Open to Python Developer / Full Stack roles

---

## ðŸ“„ License

This project is licensed under the MIT License.

---

â­ If you found this project useful, please give it a star!
