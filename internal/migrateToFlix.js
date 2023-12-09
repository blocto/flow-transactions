const fs = require('fs/promises');
const path = require('path');
const {
    listFiles
} = require('./utils/file');
const {CadenceParser} = require("@onflow/cadence-parser");
const decamelize = require("decamelize");

process();

async function process() {
    const cadenceParserWasm = await fs.readFile(
        path.join(__dirname, "..", "node_modules", "@onflow", "cadence-parser", "dist", "cadence-parser.wasm")
    )
    const parser = await CadenceParser.create(cadenceParserWasm);

    const addressConfigByReplacementPattern = JSON.parse((await fs.readFile(path.join(__dirname, "..", "config.json"))).toString("utf-8"));

    let cadencePaths = await getAllCadenceFilePaths();

    // Temporary
    cadencePaths = [cadencePaths[0]]

    const flixTemplates = await Promise.all(
        cadencePaths.map(async cadencePath => {
            const metadataPath = cadencePath.replace(".cdc", ".json");

            const [cadenceBuffer, metadataBuffer] = await Promise.all([
                fs.readFile(cadencePath),
                fs.readFile(metadataPath),
            ]);

            const cadence = cadenceBuffer.toString("utf-8");
            const metadata = JSON.parse(metadataBuffer.toString("utf-8"));
            const ast = parser.parse(removeImports(cadence));

            const descriptions = Object.entries(metadata.messages)
                .map(entry => {
                    const keyRemappingLookup = new Map([
                        ["en", "en-US"]
                    ])
                    const reMappedKey = (keyRemappingLookup.get(entry[0]) ?? entry[0]).replace("_", "-");
                    return {
                        [reMappedKey]: entry[1]
                    }
                })
                .reduce((union, entry) => ({...union, ...entry}), {});

            const cadencePathParts = cadencePath.split("/");
            const transactionName = capitalize(decamelize(cadencePathParts.at(-1).replace(".cdc", ""), {separator: " "}));
            const projectName = cadencePathParts.at(-2)
            const generatedTitle = `${transactionName} (${projectName})`;

            return {
                "f_type": "InteractionTemplate",
                "f_version": "1.0.0",
                "id": "c8cb7cc7a1c2a329de65d83455016bc3a9b53f9668c74ef555032804bac0b25b",
                "data": {
                    "type": "transaction",
                    "interface": "",
                    "messages": {
                        "title": {
                            "i18n": {
                                "en-US": generatedTitle
                            }
                        },
                        "description": {
                            "i18n": descriptions
                        }
                    },
                    "cadence": cadence,
                    "dependencies": getDependencies(cadence, addressConfigByReplacementPattern),
                    "arguments": getFlixArguments(ast)
                }
            }
        })
    );

    console.log(JSON.stringify(flixTemplates[0], null, 4))

}

function getFlixArguments(ast) {
    const parameters = ast.program.Declarations[0].ParameterList.Parameters;

    const flixParameters = parameters.map(parameter => {

        return {
            [parameter.Identifier.Identifier]: {
                "index": 0,
                "type": parameter.TypeAnnotation.AnnotatedType.ElementType?.Identifier?.Identifier ?? parameter.TypeAnnotation.AnnotatedType?.Identifier?.Identifier,
                "messages": {}
            }
        }
    });

    return flixParameters.reduce((union, parameter) => ({...union, ...parameter}), {})
}

function removeImports(cadence) {
    return cadence.split("\n").filter(line => !line.startsWith("import")).join("\n")
}

function getDependencies(cadence, addressConfigByReplacementPattern) {
    return cadence
        .split("\n")
        .filter(line => line.trim().startsWith("import"))
        .map(importLine => {

            const [contractName, replacementPattern] = importLine.replace("import", "").split("from").map(part => part.trim());

            function buildForNetwork(network) {
                const address = addressConfigByReplacementPattern[replacementPattern]?.[network];

                const existsOnNetwork = address && address !== "0x0";
                if (!existsOnNetwork) {
                    return {};
                }

                return {
                    [network]: {
                        "address": address,
                        "contract": contractName,
                        "fq_address": `A.${address}.${contractName}`,
                        "pin": "",
                        "pin_block_height": -1
                    }
                }
            }

            return {
                [replacementPattern]: {
                    [contractName]: {
                        ...buildForNetwork("mainnet"),
                        ...buildForNetwork("testnet"),
                    }
                }
            }
        })
        .reduce((union, replacementConfig) => ({...union, ...replacementConfig}), {})
}

function capitalize(text) {
    return text.slice(0, 1).toUpperCase() + text.slice(1)
}

async function getAllCadenceFilePaths() {
    const rootPath = path.join(__dirname, '..', 'transactions')

    return new Promise((resolve, reject) => {
        listFiles(rootPath, 'cdc', (err, list) => err ? reject(err) : resolve(list));
    })
}
