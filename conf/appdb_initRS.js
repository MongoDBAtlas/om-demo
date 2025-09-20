rs.initiate({
  _id: "omrs",
  members: [
    { _id: 0, host: "appdb1:27017" },
    { _id: 1, host: "appdb2:27017" },
    { _id: 2, host: "appdb3:27017" },
  ],
  settings: {
    heartbeatIntervalMillis: 30000,
    heartbeatTimeoutSecs: 40,
  },
});
