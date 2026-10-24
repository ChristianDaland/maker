// Node-RED – innstillinger for verkstedet.
// Brukernavn, passord og krypteringsnøkkel hentes fra .env (via compose.yaml).
// Øvrige innstillinger bruker Node-RED sine standardverdier.

const bcrypt = require("/usr/src/node-red/node_modules/bcryptjs");

for (const navn of ["NODERED_BRUKER", "NODERED_PASSORD", "NODERED_KRYPTERINGSNOKKEL"]) {
  if (!process.env[navn]) {
    throw new Error(`${navn} mangler i .env – Node-RED starter ikke uten innlogging`);
  }
}

module.exports = {
  uiPort: 1880,
  flowFile: "flows.json",
  flowFilePretty: true,

  // Krypterer lagrede passord (f.eks. MQTT-innlogging) i flows_cred.json
  credentialSecret: process.env.NODERED_KRYPTERINGSNOKKEL,

  // Innlogging kreves for editoren og admin-API-et
  adminAuth: {
    type: "credentials",
    users: [
      {
        username: process.env.NODERED_BRUKER,
        password: bcrypt.hashSync(process.env.NODERED_PASSORD, 10),
        permissions: "*",
      },
    ],
  },

  functionExternalModules: true,
  exportGlobalContextKeys: false,

  logging: {
    console: { level: "info", metrics: false, audit: false },
  },
};
