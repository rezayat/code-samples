import React from 'react';

const AddApplicant = (props) => {
  return (
    <form onSubmit={ (event) => props.addApplicant(event) }>
      <div className="form-group">
        <input
          name="username"
          className="form-control input-lg"
          type="text"
          placeholder="Enter a username"
          required
          value={props.username}
          onChange={props.handleChange}
        />
      </div>
      <div className="form-group">
        <input
          name="email"
          className="form-control input-lg"
          type="email"
          placeholder="Enter an email address"
          required
          value={props.email}
          onChange={props.handleChange}
        />
      </div>
      <input
        type="submit"
        className="btn btn-primary btn-lg btn-block"
        value="Add Applicant"
      />
    </form>
  )
}

export default AddApplicant;