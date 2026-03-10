// SPDX-FileCopyrightText: 2026 Alexey Andreyev <dev@aa13q.ru>
// SPDX-License-Identifier: LicenseRef-KDE-Accepted-GPL

import qbs.FileInfo
import qbs.Process
import qbs.TextFile
import "parser.js" as Parser

Project {
    property bool run: false

    Probe {
        id: scraper
        condition: project.run

        configure: {
            for (var i = 0; i < Parser.sites.length; i++) {
                var site = Parser.sites[i];
                console.info("Requesting " + site.url);

                var proc = new Process();
                try {
                    var exitCode = proc.exec("curl", ["-s", site.url], true);
                    if (exitCode !== 0) {
                        console.error("curl failed for " + site.url);
                        continue;
                    }
                    var html = proc.readStdOut();

                    var titles = Parser.parseHtml(html, site.keyword1);
                    var jsonObj = Parser.formJSON(titles, site.section, site.keyword1, site.keyword2);
                    var jsonStr = JSON.stringify(jsonObj, null, 2) + "\n";

                    var outputPath = FileInfo.joinPaths(path, site.output);
                    console.info("Saving to " + outputPath);

                    var file = new TextFile(outputPath, TextFile.WriteOnly);
                    file.write(jsonStr);
                    file.close();
                } finally {
                    proc.close();
                }
            }
        }
    }
}
