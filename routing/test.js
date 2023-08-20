
const fs = require('fs');
function getCypher(query){
    const filename='get'+query.charAt(0).toUpperCase() +query.substring(1)+'.cyp';
    console.log(filename);
    try {
        const data = fs.readFileSync(`./cypher/${filename}`, 'utf8');
        console.log(data);
      } catch (err) {
        console.error(err);
      }
}

getCypher('participants');

