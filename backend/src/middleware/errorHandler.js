export function errorHandler(err, req, res, next) {
  console.error('[API Error]:', err.message || err);

  const statusCode = res.statusCode && res.statusCode !== 200 ? res.statusCode : 500;

  res.status(statusCode).json({
    error: true,
    message: err.message || 'Internal Server Error',
    timestamp: new Date().toISOString(),
  });
}
