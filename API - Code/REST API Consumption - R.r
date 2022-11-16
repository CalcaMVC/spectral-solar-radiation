library("RCurl")
library("rjson")

# Accept SSL certificates issued by public Certificate Authorities
options(RCurlOptions = list(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"), ssl.verifypeer = FALSE))

h = basicTextGatherer()
hdr = basicHeaderGatherer()

# Request data goes here
# The example below assumes JSON formatting which may be updated
# depending on the format your endpoint expects.
# More information can be found here:
# https://docs.microsoft.com/azure/machine-learning/how-to-deploy-advanced-entry-script
req = fromJSON('{
  "Inputs": {
    "data": [
      {
        "year": 0,
        "month": 0,
        "day": 0,
        "julian-day": 0,
        "hour": 0,
        "minute": 0,
        "solar-elevation": 0.0,
        "ig": 0.0,
        "extraterrestrial-uv": 0.0
      }
    ]
  },
  "GlobalParameters": 0.0
}')

body = enc2utf8(toJSON(req))
api_key = "m9acXFQejiEw0nOMDdNoRHYH3JxkGjar" # Replace this with the API key for the web service
authz_hdr = paste('Bearer', api_key, sep=' ')

h$reset()

# The azureml-model-deployment header will force the request to go to a specific deployment.
# Remove this header to have the request observe the endpoint traffic rules
curlPerform(
    url = "http://cd6c3198-6ebe-4702-aadb-0724f58b96ee.eastus.azurecontainer.io/score",
    httpheader=c('Content-Type' = "application/json", 'Authorization' = authz_hdr),
    postfields=body,
    writefunction = h$update,
    headerfunction = hdr$update,
    verbose = TRUE
)

headers = hdr$value()
httpStatus = headers["status"]
if (httpStatus >= 400)
{
    print(paste("The request failed with status code:", httpStatus, sep=" "))

    # Print the headers - they include the request ID and the timestamp, which are useful for debugging the failure
    print(headers)
}

print("Result:")
result = h$value()
print(result)