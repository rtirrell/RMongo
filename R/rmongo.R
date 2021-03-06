#library('rJava')
#.jinit()
#.jaddClassPath("inst/java/r-mongo-scala-1.0-SNAPSHOT.jar")

setClass("RMongo", representation(javaMongo = "jobjRef"))

mongoDbConnect <- function(dbName, host="127.0.0.1", port=27017){
  rmongo <- new("RMongo", javaMongo = .jnew("com/quid/RMongo", dbName, host, as.integer(port)))
  rmongo
}

setGeneric("dbAuthenticate", function(rmongo.object, username, password) standardGeneric("dbAuthenticate"))
setMethod("dbAuthenticate", signature(rmongo.object="RMongo", username="character", password="character"),
   function(rmongo.object, username, password){
    results <- .jcall(rmongo.object@javaMongo, "Z", "dbAuthenticate", username, password)
    results
  }
)

setGeneric("dbShowCollections", function(rmongo.object) standardGeneric("dbShowCollections"))
setMethod("dbShowCollections", signature(rmongo.object="RMongo"),
   function(rmongo.object){
    results <- .jcall(rmongo.object@javaMongo, "[S", "dbShowCollections")
    results
  }
)
 
setGeneric("dbInsertDocument", function(rmongo.object, collection, doc) standardGeneric("dbInsertDocument"))
setMethod("dbInsertDocument", signature(rmongo.object="RMongo", collection="character", doc="character"),
  function(rmongo.object, collection, doc){
    results <- .jcall(rmongo.object@javaMongo, "S", "dbInsertDocument", collection, doc)
    results
  }
)

setGeneric("dbGetQueryForKeys", function(rmongo.object, collection, query, keys, skip=0, limit=1000) standardGeneric("dbGetQueryForKeys"))
setMethod("dbGetQueryForKeys", signature(rmongo.object="RMongo", collection="character", query="character", keys="character", skip='numeric', limit='numeric'),
  function(rmongo.object, collection, query, keys, skip, limit){
    results <- .jcall(rmongo.object@javaMongo, "S", "dbGetQuery", collection, query, keys, skip, limit)
    if(results == ""){
      data.frame()
    }else{
      con <- textConnection(results)
      data.frame.results <- read.csv(con, sep="", stringsAsFactors=FALSE)
      close(con)

      data.frame.results
    }
  }
)

setMethod("dbGetQueryForKeys", signature(rmongo.object="RMongo", collection="character", query="character", keys="character", skip='missing', limit='missing'),
  function(rmongo.object, collection, query, keys, skip, limit){
    dbGetQueryForKeys(rmongo.object, collection, query, keys, 0, 1000)
  }
)

setGeneric("dbGetQuery", function(rmongo.object, collection, query, skip=0, limit=1000) standardGeneric("dbGetQuery"))
setMethod("dbGetQuery", signature(rmongo.object="RMongo", collection="character", query="character", skip='numeric', limit='numeric'),
  function(rmongo.object, collection, query, skip, limit){
    dbGetQueryForKeys(rmongo.object, collection, query, "{}", skip, limit)
  }
)

setMethod("dbGetQuery", signature(rmongo.object="RMongo", collection="character", query="character", skip='missing', limit='missing'),
  function(rmongo.object, collection, query, skip=0, limit=1000){
    dbGetQueryForKeys(rmongo.object, collection, query, "{}", skip, limit)
  }
)

setGeneric("dbDisconnect", function(rmongo.object) standardGeneric("dbDisconnect"))
setMethod("dbDisconnect", signature(rmongo.object="RMongo"),
  function(rmongo.object){
    .jcall(rmongo.object@javaMongo, "V", "close")
  }
)

