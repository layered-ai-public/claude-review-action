const PER_PAGE = 25;

function paginate(items, page) {
  const start = (page - 1) * PER_PAGE;
  return items.slice(start, start + PER_PAGE);
}

module.exports = { paginate, PER_PAGE };
