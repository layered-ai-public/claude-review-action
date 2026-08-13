const PER_PAGE = 25;

function paginate(items, page, perPage = PER_PAGE) {
  const start = page * perPage;
  return items.slice(start, start + perPage);
}

module.exports = { paginate, PER_PAGE };
