const neo4j = require('neo4j-driver');
const fs = require('fs');

require('dotenv').config();
exports.handler = async (event) => {

 
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
    let query = getCypher(event.cypher);
    let params=event.params;
    if(!params){
      return await getData$(driver,query);
    }else{
      return await getData$(driver,query,params);
    }
  }
  

 
  function getCypher(query){
    const filename='get'+query.charAt(0).toUpperCase() +query.substring(1)+'.cyp';
    console.log(`Filename: ${filename}`);
    try {
      const data = fs.readFileSync(`./cypher/${filename}`, 'utf8');
      console.log(`Cypher: ${data}`);
      return data;
    } catch (err) {
      console.error(err);
    }
  }
  

  async function getData$(driver,query){
    let session = driver.session();
    let data =[];
    // the Promise way, where the complete result is collected before we act on it:
    return new Promise((resolve,reject)=>{
      session
      .run(query)
      .then(result => {
        result.records.forEach(record => {
          let dataRecord={};
          if(record.keys.length>1){
            record.keys.forEach(key=>{
              dataRecord[key]=record.get(key);
            });
          }else{
            dataRecord=record.get(record.keys[0]);
          }
          if(result.records.length==1){
            data=dataRecord;
          }else{
            data.push(dataRecord);
          }
        })
      })
      .catch(error => {
        console.log(error)
      })
      .then(() => {session.close();resolve(data);})
    });    
  }
  async function getData$(driver,query,{params}){
    let session = driver.session();
    let data =[];
    // the Promise way, where the complete result is collected before we act on it:
    return new Promise((resolve,reject)=>{
      session
      .run(query,params)
      .then(result => {
        result.records.forEach(record => {
          let dataRecord={};
          if(record.keys.length>1){
            record.keys.forEach(key=>{
              dataRecord[key]=record.get(key);
            });
          }else{
            dataRecord=record.get(record.keys[0]);
          }
          if(result.records.length==1){
            data=dataRecord;
          }else{
            data.push(dataRecord);
          }
        })
      })
      .catch(error => {
        console.log(error)
      })
      .then(() => {session.close();resolve(data);})
    });
  }