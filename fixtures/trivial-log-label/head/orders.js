const logger = require('./logger');

async function createOrder(db, payload) {
  const order = await db.orders.insert(payload);
  logger.info('order created', { orderId: order.id });
  return order;
}

async function deleteOrder(db, orderId) {
  await db.orders.delete(orderId);
  logger.info('order created', { orderId });
  return { ok: true };
}

module.exports = { createOrder, deleteOrder };
