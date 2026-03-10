// SPDX-FileCopyrightText: 2021 Alexey Andreyev <aa13q@ya.ru>
// SPDX-License-Identifier: LicenseRef-KDE-Accepted-GPL

import QtQuick.Window 2.15
import QtQuick 2.15

Window {
    // see also:
    // https://github.com/a-andreyev/harbour-imagitron/blob/master/src/imagitronlistmodel.cpp#L88
    function parseHtml(str, keyword) {
        const titlesSet = new Set();
        const regex = new RegExp("<a href=\"" + keyword + ".*jpg", "gm");
        let m;
        while ((m = regex.exec(str)) !== null) {
            if (m.index === regex.lastIndex)
                regex.lastIndex++;

            m.forEach((match, groupIndex) => {
                const newLink = match.split("\"")[1].split("/").pop();
                titlesSet.add(newLink);
            });
        }
        return titlesSet;
    }

    function formJSON(titles, section, keyword1, keyword2) {
        var jsonObj = {
            "simonstalenhag.se": []
        };
        for (let title of titles) {
            const sRegex = /_?(big)?([\d]{4})?\.jpg/gm;
            var smallTitle = title.replace(sRegex, "");
            jsonObj["simonstalenhag.se"].push({
                "name": smallTitle,
                "imagebig": "http://simonstalenhag.se/" + keyword1 + "/" + title,
                "image": "http://simonstalenhag.se/" + keyword2 + "/" + smallTitle + ".jpg",
                "section": section
            });
        }
        return jsonObj;
    }

    function saveFile(fileUrl, text, quitOnFinish = false) {
        console.log("Saving to file " + fileUrl);
        var request = new XMLHttpRequest();
        request.onreadystatechange = function() {
            if (request.readyState == XMLHttpRequest.DONE) {
                if (quitOnFinish)
                    Qt.quit();

            }
        };
        request.open("PUT", fileUrl, false);
        request.send(text);
    }

    function makeRequest(url, section, output, keyword1 = "bilderbig", keyword2 = "bilder", quitOnFinish = false) {
        console.log("Requesting " + url);
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                const str = doc.responseText;
                var titles = parseHtml(str, keyword1);
                var x = formJSON(titles, section, keyword1, keyword2);
                saveFile(Qt.resolvedUrl("./") + output, JSON.stringify(x, null, 2) + "\n", quitOnFinish);
            }
        };
        doc.open("GET", url);
        doc.send();
    }

    function runScript() {
        makeRequest("http://simonstalenhag.se/svema.html", "SWEDISH MACHINES (2024)", "data/svema.json", "4k", "bilder");
        makeRequest("http://simonstalenhag.se/", "EUROPA MEKANO", "data/em.json");
        makeRequest("http://simonstalenhag.se/labyrinth.html", "THE LABYRINTH (2020)", "data/labyrinth.json");
        makeRequest("http://simonstalenhag.se/es.html", "THE ELECTRIC STATE (2017)", "data/es.json");
        makeRequest("http://simonstalenhag.se/tftf.html", "THINGS FROM THE FLOOD (2016)", "data/tftf.json", "tftfbig", "tftf");
        makeRequest("http://simonstalenhag.se/tftl.html", "TALES FROM THE LOOP (2014)", "data/tftl.json", "tftlbig", "tftl");
        makeRequest("http://simonstalenhag.se/paleo.html", "PALEOART", "data/paleo.json", "paleobig", "paleo");
        makeRequest("http://simonstalenhag.se/other.html", "COMMISSIONS, UNPUBLISHED WORK AND SOLO PIECES", "data/other.json", "otherbig", "other", true);
    }

    Component.onCompleted: {
        runScript();
    }
}
