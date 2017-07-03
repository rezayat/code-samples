import React from 'react'
import { Link } from 'react-router'

export default function NavLink(props) {
  return (
    <Link { ...props }
      style={ { textDecoration: 'none' } }w
      activeStyle={ { fontWeight: 'bolder' } } />
  )
}
