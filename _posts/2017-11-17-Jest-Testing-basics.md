---
layout: post
title: Basics of Jest Testing
---

- Jest provides a complete ecosystem for testing. There is No need of extra libraries - Mocha, Sinon, Istanbul, Chai, proxyquire etc. as all present in Jest itself.

### Basic Setup Configurations

- `testMatch `: The glob patterns Jest uses to detect test files. By default it looks for .js and .jsx files inside of __tests__ folders, as well as any files with a suffix of .test or .spec (e.g. Component.test.js or Component.spec.js). It will also find files called test.js or spec.js.

- `setupTestFrameworkScriptFile `: E.g. If you are using EnzymeV2 and React v16, then the configuration of adapter can happen here. https://github.com/airbnb/enzyme/blob/master/docs/installation/README.md

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
- `setupFiles`

## Patterns

Below are the different patterns of using Jest in a typical React - Redux application.
### Snapshot testing of React Components
Snapshot testing is an assertion and not just limited to testing react components. It doesn’t really follow TDD.
```
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

### Redux Stores (HOC/Connected Components)

Mock store for your testing your redux async action creators and middleware with `redux-mock-store`.

```
import configureStore from 'redux-mock-store'
const middlewares = [thunk]
const mockStore = configureStore(middlewares)
<Provider store={mockStore({login: {userid: ''}})}>
  <Login actions={loginActions} />
</Provider>
```

### Action & Reducer Snapshot testing

I have mostly seen Jest being used to test React components. However, Jest makes it simpler to test even your actions and reducers as it's basically an assertion.

Usually, developers do a `console.log` to find out the result and then use that as the assertion by pasting the result. Instead of that, you can just do `toMatchSnapshot()` and Jest will store the result in snapshot file.

We should always take a look at the snapshot to verify whether the results are correct. As always, the Jest snapshots should also be committed in the repo.

```
it('should handle GET_POST_START', () => {
  const addAction = {
    type: actions.ADD_TASK,
    payload: 'Task 1'
  };
  expect(reducer(initialState, addAction)).toMatchSnapshot()
});
```

### Events
With Jest you can test your app state before and after the event.

```
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

In some of the cases, using Jest along with Enzyme gives you complete access to manipulating the DOM elements and then verifying the components with spying & mock functions.

```
const mockCallback = jest.fn()
const wrapper = shallow(<TextInput onChange={mockCallback} />)
wrapper.find('input').simulate('change', {target: {value: 'xyz'}})
expect(onChange).toBeCalledWith(value)
```

### API calls in Redux actions

In cases where we trigger API calls in Redux action creators, we can use `fetch-mock` to mock the status and response.

```
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

There is no need of `sinon` any more as Jest provides a way for spying.

```
const editSpy = jest.spyOn(wrapper.props().children.props.actions, 'updateEditMode')
wrapper.find('span.icon-sysicon-edit').simulate('click')
expect(editSpy).toHaveBeenCalled()
```

### Using Jest for Node Microservices
If you have Proxyquire in your test cases, Jest is not compatible with that. Jest recommends using their own mocking library :)

 https://github.com/thlorenz/proxyquire/issues/152#issuecomment-273854086 https://github.com/facebook/jest/issues/1937


[Converting proxyquire mocks to Jest mocks](http://madole.xyz/mocking-relative-dependencies-in-jest-with-jest-mock/)

### Jest as a testing platform
- `jest-validate`: Generic config validation tool
https://github.com/facebook/jest/tree/master/packages/jest-validate
- `pretty-format` : Stringify any JS value. Almost similar to `JSON.stringify`
. [Faster](https://gist.github.com/thejameskyle/2b04ffe4941aafa8f970de077843a8fd) and no circular reference issue. `prettier` uses it

### Debugging jest

You can use `node --inspect` to debug your Jest cases.

`test:debug: "node --inspect-brk node_modules/.bin/jest --watch"`
