module MyServerModule

using Oxygen
@oxidise

using DotEnv, ODBC, SQLStrings, DBInterface, Query, DataFrames, JSON3, TypedTables, HTTP
import NamedTupleTools
DotEnv.load!()

# Get values from environment
const server::String = ENV["DB_SERVER"]
const database::String = ENV["DB_NAME"]
const username::String = ENV["DB_USER"]
const password::String = ENV["DB_PASSWD"]

const conn_str = "DRIVER={ODBC Driver 18 for SQL Server};SERVER=$server;DATABASE=$database;Uid=$username;Pwd=$password;Authentication=ActiveDirectoryServicePrincipal;Encrypt=yes;"

_getconnection() = ODBC.Connection(conn_str)

const unmappedrdwbsquery = open("complex_query.sql", "r") do file
    read(file, String)
end

println(unmappedrdwbsquery)

query2 = """
select top(10) * from manual_exports.dbo.actual_costs;

"""


@get "/generateserror" function generateserror(req::Request)
    println("Test")
    data = DBInterface.execute(_getconnection(), unmappedrdwbsquery) 
#    data = DBInterface.execute(_getconnection(), query2) 
    tab = Table(data)
    println(tab[1:5, :])
    return tab
end


end # module MyServerModule
