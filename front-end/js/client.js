function login() {
    var username = $('#username-modal').val();
    var password = $('#password-modal').val();
    $.ajax({
        url: "login",
        type: "GET",
        async: false,
        success: function (data, textStatus, jqXHR) {
            alert("Logged in as " + username);
            console.log('posted: ' + textStatus);
            console.log("logged_in cookie: " + $.cookie('logged_in'));
        },
        error: function (jqXHR, textStatus, errorThrown) {
            alert("Problem with your login credentials. " + errorThrown);
            console.log('error: ' + jqXHR);
            console.log('error: ' + textStatus);
            console.log('error: ' + errorThrown);
        },
        beforeSend: function (xhr) {
            xhr.setRequestHeader("Authorization", "Basic " + btoa(username + ":" + password));
        }
    });
}

(function ($) {
    $.querystring = (function (a) {
        var i,
            p,
            b = {};
        if (a === "") {
            return {};
        }
        for (i = 0; i < a.length; i += 1) {
            p = a[i].split('=');
            if (p.length === 2) {
                b[p[0]] = decodeURIComponent(p[1].replace(/\+/g, " "));
            }
        }
        return b;
    }(window.location.search.substr(1).split('&')));
}(jQuery));

function setNewUrl(name, value) {
    window.location.search = $.query.set(name, value);
}

function setNewPageSize(value) {
    window.location.search = $.query.set("page", 1).set("size", value);
}

function setNewPage(value) {
    window.location.search = $.query.set("page", value);
}