// SPDX-FileCopyrightText: 2021 Alexey Andreyev <aa13q@ya.ru>
//
// SPDX-License-Identifier: LicenseRef-KDE-Accepted-GPL

import QtQuick.Window 2.15
import QtQuick 2.15

Window {
    // see also: 
    // https://github.com/a-andreyev/harbour-imagitron/blob/master/src/imagitronlistmodel.cpp#L88
    function parseHtml(str, keyword="bilder") {
        const titlesSet = new Set()
        const regex = new RegExp("<a href=\"" + keyword + "big.*jpg", "gm")
        let m
        while ((m = regex.exec(str)) !== null) {
            if (m.index === regex.lastIndex) {
                regex.lastIndex++;
            }
            m.forEach((match, groupIndex) => {
                const newLink = match.split("\"")[1].split("/").pop()
                titlesSet.add(newLink)
            })
        }
        return titlesSet
    }
    
    function formJSON(titles, section, keyword="bilder") {
        var jsonObj = { 
            "simonstalenhag.se" : [] 
        }
        for (let title of titles) {
            const sRegex = /_?(big)?([\d]{4})?\.jpg/gm
            var smallTitle = title.replace(sRegex, "")
            jsonObj["simonstalenhag.se"].push(
                {
                    "name": smallTitle,
                    "imagebig": "http://simonstalenhag.se/"+keyword+"big/"+title,
                    "image": "http://simonstalenhag.se/"+keyword+"/"+smallTitle+".jpg",
                    "section": section
                }
            )
        }
        return jsonObj
    }

    function makeRequest(url, section, keyword="bilder", quitOnFinish = false) {
        var doc = new XMLHttpRequest()
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                const str = doc.responseText
                var titles = parseHtml(str, keyword)
                var x = formJSON(titles, section, keyword)
                console.log(JSON.stringify(x, null, 2))
                if (quitOnFinish) {
                    Qt.quit()
                }
            }
        }

        doc.open("GET", url)
        doc.send()
    }
    
    function runScript() {
        makeRequest("http://simonstalenhag.se/", "EUROPA MEKANO")
        makeRequest("http://simonstalenhag.se/labyrinth.html", "THE LABYRINTH (2020)")
        makeRequest("http://simonstalenhag.se/es.html", "THE ELECTRIC STATE (2017)")
        makeRequest("http://simonstalenhag.se/tftf.html", "THINGS FROM THE FLOOD (2016)", "tftf")
        makeRequest("http://simonstalenhag.se/tftl.html", "TALES FROM THE LOOP (2014)", "tftl")
        makeRequest("http://simonstalenhag.se/paleo.html", "PALEOART", "paleo")
        makeRequest("http://simonstalenhag.se/other.html", "COMMISSIONS, UNPUBLISHED WORK AND SOLO PIECES", "other", true)
    }
    
    Component.onCompleted: {
        runScript()
    }
}
