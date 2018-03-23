---
layout: post
title: Jest Testing patterns in React-Redux applications
---

- Jest provides a complete ecosystem for testing. There is no need of extra libraries - Mocha, Sinon, Istanbul, Chai, proxyquire etc. as all are  present in Jest itself.

### Basic Setup Configurations

- `testMatch `: The glob patterns Jest uses to detect test files. By default it looks for .js and .jsx files inside of __tests__ folders, as well as any files with a suffix of .test or .spec (e.g. Component.test.js or Component.spec.js). It will also find files called test.js or spec.js.

- `setupTestFrameworkScriptFile `: E.g. If you are using EnzymeV2 and React v16, then the configuration of adapter can happen here. https://github.com/airbnb/enzyme/blob/master/docs/installation/README.md

      `"setupTestFrameworkScriptFile": "./src/app/utils/setup-tests.js"`


    And inside that we will have the below code. Make sure you install `enzyme-adapter-react-16`
      
      
    ```js
    // setup file
    import { configure } from 'enzyme'
    import Adapter from 'enzyme-adapter-react-16'

    configure({ adapter: new Adapter() })
    ```

      


- `setupFiles`

- `coverageReporters`: Default: [“json”, “lcov”, “text”]

 ```
"jest": {
    "collectCoverage": true,
    "setupTestFrameworkScriptFile": "./setupTests.js",
    "setupFiles": [
      "./setup.js"
    ],
    "testPathIgnorePatterns": [
      "./node_modules/",
      "./build/"
    ]
}
```

## Patterns

Below are the different patterns of using Jest in a typical React - Redux application.
### Snapshot testing of React Components
------
Snapshot testing is an assertion and not just limited to testing react components. It doesn’t really follow TDD.
```jsx
const component = renderer.create(
    <LoginForm {...props} />
);
let tree = component.toJSON();
expect(tree).toMatchSnapshot();
```

If you are using enzyme, you can use `shallow/mount` method for snapshot testing as well with `enzyme-to-json`.

```
import toJson from 'enzyme-to-json'
const component = shallow(<LoginForm {...props} />)
expect(toJson(component)).toMatchSnapshot()
```

One of the most easiest way to set props for the component you need to test is by using the React chrome plugin. It has this super cool way to copy props and it's saved to your clipboard as a json which you can then paste in your test file. 

![My helpful screenshot](/public/images/react_chrome_plugin.PNG)

### Redux Stores (HOC/Connected Components)
------
Mock store for your testing your redux async action creators and middleware with `redux-mock-store`.

```jsx
import configureStore from 'redux-mock-store'
const middlewares = [thunk]
const mockStore = configureStore(middlewares)
<Provider store={mockStore({login: {userid: ''}})}>
  <Login actions={loginActions} />
</Provider>
```

### Action & Reducer Snapshot testing
------
I have mostly seen Jest being used to test React components. However, Jest makes it simpler to test even your actions and reducers as it's basically an assertion.

Usually, developers do a `console.log` to find out the result and then use that as the assertion by pasting the result. Instead of that, you can just do `toMatchSnapshot()` and Jest will store the result in snapshot file.

We should always take a look at the snapshot to verify whether the results are correct. As always, the Jest snapshots should also be committed in the repo.

```js
it('should handle GET_POST_START', () => {
  const addAction = {
    type: actions.ADD_TASK,
    payload: 'Task 1'
  };
  expect(reducer(initialState, addAction)).toMatchSnapshot()
});
```

### Events
------
With Jest you can test your app state before and after the event.

```js
it('should render Markdown in preview mode', () => {
    const wrapper = shallow(
        <Login {...props} />
    );

    expect(wrapper).toMatchSnapshot();

    wrapper.find('[name="show-password"]').simulate('click');

    expect(wrapper).toMatchSnapshot();
});
```

### Event Handlers (Enzyme + Jest)
------
In some of the cases, using Jest along with Enzyme gives you complete access to manipulating the DOM elements and then verifying the components with spying & mock functions.

```js
const mockCallback = jest.fn()
const wrapper = shallow(<TextInput onChange={mockCallback} />)
wrapper.find('input').simulate('change', {target: {value: 'xyz'}})
expect(onChange).toBeCalledWith(value)
```

### API calls in Redux actions
------
In cases where we trigger API calls in Redux action creators, we can use `fetch-mock` to mock the status and response.

```js
it('Password change failure - Locked', () => {
    fetchMock
      .post(CHANGE_PASSWORD_URL, { status: 423, body: 'locked' })
      .catch(503)
    const store = mockStore({
      password: {
        oldPassword: {
          value: 'nmc12345',
          isValid: true
        },
        newPassword: {
          value: 'abc12345',
          isValid: true
        }
      }
    })

    const expectedAction = [
      { type: 'CHANGE_PASSWORD', meta: undefined },
      {
        type: 'ACCOUNT_LOCKED',
        payload: {
          message: `The password you've entered is incorrect. For your security, we're automatically logging you out of your account. Please try again at least two hours later.`
        },
        meta: {
          analytics: {
            type: 'ACCOUNT_LOCKED',
            payload: {
              message: 'Locked, error.. account locked'
            }
          }
        }
      }
    ]
    store.dispatch(actions.validateAndChangePassword()).then(() => {
      expect(store.getActions()).toEqual(expectedAction)
    })
  })
  ```

### Jest Spying functions
------
There is no need of `sinon` any more as Jest provides a way for spying.

```js
const editSpy = jest.spyOn(wrapper.props().children.props.actions, 'updateEditMode')
wrapper.find('span.icon-sysicon-edit').simulate('click')
expect(editSpy).toHaveBeenCalled()
```

### Using Jest for Node Microservices
------
If you have Proxyquire in your test cases, Jest is not compatible with that. Jest recommends using their own mocking library :)

 https://github.com/thlorenz/proxyquire/issues/152#issuecomment-273854086 https://github.com/facebook/jest/issues/1937


[Converting proxyquire mocks to Jest mocks](http://madole.xyz/mocking-relative-dependencies-in-jest-with-jest-mock/)

### Jest as a testing platform
------
- `jest-validate`: Generic config validation tool
https://github.com/facebook/jest/tree/master/packages/jest-validate
- `pretty-format` : Stringify any JS value. Almost similar to `JSON.stringify`
. [Faster](https://gist.github.com/thejameskyle/2b04ffe4941aafa8f970de077843a8fd) and no circular reference issue. `prettier` uses it

### Debugging jest
------
You can use `node --inspect` to debug your Jest cases.

`test:debug: "node --inspect-brk node_modules/.bin/jest --watch"`

### Editor setup
------
When you write test cases, you would often see errors and warnings related to jest keywords (`it, expect`) when you have Standard plugin installed in your editor. One way to mitigate this is by adding the `env` keyword to your `standard` configuration and set it to `jest`. With that done, you would no more see the warnings and errors related to Jest. 

```
"standard": {
    "ignore": [
      "/src/app/Validator/lib/*"
    ],
    "env": [ "jest" ]
}
```