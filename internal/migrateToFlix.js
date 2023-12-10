const fs = require('fs/promises');
const path = require('path');
const {
    listFiles
} = require('./utils/file');
const {CadenceParser} = require("@onflow/cadence-parser");
const fcl = require("@onflow/fcl");
const Flix = require("@onflow/interaction-template-generators")
const decamelize = require("decamelize");

process();

async function process() {
    // p-map lib only works with ESM modules,
    // but using the dynamic import syntax works in Common JS.
    const pMap = await import("p-map");

    const cadenceParserWasm = await fs.readFile(
        path.join(__dirname, "..", "node_modules", "@onflow", "cadence-parser", "dist", "cadence-parser.wasm")
    )
    const parser = await CadenceParser.create(cadenceParserWasm);

    const addressConfigByReplacementPattern = JSON.parse(
        (await fs.readFile(path.join(__dirname, "..", "config.json"))).toString("utf-8")
    );

    const flixDirPath = path.join(__dirname, "..", "flix");

    await fs.mkdir(flixDirPath, {recursive: true});

    let cadencePaths = await getAllCadenceFilePaths();

    fcl.config({
        "accessNode.api": "https://rest-testnet.onflow.org"
    });

    async function processCadencePath(cadencePath) {
        const metadataPath = cadencePath.replace(".cdc", ".json");

        const [cadenceBuffer, metadataBuffer] = await Promise.all([
            fs.readFile(cadencePath),
            fs.readFile(metadataPath),
        ]);

        const cadence = cadenceBuffer.toString("utf-8");
        const metadata = JSON.parse(metadataBuffer.toString("utf-8"));
        // Parsing will fail if we don't remove the imports with replacement characters.
        const ast = parser.parse(removeImports(cadence));

        // This call currently takes quite some time to complete.
        // See: https://github.com/onflow/flow-interaction-template-tools/issues/6
        const flixTemplate = await Flix.template({
            type: "InteractionTemplate",
            iface: "",
            messages: [
                generateTitleMessage(cadencePath),
                generateDescriptionMessage(metadata.messages)
            ],
            dependencies: generateDependencies(cadence, addressConfigByReplacementPattern),
            args: generateArguments(ast),
            cadence,
        });

        await fs.writeFile(
            path.join(flixDirPath, generateFileName(flixTemplate)),
            JSON.stringify(flixTemplate, null, 4)
        )
    }

    async function mapper(cadencePath) {
        try {
            await processCadencePath(cadencePath)
        } catch (error) {
            console.error(`Error for ${cadencePath}:`, error)
            return pMap.pMapSkip;
        }
    }

    await pMap.default(cadencePaths, mapper, {concurrency: 5})
}

function generateFileName(flixTemplate) {
    const title = flixTemplate.data.messages.title.i18n["en-US"];
    return `${title.toLowerCase().replaceAll(" ", "-")}.json`
}

function generateArguments(ast) {
    const parameters = ast.program.Declarations?.[0]?.ParameterList?.Parameters;

    if (!parameters) {
        throw new Error(`Failed to generate arguments for AST: ${JSON.stringify(ast, null, 4)}`)
    }

    return parameters.map((parameter, index) => {

        return Flix.arg({
            tag: parameter.Identifier.Identifier,
            type: parameter.TypeAnnotation.AnnotatedType.ElementType?.Identifier?.Identifier ?? parameter.TypeAnnotation.AnnotatedType?.Identifier?.Identifier,
            index,
            messages: [],
        })
    });
}

function removeImports(cadence) {
    return cadence.split("\n").filter(line => !line.startsWith("import")).join("\n")
}

function generateDependencies(cadence, addressConfigByReplacementPattern) {
    return cadence
        .split("\n")
        .filter(line => line.trim().startsWith("import"))
        .map(importLine => {

            const [contractName, placeholder] = importLine.replace("import", "").split("from").map(part => part.trim());

            function buildForNetwork(network) {
                const address = addressConfigByReplacementPattern[placeholder]?.[network];

                const existsOnNetwork = address && address !== "0x0";
                if (!existsOnNetwork) {
                    return undefined;
                }

                return Flix.dependencyContractByNetwork({
                    network,
                    contractName,
                    address,
                    fqAddress: `A.${address}.${contractName}`,
                    pin: "",
                    pinBlockHeight: 0,
                })
            }

            return Flix.dependency({
                addressPlaceholder: placeholder,
                contracts: [
                    Flix.dependencyContract({
                        contractName,
                        // For now, it only works to generate template for a single network at the time.
                        // See: https://github.com/onflow/flow-interaction-template-tools/issues/13
                        networks: [
                            // buildForNetwork("mainnet"),
                            buildForNetwork("testnet"),
                        ].filter(Boolean),
                    }),
                ],
            })
        })
}

function generateDescriptionMessage(bloctoMessages) {
    return Flix.message({
        tag: "description",
        translations: Object.entries(bloctoMessages)
            .map(entry => {
                const keyRemappingLookup = new Map([
                    ["en", "en-US"]
                ])
                const reMappedKey = (keyRemappingLookup.get(entry[0]) ?? entry[0]).replace("_", "-");

                return Flix.messageTranslation({
                    bcp47tag: reMappedKey,
                    translation: entry[1]
                })
            })
    })
}

function generateTitleMessage(cadencePath) {
    const cadencePathParts = cadencePath.split("/");
    const transactionName = capitalize(decamelize(cadencePathParts.at(-1).replace(".cdc", ""), {separator: " "}));
    const projectName = cadencePathParts.at(-2)

    return Flix.message({
        tag: "title",
        translations: [
            Flix.messageTranslation({
                bcp47tag: "en-US",
                translation: `${projectName} ${transactionName}`,
            })
        ]
    })
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
