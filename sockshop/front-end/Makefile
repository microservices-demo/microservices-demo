.PHONY: test coverage

deps:
	@npm install

server:
	@npm start

test:
	@$$(npm bin)/istanbul cover $$(npm bin)/_mocha -- -R nyan

coverage:
	@open coverage/lcov-report/index.html
