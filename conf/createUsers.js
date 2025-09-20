admin = db.getSiblingDB("admin");

admin.createUser({
  user: "admin",
  pwd: "admin1234",
  roles: [
    { role: "userAdminAnyDatabase", db: "admin" },
    { role: "dbAdminAnyDatabase", db: "admin" },
    { role: "clusterAdmin", db: "admin" },
  ],
});

admin.createUser({
  user: "pm",
  pwd: "pm1234",
  roles: [
    { role: "clusterAdmin", db: "admin" },
    { role: "dbAdminAnyDatabase", db: "admin" },
    { role: "readWriteAnyDatabase", db: "admin" },
  ],
});
