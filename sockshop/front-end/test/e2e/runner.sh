#!/usr/bin/env bash

code=0
testfile=$1
files=$testfile

if [ -z $testfile ]
then
  files=$(ls test/e2e/*_test.js)
fi

for test in $files
do
  docker exec -it dockeronly_cart-db_1 mongo data} --eval '["cart", "item"].forEach(function(col) { db[col].remove({}); });'
  $(npm bin)/casperjs test $test
  ret=$?
  if [ ! $ret == "0" ]; then code=1; fi
done

exit $code
