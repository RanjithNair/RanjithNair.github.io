---
layout: post
title: How to use external API's in GraphQL via Apollo server
---

There are scenarios in GraphQL where we have to use external API's. Let's take a look at an example of how to call external API's in a GraphQL server. 


As part of this example, lets take an example of Stocktwits API to find the trending stocks and then use the IEXTrading API to get the details of each of the stocks. 

1. Lets install the required packages first

    `npm i grahql apollo-server apollo-datasource-rest --save`

2. First lets create the class which fetches the trending stocks and then gets the details for each of the stocks via Stocktwits API. 

    For this we will create a class which extends `RESTDataSource` from the module `apollo-datasource-rest`. 

    {% gist bccf7fb4053e27f85f5560c84330a5b9 %}

3. Lets create the type defs to define the schema and the required queries. In our case we are just creating a single query to return back an array of `Stock` which are trending on Stocktwits. 

    ```javascript
    const typeDefs = gql`
     type Stock {
      symbol: String
      companyName: String
      sector: String
      latestPrice: Float
      week52High: Float
      week52Low: Float
     }
     type Query {
      stocktwitstrending: [Stock]
     }
    ` 
    ```

4. Lets create the resolvers for each of the queries. Within the resolvers, the `dataSources` will be injected, through which we will be getting the API data. 
    {% gist a995c2ff5b0e903afc73d013e3cdb40c %}

5. Finally, lets create our apollo server.

    ```javascript
    const server = new ApolloServer({
     typeDefs,
     resolvers,
     dataSources: () => {
      return {
       stockTwitsAPI: new StockTwitsAPI()
      }
     }
    })

    // This `listen` method launches a web-server.  Existing apps
    // can utilize middleware options, which we'll discuss later.
    server.listen().then(({ url }) => {
     console.log(`🚀  Server ready at ${url}`)
    })
    ```

Lets start the server and bring up the graphql playground to see how the response looks. 

```
curl 'http://localhost:4000' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Origin: http://localhost:4000' --data-binary '{"query":"{stocktwitstrending{symbol,companyName,latestPrice}}"}' --compressed
```

Response :-

```json
{
  "data": {
    "stocktwitstrending": [
      {
        "symbol": "CRM",
        "companyName": "Salesforce.com Inc",
        "latestPrice": 127.54
      },
      {
        "symbol": "TIF",
        "companyName": "Tiffany & Co.",
        "latestPrice": 94.05
      },
      {
        "symbol": "NTNX",
        "companyName": "Nutanix Inc.",
        "latestPrice": 40.97
      },
      {
        "symbol": "WB",
        "companyName": "Weibo Corporation",
        "latestPrice": 59.1
      },
      {
        "symbol": "SJM",
        "companyName": "J.M. Smucker Company (The)",
        "latestPrice": 109.18
      },
      {
        "symbol": "ACAD",
        "companyName": "ACADIA Pharmaceuticals Inc.",
        "latestPrice": 17
      },
      {
        "symbol": "DKS",
        "companyName": "Dick's Sporting Goods Inc",
        "latestPrice": 37.5
      },
      {
        "symbol": "BURL",
        "companyName": "Burlington Stores Inc.",
        "latestPrice": 148.56
      },
      null,
      {
        "symbol": "BA",
        "companyName": "The Boeing Company",
        "latestPrice": 318.03
      },
      {
        "symbol": "CMCM",
        "companyName": "Cheetah Mobile Inc. American Depositary Shares each representing 10 Class",
        "latestPrice": 5.48
      },
      {
        "symbol": "SINA",
        "companyName": "Sina Corporation",
        "latestPrice": 61.9
      },
      {
        "symbol": "GPIC",
        "companyName": "Gaming Partners International Corporation",
        "latestPrice": 7.69
      },
      {
        "symbol": "AFSI",
        "companyName": "AmTrust Financial Services Inc.",
        "latestPrice": 13.99
      },
      {
        "symbol": "AAL",
        "companyName": "American Airlines Group Inc.",
        "latestPrice": 38.29
      },
      {
        "symbol": "WHR",
        "companyName": "Whirlpool Corporation",
        "latestPrice": 125.26
      },
      {
        "symbol": "PDCO",
        "companyName": "Patterson Companies Inc.",
        "latestPrice": 26.16
      },
      {
        "symbol": "ALK",
        "companyName": "Alaska Air Group Inc.",
        "latestPrice": 70.75
      },
      {
        "symbol": "JILL",
        "companyName": "J. Jill Inc.",
        "latestPrice": 5
      },
      {
        "symbol": "PLAN",
        "companyName": "Anaplan Inc.",
        "latestPrice": 22.5
      },
      {
        "symbol": "GNL",
        "companyName": "Global Net Lease Inc.",
        "latestPrice": 20.18
      },
      {
        "symbol": "TS",
        "companyName": "Tenaris S.A. American Depositary Shares",
        "latestPrice": 24.36
      },
      {
        "symbol": "DAL",
        "companyName": "Delta Air Lines Inc.",
        "latestPrice": 58.31
      },
      {
        "symbol": "BOX",
        "companyName": "Box Inc. Class A",
        "latestPrice": 17.41
      },
      {
        "symbol": "VEEV",
        "companyName": "Veeva Systems Inc. Class A",
        "latestPrice": 89.79
      },
      {
        "symbol": "GNE",
        "companyName": "Genie Energy Ltd. Class B Stock",
        "latestPrice": 6.23
      },
      {
        "symbol": "DLTR",
        "companyName": "Dollar Tree Inc.",
        "latestPrice": 81.82
      },
      {
        "symbol": "MDB",
        "companyName": "MongoDB Inc.",
        "latestPrice": 79.55
      }
    ]
  }
}
```

Why `RESTDataSource`?

Its an obvious question as to why cant we call the API's within the resolvers and just return back the data. The reason this approach is recommended is because of the below reasons :-

1. **Encapsulation**: Its far more clearner to have a class which tacles everything related to the triggering of external API calls rather than having everything within the resolvers. 

2. **Caching**: You can set the caching of the API responses by setting the time you want to cache the responses in the data source. 

    In the above example i can set the caching ttl as below :-
    ```
    const data = await this.get('trending/symbols.json', null, {
     cacheOptions: {ttl: 60}
    })
    ```


