# Api module for Octoshell

This project rocks and uses MIT-LICENSE.

## What is it for?

You can export any data from Octoshell to outside via read-only requests. E.g. "all users with expired sessions" or something like this. You will be able to get such data using e.g. curl:

    curl -H 'X-OctoApi-Auth: SECRET_KEY' https:octoshell.site/api/req/REQ_NAME?arg1=...&arg2=...

## How to use it

In Administration office you can see 'Api' point. Inside you have three points: 'Access keys', "Exports" and 'Key Parameters'.

If you want to show any read-only API outside, create an 'Export'. Title is only for you, give new export appropriate name. Request is 'REQ_NAME' part in curl request. In 'Export text' you should type in the code, which will be executed inside Octoshell. BE CAREFULL!!!

Next (or may be first...), you should create access key. Simply type in the secret string into 'Key' field. This value should be used in X-OctoApi-Auth header while http request. Then associate this key with any exports and you can execute your requests!

If you want to use parameters in your requests, create 'Key parameter', give it a reasonable name, default value and associate it with appropriate exports. Parameters will be substituted inside export text: parameter 'arg1=123' will be expanded in text 'logger.warn "got request %arg1%"' to 'logger.warn "got request 123"'

That's all!
