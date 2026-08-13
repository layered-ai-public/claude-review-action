const { paginate } = require('./reports');

// `page` is 1-based: the UI links start at ?page=1.
async function listReports(db, query) {
  const page = Number(query.page) || 1;
  const all = await db.reports.findAll();
  return {
    page,
    results: paginate(all, page),
  };
}

module.exports = { listReports };
