import React from 'react';

const Logout = (props) => {
  return (
    <form onSubmit={ (event) => props.logout(event) }>
      <input
        type="submit"
        name="btn_logout"
        className="btn btn-lg btn-block"
        value="Logout"
      />
    </form>
  )
}

export default Logout;