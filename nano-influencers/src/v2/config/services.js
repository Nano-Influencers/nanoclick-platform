export const SERVICE_CONFIG = Object.freeze({
  word_of_mouth: {
    id: "word_of_mouth",
    label: "Word of Mouth",
    workerCategory: "repeating_single",
  },
  engaged_growth: {
    id: "engaged_growth",
    label: "Engaged Growth",
    workerCategory: "repeating_grouped",
  },
  single_one_time: {
    id: "single_one_time",
    label: "Single One-Time Task",
    workerCategory: "one_off_single",
  },
  custom: {
    id: "custom",
    label: "Custom Task",
    workerCategory: "one_off_grouped",
  },
  trend_on_x: {
    id: "trend_on_x",
    label: "Trend on X",
    workerCategory: "trend_push",
  },
  high_value: {
    id: "high_value",
    label: "High Value",
    workerCategory: "skill_based",
  },
  try_for_free: {
    id: "try_for_free",
    label: "Try for Free",
    workerCategory: "unpaid",
  },
});

export const SERVICES = Object.freeze(Object.values(SERVICE_CONFIG));

export function getServiceConfig(serviceId) {
  return SERVICE_CONFIG[serviceId] || null;
}
