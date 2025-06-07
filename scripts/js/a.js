const fs = require("fs");

const inputPath = "./codes.txt";
const outputPath = "./output.txt";

fs.readFile(inputPath, "utf8", (err, data) => {
    if (err) {
        console.error("Error reading file:", err);
        return;
    }

    const items = data
        .split("\n")
        .map((line) => line.trim())
        .filter((line) => line.length > 0)
        .map((line) => `'${line}'`);

    const result = `(${items.join(", ")})`;

    fs.writeFile(outputPath, result, "utf8", (err) => {
        if (err) {
            console.error("Error writing to output file:", err);
        } else {
            console.log(`Conversion successful! Output written to ${outputPath}`);
        }
    });
});
