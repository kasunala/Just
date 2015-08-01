
//Kasun Alahakoon on 1st August 2015

Parse.Cloud.job("BackupMessages", function(request, status) {

    var nowTimeStamp = Date.now();

    var timeout = 60 ;//* 60 * 1000; // one hour //test 1 min

    var query = new Parse.Query("Calls");

    // set a limit to make sure resource usage

    query.limit(100); 

    query.equalTo("read", true);

    query.lessThan("readTime", nowTimeStamp - timeout);

    query.find().then(function(messages) {

        var promises = [];

        var CallsArchive = Parse.Object.extend("CallsArchive");

        _.each(messages, function(message) {

            promises.push(function(message) {

                var newObject = new CallsArchive();

                // try to backup the ObjectId of Calls

                newObject.set("CallsId", message.get("objectId"));

                // for each data column you want to backup

                newObject.set("data", message.get("data"));

                // ...

                return newObject.save();

            } (message));

        });

        // remember clean "Calls"

        // promises.push(Parse.Object.destroyAll(messages));

        // do Promises in Parallel 

        return Parse.Promise.when(promises);

    }).then(function() {

        status.success("data moved.");

    }, function(error) {

        status.error("error move data" + error.code + ": " + error.message);

    });

});
