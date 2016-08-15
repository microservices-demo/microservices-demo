const hooks = require('hooks');
const mysql = require('mysql');

let db;


// Setup database connection before Dredd starts testing
hooks.beforeAll((transactions, done) => {
    db  = mysql.createConnection({
	host     : process.env.MYSQL_PORT_3306_TCP_ADDR,
	port     : 3306,
	user     : "root",
	password : process.env.MYSQL_ENV_MYSQL_ROOT_PASSWORD,
	database : process.env.MYSQL_ENV_MYSQL_DATABASE,
	multipleStatements: true
    });
    db.connect();
    db.query("CREATE USER IF NOT EXISTS 'catalogue_user' IDENTIFIED BY 'default_password';\
            GRANT ALL ON socksdb.* TO 'catalogue_user';\
            );",
	     (e, r) => {
		 if (e) {
		     console.error(r);
		 }
		 done ();});
    
});

// Close database connection after Dredd finishes testing
hooks.afterAll((transactions, done) => {
    // drop database
    done();

});

hooks.beforeEach((transaction, done) => {
    db.query("CREATE TABLE IF NOT EXISTS sock (\
            sock_id varchar(40) NOT NULL, \
            name varchar(20), \
            description varchar(200), \
            price float, \
            count int, \
            image_url_1 varchar(40), \
            image_url_2 varchar(40), \
            PRIMARY KEY(sock_id)\
            );\
            CREATE TABLE IF NOT EXISTS tag (\
            tag_id MEDIUMINT NOT NULL AUTO_INCREMENT, \
            name varchar(20), \
            PRIMARY KEY(tag_id)\
            );\
            CREATE TABLE IF NOT EXISTS sock_tag (\
            sock_id varchar(40), \
            tag_id MEDIUMINT NOT NULL, \
            FOREIGN KEY (sock_id) \
            REFERENCES sock(sock_id), \
            FOREIGN KEY(tag_id)\
            REFERENCES tag(tag_id)\
            );\
            INSERT INTO sock VALUES (\"a0a4f044-b040-410d-8ead-4de0446aec7e\", \"Nerd leg\", \"For all those leg lovers out there. A perfect example of a swivel chair trained calf. Meticulously trained on a diet of sitting and Pina Coladas. Phwarr...\", 7.99, 115, \"/catalogue/images/bit_of_leg_1.jpeg\", \"/catalogue/images/bit_of_leg_2.jpeg\");\
            INSERT INTO sock VALUES (\"808a2de1-1aaa-4c25-a9b9-6612e8f29a38\", \"Crossed\", \"A mature sock, crossed, with an air of nonchalance.\",  17.32, 738, \"/catalogue/images/cross_1.jpeg\", \"/catalogue/images/cross_2.jpeg\");\
            INSERT INTO sock VALUES (\"510a0d7e-8e83-4193-b483-e27e09ddc34d\", \"SuperSport XL\", \"Ready for action. Engineers: be ready to smash that next bug! Be ready, with these super-action-sport-masterpieces. This particular engineer was chased away from the office with a stick.\",  15.00, 820, \"/catalogue/images/puma_1.jpeg\", \"/catalogue/images/puma_2.jpeg\");\
            INSERT INTO sock VALUES (\"03fef6ac-1896-4ce8-bd69-b798f85c6e0b\", \"Holy\", \"Socks fit for a Messiah. You too can experience walking in water with these special edition beauties. Each hole is lovingly proggled to leave smooth edges. The only sock approved by a higher power.\",  99.99, 1, \"/catalogue/images/holy_1.jpeg\", \"/catalogue/images/holy_2.jpeg\");\
            INSERT INTO sock VALUES (\"d3588630-ad8e-49df-bbd7-3167f7efb246\", \"YouTube.sock\", \"We were not paid to sell this sock. It's just a bit geeky.\",  10.99, 801, \"/catalogue/images/youtube_1.jpeg\", \"/catalogue/images/youtube_2.jpeg\");\
            INSERT INTO sock VALUES (\"819e1fbf-8b7e-4f6d-811f-693534916a8b\", \"Figueroa\", \"enim officia aliqua excepteur esse deserunt quis aliquip nostrud anim\",  14, 808, \"/catalogue/images/WAT.jpg\", \"/catalogue/images/WAT2.jpg\");\
            INSERT INTO sock VALUES (\"zzz4f044-b040-410d-8ead-4de0446aec7e\", \"Classic\", \"Keep it simple.\",  12, 127, \"/catalogue/images/classic.jpg\", \"/catalogue/images/classic2.jpg\");\
            INSERT INTO sock VALUES (\"3395a43e-2d88-40de-b95f-e00e1502085b\", \"Colourful\", \"proident occaecat irure et excepteur labore minim nisi amet irure\",  18, 438, \"/catalogue/images/colourful_socks.jpg\", \"/catalogue/images/colourful_socks.jpg\");\
            INSERT INTO sock VALUES (\"837ab141-399e-4c1f-9abc-bace40296bac\", \"Cat socks\", \"consequat amet cupidatat minim laborum tempor elit ex consequat in\",  15, 175, \"/catalogue/images/catsocks.jpg\", \"/catalogue/images/catsocks2.jpg\");\
            \
            INSERT INTO tag (name) VALUES (\"brown\");\
            INSERT INTO tag (name) VALUES (\"geek\");\
            INSERT INTO tag (name) VALUES (\"formal\");\
            INSERT INTO tag (name) VALUES (\"blue\");\
            INSERT INTO tag (name) VALUES (\"skin\");\
            INSERT INTO tag (name) VALUES (\"red\");\
            INSERT INTO tag (name) VALUES (\"action\");\
            INSERT INTO tag (name) VALUES (\"sport\");\
            INSERT INTO tag (name) VALUES (\"black\");\
            INSERT INTO tag (name) VALUES (\"magic\");\
            INSERT INTO tag (name) VALUES (\"green\");\
            INSERT INTO sock_tag VALUES (\"a0a4f044-b040-410d-8ead-4de0446aec7e\", \"4\");\
            INSERT INTO sock_tag VALUES (\"a0a4f044-b040-410d-8ead-4de0446aec7e\", \"5\");\
            INSERT INTO sock_tag VALUES (\"808a2de1-1aaa-4c25-a9b9-6612e8f29a38\", \"4\");\
            INSERT INTO sock_tag VALUES (\"808a2de1-1aaa-4c25-a9b9-6612e8f29a38\", \"6\");\
            INSERT INTO sock_tag VALUES (\"808a2de1-1aaa-4c25-a9b9-6612e8f29a38\", \"7\");\
            INSERT INTO sock_tag VALUES (\"808a2de1-1aaa-4c25-a9b9-6612e8f29a38\", \"3\");\
            INSERT INTO sock_tag VALUES (\"510a0d7e-8e83-4193-b483-e27e09ddc34d\", \"8\");\
            INSERT INTO sock_tag VALUES (\"510a0d7e-8e83-4193-b483-e27e09ddc34d\", \"9\");\
            INSERT INTO sock_tag VALUES (\"510a0d7e-8e83-4193-b483-e27e09ddc34d\", \"3\");\
            INSERT INTO sock_tag VALUES (\"03fef6ac-1896-4ce8-bd69-b798f85c6e0b\", \"10\");\
            INSERT INTO sock_tag VALUES (\"03fef6ac-1896-4ce8-bd69-b798f85c6e0b\", \"7\");\
            INSERT INTO sock_tag VALUES (\"d3588630-ad8e-49df-bbd7-3167f7efb246\", \"2\");\
            INSERT INTO sock_tag VALUES (\"d3588630-ad8e-49df-bbd7-3167f7efb246\", \"3\");\
            INSERT INTO sock_tag VALUES (\"819e1fbf-8b7e-4f6d-811f-693534916a8b\", \"3\");\
            INSERT INTO sock_tag VALUES (\"819e1fbf-8b7e-4f6d-811f-693534916a8b\", \"11\");\
            INSERT INTO sock_tag VALUES (\"819e1fbf-8b7e-4f6d-811f-693534916a8b\", \"4\");\
            INSERT INTO sock_tag VALUES (\"zzz4f044-b040-410d-8ead-4de0446aec7e\", \"1\");\
            INSERT INTO sock_tag VALUES (\"zzz4f044-b040-410d-8ead-4de0446aec7e\", \"11\");\
            INSERT INTO sock_tag VALUES (\"3395a43e-2d88-40de-b95f-e00e1502085b\", \"1\");\
            INSERT INTO sock_tag VALUES (\"3395a43e-2d88-40de-b95f-e00e1502085b\", \"4\");\
            INSERT INTO sock_tag VALUES (\"837ab141-399e-4c1f-9abc-bace40296bac\", \"1\");\
            INSERT INTO sock_tag VALUES (\"837ab141-399e-4c1f-9abc-bace40296bac\", \"11\");\
            INSERT INTO sock_tag VALUES (\"837ab141-399e-4c1f-9abc-bace40296bac\", \"3\");\
            \
   ", (e, r) => {
       if (e) {
	   console.error(e);
       }
       done ();});
    
});

hooks.afterEach((transaction, done) => {
    db.query("DROP TABLE sock_tag;\
              DROP TABLE sock;\
              DROP TABLE tag;", (e, r) => {
		  if (e) {
		      console.error(e);
		  }
		  done ();
	      });
});
