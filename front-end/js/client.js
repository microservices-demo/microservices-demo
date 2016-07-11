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
            console.log('error: ' + JSON.stringify(jqXHR));
            console.log('error: ' + textStatus);
            console.log('error: ' + errorThrown);
        },
        beforeSend: function (xhr) {
            xhr.setRequestHeader("Authorization", "Basic " + btoa(username + ":" + password));
        }
    });
}

function logout() {
    $.removeCookie('logged_in');
    location.reload();
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

function order() {
    if (!$.cookie('logged_in')) {
        alert("You must be logged in to place an order.");
        return false;
    }

    var success = false;
    $.ajax({
        url: "orders",
        type: "POST",
        async: false,
        success: function (data, textStatus, jqXHR) {
            if (jqXHR.status == 201) {
                console.log("Order placed.");
                alert("Order placed!");
                deleteCart();
                success = true;
            }
        },
        error: function (jqXHR, textStatus, errorThrown) {
            console.log('error: ' + JSON.stringify(jqXHR));
            console.log('error: ' + textStatus);
            console.log('error: ' + errorThrown);
            if (jqXHR.status == 406) {
                alert("Error placing order. Payment declined.");
            }
        }
    });
    return success;
}

function deleteCart() {
    $.ajax({
        url: "cart",
        type: "DELETE",
        async: true,
        success: function (data, textStatus, jqXHR) {
            console.log("Cart deleted.");
        },
        error: function (jqXHR, textStatus, errorThrown) {
            console.log('error: ' + JSON.stringify(jqXHR));
            console.log('error: ' + textStatus);
            console.log('error: ' + errorThrown);
        }
    });
}

function addToCart(id) {
    console.log("Sending request to add to cart: " + id);
    $.ajax({
        url: "cart",
        type: "POST",
        data: JSON.stringify({"id": id}),
        success: function (data, textStatus, jqXHR) {
            console.log('Item added: ' + id + ', ' + textStatus);
            location.reload();
        },
        error: function (jqXHR, textStatus, errorThrown) {
            console.error('Could not add item: ' + id + ', due to: ' + textStatus + ' | ' + errorThrown);
        }
    });
}

function username(id, callback) {
    console.log("Requesting user account information " + id);
    $.ajax({
        url: "accounts/" + id,
        type: "GET",
        success: function (data, textStatus, jqXHR) {
            callback(JSON.parse(data).firstName + " " + JSON.parse(data).lastName);
        },
        error: function (jqXHR, textStatus, errorThrown) {
            console.error('Could not get user information: ' + id + ', due to: ' + textStatus + ' | ' + errorThrown);
        }
    });
}
