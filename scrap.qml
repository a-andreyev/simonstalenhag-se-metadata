// SPDX-FileCopyrightText: 2021-2026 Alexey Andreyev <dev@aa13q.ru>
// SPDX-License-Identifier: LicenseRef-KDE-Accepted-GPL

import QtQuick.Window 2.15
import QtQuick 2.15
import "parser.js" as Parser

Window {
    id: root

    property int pendingRequests: 0

    function saveFile(fileUrl, text) {
        console.log("Saving to file " + fileUrl);
        var request = new XMLHttpRequest();
        request.open("PUT", fileUrl, false);
        request.send(text);
    }

    function makeRequest(site) {
        console.log("Requesting " + site.url);
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                var str = doc.responseText;
                var titles = Parser.parseHtml(str, site.keyword1);
                var x = Parser.formJSON(titles, site.section, site.keyword1, site.keyword2);
                saveFile(Qt.resolvedUrl("./") + site.output, JSON.stringify(x, null, 2) + "\n");
                root.pendingRequests--;
                if (root.pendingRequests === 0)
                    Qt.quit();

            }
        };
        doc.open("GET", site.url);
        doc.send();
    }

    function runScript() {
        root.pendingRequests = Parser.sites.length;
        for (var i = 0; i < Parser.sites.length; i++) {
            makeRequest(Parser.sites[i]);
        }
    }

    Component.onCompleted: {
        runScript();
    }
}
