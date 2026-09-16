// Express doesn't catch errors thrown inside an async route handler on its
// own — without this, a failed query would hang the request instead of
// returning an error. Wrapping the handler forwards any rejection to
// Express's error-handling middleware (see the app.use((err, ...)) in index.js).
function asyncHandler(fn) {
  return (req, res, next) => {
    fn(req, res, next).catch(next);
  };
}

module.exports = asyncHandler;
