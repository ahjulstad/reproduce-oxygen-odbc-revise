
using Revise
using Pkg
import HTTP
import Oxygen

# Pkg.resolve()

import MyServerModule


allowed_origins = ["Access-Control-Allow-Origin" => "*"]

cors_headers = [
    allowed_origins...,
    "Access-Control-Allow-Headers" => "*",
    "Access-Control-Allow-Methods" => "GET, POST"
]

function CorsHandler(handle)
    return function (req::HTTP.Request)
        # return headers on OPTIONS request
        if HTTP.method(req) == "OPTIONS"
            return HTTP.Response(200, cors_headers)
        else
            r = handle(req)
            append!(r.headers, allowed_origins)
            return r
        end
    end
end


function ReviseHandler(handle)
    req -> begin
        Revise.revise()
        invokelatest(handle, req)
    end
end

server = MyServerModule.serve(port=8099; middleware=[ReviseHandler, CorsHandler], async=true);

sleep(5)

HTTP.get("http://localhost:8099/generateserror")

sleep(3)