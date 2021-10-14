const child_process = require('child_process');

child_process.exec('node ./internal/replaceAddresses', (error) => {
    if (error !== null) {
        console.error(error);
    }

    child_process.exec('node ./internal/processHash', (error) => {
        if (error !== null) {
            console.error(error);
        }
    
        child_process.exec('node ./internal/generateMessage', (error) => {
            if (error !== null) {
                console.error(error);
            }
        });
    });
});
