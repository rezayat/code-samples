import { increment, decrement, changeStep } from './actions'
import { makeActionReducers } from 'redux-standard-actions'
import { combineReducers } from 'redux'

const count = makeActionReducers({
  [increment]: (state, { payload }) => state + payload,
  [decrement]: (state, { payload }) => state - payload,
}, 0)

const step = makeActionReducers({
  [changeStep]: (state, { payload }) => payload,
}, 1)

export default combineReducers({ count, step })

function getStep(state) {
  return state.counter.step
}

function getCount(state) {
  return state.counter.count
}

export const selectors = { getStep, getCount }
