const fs = require('fs/promises');
const path = require('path');
const {
    listFiles
} = require('./utils/file');

process();

async function process() {
    const cadencePaths = await getAllCadenceFilePaths();
    const cadenceAndMetadataPaths = await Promise.all(
        cadencePaths.map(async cadencePath => {
            const metadataPath = cadencePath.replace(".cdc", ".json");

            const [cadenceBuffer, metadataBuffer] = await Promise.all([
                fs.readFile(cadencePath),
                fs.readFile(metadataPath),
            ]);

            return {
                cadence: cadenceBuffer.toString("utf-8"),
                metadata: JSON.parse(metadataBuffer.toString("utf-8"))
            }
        })
    );

}

async function getAllCadenceFilePaths() {
    const rootPath = path.join(__dirname, '..', 'transactions')

    return new Promise((resolve, reject) => {
        listFiles(rootPath, 'cdc', (err, list) => err ? reject(err) : resolve(list));
    })
}
