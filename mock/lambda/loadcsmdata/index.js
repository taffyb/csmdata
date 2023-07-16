const AWS = require('aws-sdk');

// Create an instance of the S3 client
const s3 = new AWS.S3();

// Lambda handler function
exports.handler = async (event) => {
  try {
    const { bucket, file } = event;
    console.log("event: " + JSON.stringify(event));
    
    // Create the parameters for the S3 getObject operation
    const params = {
      Bucket: bucket,
      Key: file
    };
    console.log("params: " + JSON.stringify(params));
    // Get the JSON file from S3
    
    let data;
    try {
      data = await s3.getObject(params).promise();
    console.log("data: " + data);
    } catch (error) {
      console.error('Error:', error);
    }
    
    // Parse the JSON data
    const jsonData = JSON.parse(data.Body.toString());
    console.log("jsonData: " + JSON.stringify(jsonData));

    // Return the JSON data as the response
    return jsonData//JSON.stringify(jsonData);
  } catch (error) {
    // Return an error response if anything goes wrong
    return {
      statusCode: 500,
      body: JSON.stringify({ message: 'Error retrieving JSON file' })
    };
  }
};
