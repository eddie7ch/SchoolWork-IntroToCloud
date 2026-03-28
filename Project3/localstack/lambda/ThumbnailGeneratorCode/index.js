exports.handler = async (event) => {

    console.log("Generating thumbnail");

    return {
        statusCode: 200,
        body: JSON.stringify({
            message: "Thumbnail generated",
            image: event.imageKey
        })
    };

};
