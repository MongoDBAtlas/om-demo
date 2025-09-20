admin = db.getSiblingDB("admin");

admin.createUser({
  user: "super",
  pwd: "super1234",
  roles: [{ role: "root", db: "admin" }],
});
