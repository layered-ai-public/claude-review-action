const BULK_DISCOUNT_THRESHOLD = 100;
const BULK_DISCOUNT_RATE = 0.9;

function lineTotal(item) {
  return item.price * item.quantity;
}

function applyBulkDiscount(sum) {
  if (sum > BULK_DISCOUNT_THRESHOLD) {
    return sum * BULK_DISCOUNT_RATE;
  }
  return sum;
}

function roundToPence(amount) {
  return Math.round(amount * 100) / 100;
}

function cartTotal(items) {
  const sum = items.reduce((acc, item) => acc + lineTotal(item), 0);
  return roundToPence(applyBulkDiscount(sum));
}

module.exports = { cartTotal };
