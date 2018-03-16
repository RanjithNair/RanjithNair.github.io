---
layout: post
title: Configuring Redux in a Universal React App with React Router
image: /public/images/redux.png
---

Few days back Tyler McGinnis had shared a great video to build a simple Universal React app with React Router. If you haven't seen it, i would definitely recommend you to watch it once. It was a great article/video explaining the pain points of configuring a universal react app.

https://medium.com/@tylermcginnis/server-rendering-with-react-and-react-router-e0b7ba37653f

<iframe width="560" height="315" src="https://www.youtube.com/embed/mZEv4mHsU5E?rel=0" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

I would like to continue on that sample app and walkthrough the steps involved in configuring Redux within it for state management. So, lets straight away dig into it. I would be using Tyler's boilerplate as a starting point.


1. Clone Tyler's boilerplate from the below location :-

    https://github.com/tylermcginnis/rrssr
2. Installing the required libraries :-
    
    `npm install --save react-router-redux@next react-redux redux redux-thunk history`

3.  Next, we create a store at our server side, populate it and then send it to the client wherein again the store is initialized with the data we sent from server.

    So let's create a function to configure our store. You could see that we accept another optional parameter `history` which we need for `react-redux-router`. We will get back to that later. Along with that, we would configure our required middlewares (*like redux thunk, redux dev tools extensions*)

    ```js
    import { compose, createStore, applyMiddleware } from 'redux'
    import thunk from 'redux-thunk'
    import rootReducer from './rootReducer'
    import { routerMiddleware } from 'react-router-redux'

    export default function configureStore (initialState, history = null) {
      /* Middleware
      * Configure this array with the middleware that you want included
      */
      let middleware = [thunk]

      if (history) {
          middleware.push(routerMiddleware(history))
      }

      // Add universal enhancers here
      let enhancers = []

      const composeEnhancers =
          (typeof window !== 'undefined' &&
          window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__) ||
          compose
          const enhancer = composeEnhancers(
            ...[applyMiddleware(...middleware), ...enhancers]
      )

      // create store with enhancers, middleware, reducers, and initialState
      const store = createStore(rootReducer, initialState, enhancer)

      if (module.hot) {
          // Enable Webpack hot module replacement for reducers
          module.hot.accept('../reducers', () => {
            const nextRootReducer = require('../reducers').default
            store.replaceReducer(nextRootReducer)
          })
      }

      return store
    }
    ```

4. At the server side, the fetching of data depends on the route invoked by the user. Inside each of the component which depends on some kind of data from the API, we will have a static function which dispatches the actions to fetch the data and updates the store.

So, we have the call to dispatch action at 2 places :-

- **Static function**: This will be called from server side.
- **ComponentDidMount**: This will be only called at client side provided the server fetch didn't happen/failed. 

    We will have the check in `componentDidMount` to dispatch the action only if we dont have the data already in redux store. 

    ```jsx
    import React, { Component } from 'react'
    import { connect } from 'react-redux'
    import { bindActionCreators } from 'redux'
    import * as Actions from './Actions'
    class Sample extends Component {
        // This will be called at server side to do the fetching and populating redux store
        static fetchData (store) {
            return store.dispatch(Actions.getSampleData())
        }
        async componentDidMount () {
            // check whether store already has data?
            if (!this.props.sampleData) {
                await this.props.actions.getSampleData()
            }
        }

        render () {
            return (
                <div>
                    <h2>Sample Data</h2>
                    <h3>{this.props.sampleData.name}</h3>
                </div>
            )
        }
    }

    function mapStateToProps (state, ownProps) {
        return {
            sampleData: state.sample
        }
    }

    function mapDispatchToProps (dispatch) {
        return {
            actions: bindActionCreators(Actions, dispatch)
        }
    }

    export default connect(mapStateToProps, mapDispatchToProps)(Sample)
    ```

5. At server side, we get the component, which would eventually be rendered by the route and then call its function to populate the store. 

    ```js
    app.get('*', (req, res, next) => {
        let responseBody = null
        // Create a new Redux store instance
        const initialState = {
            sample: {}
        }
        const store = configureStore(initialState)
        const markup = renderToString(
            <Provider store={store}>
                <StaticRouter location={req.url}>
                    <App />
                </StaticRouter>
            </Provider>
        )
        const activeRoute = routes.find((route) => matchPath(req.url, route)) || {}
        if (activeRoute.component && activeRoute.component.fetchData) {
            activeRoute.component.fetchData(store).then(() => {
                responseBody = AppShell(store.getState(), markup)
                res.send(responseBody)
            })
        } else {
            responseBody = AppShell(store.getState(), markup)
            res.send(responseBody)
        }
    })
    ```

6. We pass in the the redux store state to the `AppShell` function which sets the store to the window object so that we can access it at the client side. This is one of the easiest way to transfer content from server side to client side. Please be cautious of passing in any sensitive information here. 

    `<script>window.__INITIAL_STATE__ = ${serialize(state)}</script>`

7. Now lets jump to the client side. One of the major changes is to use `react-redux-router` which syncs the routing information with the redux store. The changes involved as part of this are :-

    * Pass in the history object while configuring the store. 
    * Use `ConnectedRouter` provided by `react-router-redux` at the client side and pass the history as props to it. 

    Here we also get the redux store state which is set to the window object from the server side and then populate redux store at the client side with that data. 

    ```jsx
    import React from 'react'
    import { hydrate } from 'react-dom'
    import { Provider } from 'react-redux'
    import configureStore from '../store'
    import App from '../shared/App'
    import { ConnectedRouter } from 'react-router-redux'
    import createHistory from 'history/createBrowserHistory'

    const history = createHistory()
    const preloadedState = window.__INITIAL_STATE__
    delete window.__PRELOADED_STATE__
    const store = configureStore(preloadedState, history)

    hydrate(
        <Provider store={store}>
            <ConnectedRouter history={history}>
                <App />
            </ConnectedRouter>
        </Provider>,
        document.getElementById('app')
    )
    ```

## Conclusion

Lets summarize the 3 basic steps involved in this :-

* At the server side, get the component being invoked by the route and call the component's static function to populate the redux store. 
* Set the redux store state to the window object while rendering the server side HTML. 
* At the client side, get the redux state content from the window object and create the store with that content at the client side. 


## Code Repo

You can find the repo with the above changes in the below Git :-

https://github.com/RanjithNair/universal-redux    
