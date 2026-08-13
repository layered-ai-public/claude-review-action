from flask import Blueprint, jsonify, request

from search import search_customers

bp = Blueprint("customers", __name__)


@bp.route("/customers/search")
def customers_search():
    term = request.args.get("q", "")
    return jsonify(search_customers(term))
