-- SQL

/* 1. Devolver restaurant_id, name, borough y cuisine pero excluyendo _id para un documento (el primero). */

db.restaurants.findOne({},{ restaurant_id: 1, name: 1, borough: 1, cuisine: 1, _id: 0})

/* RES
{
	"borough" : "Manhattan",
	"cuisine" : "American",
	"name" : "Cafe Metro",
	"restaurant_id" : "40363298"
}
*/

/* 2. Devolver restaurant_id, name, borough y cuisine para los primeros 3 restaurantes que contengan 'Bake'
en alguna parte de su nombre. */

db.restaurants.find({ name: /Bake/ },{ restaurant_id:1, name:1, borough: 1, cuisine:1 }).limit(3)

/* RES
{ "_id" : ObjectId("5eb3d668b31de5d588f42a67"), "borough" : "Staten Island", "cuisine" : "American", "name" : "Perkins Family Restaurant & Bakery", "restaurant_id" : "40370910" }
{ "_id" : ObjectId("5eb3d668b31de5d588f42aea"), "borough" : "Queens", "cuisine" : "Caribbean", "name" : "Western Bakery", "restaurant_id" : "40377560" }
{ "_id" : ObjectId("5eb3d668b31de5d588f4292e"), "borough" : "Bronx", "cuisine" : "Bakery", "name" : "Morris Park Bake Shop", "restaurant_id" : "30075445" }
*/

/* 3 Contar los restaurantes de comida (cuisine) china (Chinese) o tailandesa (Thai) del barrio (borough)
Bronx. Consultar or versus in. */

db.restaurants.count({ cuisine: {$in:["Chinese", "Thai"]}, borough: "Bronx"})

/* RES
325 */

-- NoSQL

/* 1. Traer 3 restaurantes que hayan recibido al menos una calificación de grade 'A' con score mayor a 50. Una
misma calificación debe cumplir con ambas condiciones simultáneamente; investigar el operador
elemMatch. */

db.restaurants.find({ grades: { $elemMatch: {grade: "A", score: {$gt: 50} }} }).limit(3)

/* 2. ¿A cuántos documentos les faltan las coordenadas geográficas? En otras palabras, revisar si el tamaño de
address.coord es 0 y contar. */

db.restaurants.count({ "address.coord": { $size: 0 } })

/* RES
2 */

db.restaurants.find({ "address.coord": { $size: 0 } }).pretty()

/* RES
{
	"_id" : ObjectId("5eb3d668b31de5d588f439aa"),
	"address" : {
		"building" : "0",
		"coord" : [ ],
		"street" : "Wards Island/2Fl",
		"zipcode" : "10057"
	},
	"borough" : "Manhattan",
	"cuisine" : "American",
	"grades" : [
		{
			"date" : ISODate("2013-09-10T00:00:00Z"),
			"grade" : "A",
			"score" : 12
		},
		{
			"date" : ISODate("2013-01-28T00:00:00Z"),
			"grade" : "A",
			"score" : 6
		},
		{
			"date" : ISODate("2012-07-16T00:00:00Z"),
			"grade" : "B",
			"score" : 20
		},
		{
			"date" : ISODate("2012-02-06T00:00:00Z"),
			"grade" : "A",
			"score" : 9
		},
		{
			"date" : ISODate("2011-08-24T00:00:00Z"),
			"grade" : "A",
			"score" : 7
		}
	],
	"name" : "Fratelli'S Market Place",
	"restaurant_id" : "40959339"
}
{
	"_id" : ObjectId("5eb3d669b31de5d588f48945"),
	"address" : {
		"building" : "397",
		"coord" : [ ],
		"street" : "Tompkins Ave",
		"zipcode" : "11216"
	},
	"borough" : "Brooklyn",
	"cuisine" : "American",
	"grades" : [
		{
			"date" : ISODate("2015-01-20T00:00:00Z"),
			"grade" : "Not Yet Graded",
			"score" : 17
		}
	],
	"name" : "Eugene & Co",
	"restaurant_id" : "50017256"
} */

/* 3. Devolver name, borough, cuisine y grades para los primeros 3 restaurantes; de cada documento solo la
última calificación. Ver el operador slice. */

db.restaurants.find({}, { name: 1, borough: 1, cuisine: 1, grades: { $slice: -1 } }).limit(3).pretty()

/* RES
{
	"_id" : ObjectId("5eb3d668b31de5d588f4294f"),
	"borough" : "Manhattan",
	"cuisine" : "American",
	"grades" : [
		{
			"date" : ISODate("2011-09-09T00:00:00Z"),
			"grade" : "A",
			"score" : 13
		}
	],
	"name" : "Cafe Metro"
}
{
	"_id" : ObjectId("5eb3d668b31de5d588f42930"),
	"borough" : "Queens",
	"cuisine" : "American",
	"grades" : [
		{
			"date" : ISODate("2012-02-10T00:00:00Z"),
			"grade" : "A",
			"score" : 13
		}
	],
	"name" : "Brunos On The Boulevard"
}
{
	"_id" : ObjectId("5eb3d668b31de5d588f42955"),
	"borough" : "Manhattan",
	"cuisine" : "Pizza",
	"grades" : [
		{
			"date" : ISODate("2011-09-26T00:00:00Z"),
			"grade" : "A",
			"score" : 0
		}
	],
	"name" : "Domino'S Pizza"
}
*/

-- DESAFIANTES

/* 1. ¿Cuál es top 3 de tipos de cocina (cuisine) que podemos encontrar entre los datos? Googlear "mongodb group by
field, count it and sort it". Ver etapa limit del pipeline de agregación. */

db.restaurants.aggregate([{ $group: {_id: "$cuisine", count: {$sum: 1} }}, { $sort: {"count": -1 }}, { $limit: 3 }])

/* RES
{ "_id" : "American", "count" : 6183 }
{ "_id" : "Chinese", "count" : 2418 }
{ "_id" : "Café/Coffee/Tea", "count" : 1214 } */

/* 2. ¿Cuáles son los barrios más desarrollados gastronómicamente? Calcular el promedio ($avg) de puntaje
(grades.score) por barrio; considerando restaurantes que tengan más de tres reseñas; ordenar barrios con mejor
puntaje arriba. Ayuda: 
a. match es una etapa que filtra documentos según una condición, similar a db.orders.find(<condición>).
b. Parece necesario deconstruir las listas grades para producir un documento por cada puntaje utilizando la
etapa unwind. */

db.restaurants.aggregate([ { $match: { grades: { $gt: { $size: 3}} }}, { $unwind: "$grades" }, { $group: { _id: "$borough", average_score: { $avg: "$grades.score"} }}, { $sort: { "average_score": -1 }} ])

/* RES
{ "_id" : "Queens", "average_score" : 11.634865110930088 }
{ "_id" : "Brooklyn", "average_score" : 11.44797595737899 }
{ "_id" : "Manhattan", "average_score" : 11.418151216986018 }
{ "_id" : "Staten Island", "average_score" : 11.370957711442786 }
{ "_id" : "Bronx", "average_score" : 11.036186099942562 }
{ "_id" : "Missing", "average_score" : 9.632911392405063 } */

/* 3. Una persona con ganas de comer está en longitud -73.93414657 y latitud 40.82302903, ¿qué opciones tiene en
500 metros a la redonda? Consultar geospatial tutorial. */ 

db.restaurants.createIndex( { "address.coord": "2d" })
db.restaurants.find( { "address.coord": { $geoWithin: { $centerSphere: [ [ -73.93414657, 40.82302903 ], 0.5 / 6300] } } }).pretty()