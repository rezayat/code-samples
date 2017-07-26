import React from 'react';

const LoginUser = (props) => {
  return (
    <form onSubmit={ (event) => props.login(event) }>
      <div className="form-group">
        <input
          name="username"
          className="form-control input-lg"
          type="text"
          placeholder="Username"
          required
          onChange={props.handleChange}
        />
      </div>
      <div className="form-group">
        <input
          name="password"
          className="form-control input-lg"
          type="password"
          placeholder="Password"
          required
          onChange={props.handleChange}
        />
      </div>
      <input
        type="submit"
        className="btn btn-primary btn-lg btn-block"
        value="Login"
      />
    </form>
  )
}

export default LoginUser;