/**
 * Export Structurizr diagrams to SVG using Puppeteer (headless Chrome).
 * Based on: https://github.com/structurizr/puppeteer
 *
 * Usage: node export-diagrams.js <structurizrUrl> <outputDir>
 * Example: node export-diagrams.js http://localhost:18080/workspace/diagrams ./diagrams
 */

const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

const IGNORE_HTTPS_ERRORS = true;
const HEADLESS = 'new';
const IMAGE_VIEW_TYPE = 'Image';

if (process.argv.length < 4) {
    console.log("Usage: node export-diagrams.js <structurizrUrl> <outputDir>");
    console.log("Example: node export-diagrams.js http://localhost:18080/workspace/diagrams ./diagrams");
    process.exit(1);
}

const url = process.argv[2];
const outputDir = process.argv[3];

// Ensure output directory exists
if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
}

var expectedNumberOfExports = 0;
var actualNumberOfExports = 0;

(async () => {
    console.log("Starting Puppeteer export...");

    const browser = await puppeteer.launch({
        ignoreHTTPSErrors: IGNORE_HTTPS_ERRORS,
        headless: HEADLESS,
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    const page = await browser.newPage();

    // Set a reasonable viewport
    await page.setViewport({ width: 1920, height: 1080 });

    // Visit the diagrams page
    console.log(" - Opening " + url);
    await page.goto(url, { waitUntil: 'domcontentloaded' });

    // Wait for Structurizr to be ready
    await page.waitForFunction('structurizr.scripting && structurizr.scripting.isDiagramRendered() === true', {
        timeout: 30000
    });

    // Get the array of views
    const views = await page.evaluate(() => {
        return structurizr.scripting.getViews();
    });

    // Count expected exports (diagram only, skip keys for cleaner output)
    views.forEach(function(view) {
        expectedNumberOfExports++; // diagram only
    });

    console.log(` - Found ${views.length} diagrams to export`);
    console.log(" - Starting export to " + outputDir);

    for (var i = 0; i < views.length; i++) {
        const view = views[i];

        await page.evaluate((view) => {
            structurizr.scripting.changeView(view.key);
        }, view);

        await page.waitForFunction('structurizr.scripting.isDiagramRendered() === true');

        // Use Structurizr Lite naming convention: structurizr-1-{ViewKey}.svg
        const diagramFilename = path.join(outputDir, `structurizr-1-${view.key}.svg`);

        var svgForDiagram = await page.evaluate(() => {
            return structurizr.scripting.exportCurrentDiagramToSVG({ includeMetadata: true });
        });

        console.log(" - " + `structurizr-1-${view.key}.svg`);
        fs.writeFileSync(diagramFilename, svgForDiagram);
        actualNumberOfExports++;
    }

    console.log(` - Exported ${actualNumberOfExports} diagrams`);
    console.log(" - Finished");
    await browser.close();
})();
