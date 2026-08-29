/**
 * Calculates the great-circle distance between two points on the Earth
 * using the Haversine formula.
 * @returns {number} Distance in kilometers
 */
export function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Earth radius in kilometers
  const dLat = toRadians(lat2 - lat1);
  const dLon = toRadians(lon2 - lon1);

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRadians(lat1)) *
      Math.cos(toRadians(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

function toRadians(degrees) {
  return degrees * (Math.PI / 180);
}

/**
 * Finds the nearest service from a list of services based on user location.
 * @param {number} userLat
 * @param {number} userLon
 * @param {Array} services
 * @returns {Object|null} Nearest service object with `distanceKm` property
 */
export function findNearestService(userLat, userLon, services) {
  if (!services || services.length === 0) return null;

  let nearest = null;
  let minDistance = Infinity;

  for (const service of services) {
    const sLat = parseFloat(service.latitude);
    const sLon = parseFloat(service.longitude);

    if (!isNaN(sLat) && !isNaN(sLon)) {
      const dist = calculateDistance(userLat, userLon, sLat, sLon);
      if (dist < minDistance) {
        minDistance = dist;
        nearest = { ...service, distanceKm: Math.round(dist * 100) / 100 };
      }
    }
  }

  return nearest;
}
