// SPDX-FileCopyrightText: 2021-2026 Alexey Andreyev <dev@aa13q.ru>
// SPDX-License-Identifier: LicenseRef-KDE-Accepted-GPL

// Shared parsing logic for QML and qbs

function parseHtml(str, keyword) {
    var titlesSet = [];
    var regex = new RegExp("<a href=\"" + keyword + ".*jpg", "gm");
    var m;
    while ((m = regex.exec(str)) !== null) {
        if (m.index === regex.lastIndex) {
            regex.lastIndex++;
        }
        m.forEach(function(match, groupIndex) {
            var newLink = match.split("\"")[1].split("/").pop();
            if (titlesSet.indexOf(newLink) === -1) {
                titlesSet.push(newLink);
            }
        });
    }
    return titlesSet;
}

function formJSON(titles, section, keyword1, keyword2) {
    var jsonObj = {
        "simonstalenhag.se": []
    };
    var sRegex = /_?(big)?([\d]{4})?\.jpg/gm;
    for (var i = 0; i < titles.length; i++) {
        var title = titles[i];
        var smallTitle = title.replace(sRegex, "");
        sRegex.lastIndex = 0; // reset regex state
        jsonObj["simonstalenhag.se"].push({
            "name": smallTitle,
            "imagebig": "http://simonstalenhag.se/" + keyword1 + "/" + title,
            "image": "http://simonstalenhag.se/" + keyword2 + "/" + smallTitle + ".jpg",
            "section": section
        });
    }
    return jsonObj;
}

// Site configuration
var sites = [
    { url: "http://simonstalenhag.se/svema.html", section: "SWEDISH MACHINES (2024)", output: "data/svema.json", keyword1: "4k", keyword2: "bilder" },
    { url: "http://simonstalenhag.se/", section: "EUROPA MEKANO", output: "data/em.json", keyword1: "bilderbig", keyword2: "bilder" },
    { url: "http://simonstalenhag.se/labyrinth.html", section: "THE LABYRINTH (2020)", output: "data/labyrinth.json", keyword1: "bilderbig", keyword2: "bilder" },
    { url: "http://simonstalenhag.se/es.html", section: "THE ELECTRIC STATE (2017)", output: "data/es.json", keyword1: "bilderbig", keyword2: "bilder" },
    { url: "http://simonstalenhag.se/tftf.html", section: "THINGS FROM THE FLOOD (2016)", output: "data/tftf.json", keyword1: "tftfbig", keyword2: "tftf" },
    { url: "http://simonstalenhag.se/tftl.html", section: "TALES FROM THE LOOP (2014)", output: "data/tftl.json", keyword1: "tftlbig", keyword2: "tftl" },
    { url: "http://simonstalenhag.se/paleo.html", section: "PALEOART", output: "data/paleo.json", keyword1: "paleobig", keyword2: "paleo" },
    { url: "http://simonstalenhag.se/other.html", section: "COMMISSIONS, UNPUBLISHED WORK AND SOLO PIECES", output: "data/other.json", keyword1: "otherbig", keyword2: "other" }
];
