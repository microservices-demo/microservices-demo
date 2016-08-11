const hooks = require('hooks');
const {MongoClient} = require('mongodb');
const ObjectID = require('mongodb').ObjectID;

let db;

const address = [
    {"_id":ObjectID("579f21ae98684924944651bd"),"_class":"works.weave.socks.accounts.entities.Address","number":"69","street":"Wilson Street","city":"Hartlepool","postcode":"TS26 8JU","country":"United Kingdom"},
    {"_id":ObjectID("579f21ae98684924944651c0"),"_class":"works.weave.socks.accounts.entities.Address","number":"122","street":"Radstone WayNet","city":"Northampton","postcode":"NN2 8NT","country":"United Kingdom"},
    {"_id":ObjectID("579f21ae98684924944651c3"),"_class":"works.weave.socks.accounts.entities.Address","number":"3","street":"Radstone Way","city":"Northampton","postcode":"NN2 8NT","country":"United Kingdom"}
];


const card = [
    {"_id":ObjectID("579f21ae98684924944651be"),"_class":"works.weave.socks.accounts.entities.Card","longNum":"8575776807334952","expires":"08/19","ccv":"014"},
    {"_id":ObjectID("579f21ae98684924944651c1"),"_class":"works.weave.socks.accounts.entities.Card","longNum":"8918468841895184","expires":"08/19","ccv":"597"},
    {"_id":ObjectID("579f21ae98684924944651c4"),"_class":"works.weave.socks.accounts.entities.Card","longNum":"6426429851404909","expires":"08/19","ccv":"381"}
];

const cart = [
    {"_id":ObjectID("579f21de98689ebf2bf1cd2f"),"_class":"works.weave.socks.cart.entities.Cart","customerId":"579f21ae98684924944651bf","items":[{"$ref":"item","$id":ObjectID("579f227698689ebf2bf1cd31")},{"$ref":"item","$id":ObjectID("579f22ac98689ebf2bf1cd32")}]},
    {"_id":ObjectID("579f21e298689ebf2bf1cd30"),"_class":"works.weave.socks.cart.entities.Cart","customerId":"579f21ae98684924944651bfaa","items":[]}
];


const item = [
    {"_id":ObjectID("579f227698689ebf2bf1cd31"),"_class":"works.weave.socks.cart.entities.Item","itemId":"819e1fbf-8b7e-4f6d-811f-693534916a8b","quantity":20,"unitPrice":99.0}
];


const customer = [
    {"_id":"579f21ae98684924944651bf","_class":"works.weave.socks.accounts.entities.Customer","firstName":"Eve","lastName":"Berger","username":"Eve_Berger","addresses":[{"$ref":"address","$id":ObjectID("579f21ae98684924944651bd")}],"cards":[{"$ref":"card","$id":ObjectID("579f21ae98684924944651be")}]
    },
    {"_id":"579f21ae98684924944651c2","_class":"works.weave.socks.accounts.entities.Customer","firstName":"User","lastName":"Name","username":"user","addresses":[{"$ref":"address","$id":ObjectID("579f21ae98684924944651c0")}],"cards":[{"$ref":"card","$id":ObjectID("579f21ae98684924944651c1")}]},
    {"_id":"579f21ae98684924944651c5","_class":"works.weave.socks.accounts.entities.Customer","firstName":"User1","lastName":"Name1","username":"user1","addresses":[{"$ref":"address","$id":ObjectID("579f21ae98684924944651c3")}],"cards":[{"$ref":"card","$id":ObjectID("579f21ae98684924944651c4")}]}
];


// Setup database connection before Dredd starts testing
hooks.beforeAll((transactions, done) => {
    var MongoEndpoint = process.env.MONGO_ENDPOINT ||  'mongodb://localhost:32769/data';
    MongoClient.connect(MongoEndpoint, function(err, conn) {
	if (err) {
	    console.error(err);
	}
	db = conn;
	done(err);
    });
});

// Close database connection after Dredd finishes testing
hooks.afterAll((transactions, done) => {
    db.dropDatabase();
    done();

});

hooks.beforeEach((transaction, done) => {
    var promisesToKeep = [
	db.collection('customer').remove({}),
	db.collection('customer').insertMany(customer),
	db.collection('card').remove({}),
	db.collection('card').insertMany(card),
	db.collection('cart').remove({}),
	db.collection('cart').insertMany(cart),
	db.collection('address').remove({}),
	db.collection('address').insertMany(address),
	db.collection('item').remove({}),
	db.collection('item').insertMany(item)
    ];
    Promise.all(promisesToKeep).then(function(vls) {
	done();
    }, function(vls) {
	console.error(vls);
	done();
    });   
});


hooks.before("/orders > POST", function(transaction, done) {
    transaction.skip = true;
    transaction.request.headers['Content-Type'] = 'application/json';
    transaction.request.body = JSON.stringify(
	{
	    "customer":"http://accounts/customers/579f21ae98684924944651bd",
	    "address": "http://accounts/addresses/579f21ae98684924944651bd",
	    "card" : "http://accounts/cards/579f21ae98684924944651bf",
	    "items": "http://accounts/items/"
	}
    );

    done()

});
