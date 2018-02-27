---
layout: post
title: How to use Reddit's Application Only OAuth
---

There are tons of applications being built for Reddit and some of them don't require user authorization. Some examples which fall under this category are :-

* Viewing top/hot/new list of a particular reddit sub
* Search

Some of the apps right now use the legacy API's which can be invoked by appending `.json` to any reddit link as an alternative to go around the OAuth. The major drawback of using legacy API being :-

* They are highly throttled as compared to OAuth API's.
* They can go off any time as Reddit categorically states in their documentation that OAuth is a must. 
* When you want to add the authorized features to your app, you will have to rewrite the entire API code. 

Many developers who use some features of Reddit and which doesn't require authorization, feel its a kind of burden to implement OAuth techniques. For that case, Reddit has something called as "Application only OAuth" which makes it simpler. As per the reddit documentation it states :-


> In some cases, 3rd party app clients may wish to make API requests without a user context. App clients can request a "user-less" Authorization token via either the standard client_credentials grant, or the reddit specific extension to this grant, https://oauth.reddit.com/grants/installed_client.

You can read more about this [here](https://github.com/reddit-archive/reddit/wiki/OAuth2#application-only-oauth).

So lets get started with how to go about using this :-

1. Create an application in Reddit. This is a fairly simple step where you provide basic details about the app you are building. Goto Preferences --> Apps --> Create app
2. Keep a note of the client Id which gets generated when you create the app. 
3. Send a POST request to `https://www.reddit.com/api/v1/access_token` with the below parameters :-
    
    Headers :-
    ```
    Authorization: Basic Base64Encode(CLIENT_ID:)

    Content-Type: application/x-www-form-urlencoded
    ```

    Please note that when you set Authorization header, you will be doing a Base64 encode of just the client ID and a blank password. So it will be in the format :-
    ```
    'Authorization': `Basic ${Buffer.from(`${REDDIT_CLIENT_ID}:`).toString('base64')}` // Put password as empty
    ```

    Body:-

    ```
    grant_type: https://oauth.reddit.com/grants/installed_client
    device_id: DO_NOT_TRACK_THIS_DEVICE
    ```

   As you can see i am using the device id as `DO_NOT_TRACK_THIS_DEVICE` so as to keep anonymity. But if you wish to send in device ID, reddit has stated the below criteria for `device_id` :-

   >You should generate and save unique ID on your client. The ID should be unique per-device or per-user of your app. A randomized or pseudo-randomized value is acceptable for generating the ID; however, you should retain and re-use the same device_id when renewing your access token.

4. You would get an `access-token` back from Step 3. The structure of the response will be like below :-

   ```
   {
    "access_token": "abcdef",
    "token_type": "bearer",
    "device_id": "DO_NOT_TRACK_THIS_DEVICE",
    "expires_in": 3600,
    "scope": "*"
   }
   ```
5. Now say, in my app i would like to fetch the top posts from `bitcoin` subreddit. I would be triggering a `GET` request to `https://oauth.reddit.com/r/bitcoin/new` and pass in the authorization header as below with the `access-token` :-

   Headers:-
   ```
   Authorization: Bearer {access-token}
   ```

## Code Example

I created a gist of a sample code in NodeJS for an express route which does the steps as stated above.
<script src="https://gist.github.com/RanjithNair/18f40c6d6887b5165cd698ac506fe7c4.js"></script>

## Conclusion

It's better to switch away from the legacy Reddit API's and to leverage Application only OAuth for the long term. It's pretty simple to use this and that's the recommended way as per Reddit as well. Please make sure you before you move to PROD, you must read the [terms and register](https://docs.google.com/forms/d/e/1FAIpQLSezNdDNK1-P8mspSbmtC2r86Ee9ZRbC66u929cG2GX0T9UMyw/viewform) in order to use the Reddit API.
