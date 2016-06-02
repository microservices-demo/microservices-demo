function login() {
    var username = $('#username-modal').val();
    var password = $('#password-modal').val();
    $.ajax({
        url: "login",
        type: "GET",
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

function setNewPageSize(value) {
    location.search = $.query.set("page", 1).set("size", value);
}

function setNewPage(value) {
    location.search = $.query.set("page", value);
}

function setNewTags(value) {
    location.search = $.query.set("tags", value);
}

function resetTags() {
    location.search = $.query.remove("tags");
}