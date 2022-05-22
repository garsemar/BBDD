show dbs

use students

db.students.find({"gender": "H"})

db.students.find({"gender": "M"})

db.students.find({"birth_year": 1993})

db.students.find({"gender": "H", "birth_year": 1993})

db.students.find({"birth_year": {$gte: 1990, $lt: 2000}})

db.students.find({"gender": "H", "birth_year": {$lt: 1990}})

db.students.find({"gender": "M", "birth_year": {$lt: 1990}})

db.students.find({"gender": "H", "birth_year": {$gte: 1980, $lt: 1990}})

db.students.find({"gender": "M", "birth_year": {$gte: 1980, $lt: 1990}})

db.students.find({"birth_year": {$ne: 1985}})

db.students.find({$or: [{"birth_year": {$ne: 1970}}, {"birth_year": {$ne: 1980}}, {"birth_year": {$ne: 1990}}]})

db.students.find({"birth_year": {$mod: [2, 0]}})

db.students.find({"birth_year": {$mod: [10, 0]}})

db.students.find({"phone_aux": {$ne: ""}})

db.students.find({"lastname2": ""})

db.students.find({$and: [{"phone_aux": {$ne: ""}}, {"lastname2": ""}]})

db.students.find({"email": {$regex: "^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.net$"}})

db.students.find({"firstname": {$regex: "^[aeiouAEIOU]+[a-zA-Z0-9.-]"}})

db.students.find({firstname: {$exists: true}, $expr: {$gt: [{ $strLenCP: '$firstname'}, 13]}})
