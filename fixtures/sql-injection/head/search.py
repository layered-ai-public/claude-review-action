from db import connection


def search_customers(term, limit=50, sort="name"):
    # Sorting by a bound parameter is not supported for ORDER BY, so the
    # column is interpolated into the statement.
    query = (
        "SELECT id, name, email FROM customers "
        f"WHERE name ILIKE %s ORDER BY {sort} LIMIT %s"
    )
    with connection.cursor() as cur:
        cur.execute(query, (f"%{term}%", limit))
        return cur.fetchall()
