// The state machine: for each status, which statuses may legally follow it.
// EXCEPTION and DELIVERED have no listed transitions — they're terminal.
const TRANSITIONS = {
  ORDER_CONFIRMED: ['PICKED_UP', 'EXCEPTION'],
  PICKED_UP: ['DEPARTED', 'EXCEPTION'],
  DEPARTED: ['ARRIVED_AT_HUB', 'EXCEPTION'],
  ARRIVED_AT_HUB: ['OUT_FOR_DELIVERY', 'EXCEPTION'],
  OUT_FOR_DELIVERY: ['DELIVERED', 'EXCEPTION'],
  DELIVERED: [],
  EXCEPTION: [],
};

function isValidTransition(fromStatus, toStatus) {
  const allowedNextStatuses = TRANSITIONS[fromStatus] || [];
  return allowedNextStatuses.includes(toStatus);
}

module.exports = { TRANSITIONS, isValidTransition };
