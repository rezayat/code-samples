import { makeActionCreators } from 'redux-standard-actions'

export const { increment, decrement, changeStep } = makeActionCreators(
  'INCREMENT',
  'DECREMENT',
  'CHANGE_STEP'
)
