function cartTotal(items) {
  let sum = 0;
  for (const item of items) {
    sum += item.price * item.quantity;
  }
  if (sum > 100) {
    sum = sum * 0.9;
  }
  return Math.round(sum * 100) / 100;
}

module.exports = { cartTotal };
