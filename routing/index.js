var neo4j = require('neo4j-driver');
require('dotenv').config();
(async () => {
 
  const URI = process.env.NEO4J_URI;
  const USER = process.env.NEO4J_USR;
  const PASSWORD = process.env.NEO4J_PWD;
  let driver

  try {
    driver = neo4j.driver(URI,  neo4j.auth.basic(USER, PASSWORD))
    const serverInfo = await driver.getServerInfo()
    console.log('Connection established')
    console.log(serverInfo)
  } catch(err) {
    console.log(`Connection error\n${err}\nCause: ${err.cause}`)
  }
})();