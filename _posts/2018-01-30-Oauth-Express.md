---
layout: post
title: How to use OAuth with Express in NodeJS
---

Often in apps, we need to pull certain information from other services. Consider a scenario where you need to build a web application to assist hiring and recruitment. In such scenario, we often need to pull data from other sources like (*Github, Linkedin, Stack Overflow etc*). One of the best way to handle that transfer of information without compromising on the security is via OAuth. 

The basic steps involved in Oauth are :-

- Register an application for the service you intend to use within their website. In this example, we would be using Github as an example. Give an appropriate app name and provide the Authorization callback URL as `http://localhost:3001/connect/github/callback`. We will get back to this later. 
- Users from your app are redirected to request their GitHub identity.
- Users are redirected back to your site by GitHub with the access token.
- Your app accesses the API with the user's access token.

So, lets start building this in Node and the module we would be using for this is [`grant`](https://github.com/simov/grant).

1. `npm install grant-express --save`
2. `grant` needs to have its config file for Oauth. So, lets create a config file

    We need 4 parameters for this config file :-

    - Protocol: use `http` for local development
    - Host: The server host (`http://localhost:3001`). 
    - Github key: You will get this when you register for an app in Github. If you didn't note down, you can still visit [here](https://github.com/settings/developers) and check/regenerate it.
    - Github secret: You will get this also when you register your app. 
    - `callback` is the most important parameter here as that's the route which gets invoked after the user is authenticated by Github. Provide the callback url as `/auth/handle_github_callback`.
    - `scope` is another important parameter which is used to request the scopes which app need to access information. You can see the list of scopes [here](https://developer.github.com/apps/building-oauth-apps/scopes-for-oauth-apps/). 
    
        *Do use [`config`](https://github.com/lorenwest/node-config) module to store all your config parameters across different environments*
    ```
    var config = require('config')
    module.exports = (github) => {
        return {
        server: {
            protocol: config.get('protocol'),
            host: config.get('host')
        },
        github: {
            key: github.key,
            secret: github.secret,
            callback: '/auth/handle_github_callback',
            scope: []
        }
        }
    }
    ```
3. Now, lets create the callback routes. This is the value we had specified within the config file as `callback`. 

    ```
    var express = require('express')
    var router = express.Router()
    var config = require('config')

    router.get('/handle_github_callback', function (req, res) {
        const {error, error_description, error_uri} = req.query
        if (error) {
            res.status(500).json({
            error,
            error_description,
            error_uri
            })
        } else {
            res.cookie('access-token-github', req.query.access_token)
            res.redirect(config.get('callback_url'))
        }
    })

    module.exports = router
    ```

    So, we can see that once the user is authenticated, we get the access token as one of the request query parameters. Usually within Oauth, the providers send in a parameter named as '`expires_in` field which indicates the time within which the token will expire. Surprisingly, for Github, it doesnt return this value. There are some important things you should keep in mind while dealing with access tokens. 
    - Ideally you should use a low expiration time, then renew. This minimizes the window for a malicious user to use a stolen JWT (you can revoke refresh tokens, which will then prevent your application from obtaining new id_tokens).
    - Some providers allow us to specify the expiration time. Grant allows us to configure that via custom parameters. Read the documentation [here](https://github.com/simov/grant#custom-parameters).
    - You need to check on the storage of these access tokens. For this example, i am sending the access token as a cookie. You need to consider the security aspects while storing in cookies. Storing in cookies are vulnerable to CSRF attacks. 


4. Finally the main piece connecting everything is to have the grant defined in your server app file (`app.js`). For the development environment, i store the key and secret within my node environment variables. I pass on those values to the function which creates my Grant config file and which is then injected into the app. 

    ```
    const {GITHUB_KEY, GITHUB_SECRET} = process.env
    const github = {
        key: GITHUB_KEY,
        secret: GITHUB_SECRET
    }
    var grant = new Grant(createConfig(github))
    app.use(grant)
    app.use('/auth', authCallback)
    ```

    The above code does 2 important things :-

    - The server is configured to hit the provider (*Github*) when you access via `http://localhost:3001/connect/github`. This would pop up the authentication screen as below. 
    - Once you approve it, it will be first redirected to `http://localhost:3001/connect/github/callback` (*this is what was specified when we were registering our app with Github as thats the first route which will be triggered by Grant*) which is then finally redirected to our callback routes which we had defined in our config file (`http://localhost:3001/auth/handle_github_callback).
    - Please note that certain routes are reserved for Grant.
        ```
        /connect/:provider/:override?
        /connect/:provider/callback
        ```
    - When our callback route is finally called, we get the `access_token` which is required to trigger certain Github authenticated API's.    

5. Try using that `access_token` to hit the route `` to fetch email of the user from Github

        `https://api.github.com/user?access_token=<access_token_val>`
