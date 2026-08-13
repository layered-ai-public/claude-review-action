from db import connection


def search_customers(term, limit=50):
    with connection.cursor() as cur:
        cur.execute(
            "SELECT id, name, email FROM customers WHERE name ILIKE %s LIMIT %s",
            (f"%{term}%", limit),
        )
        return cur.fetchall()
