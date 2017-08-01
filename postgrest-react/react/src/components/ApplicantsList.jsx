import React from 'react';

const ApplicantsList = (props) => {
  return (
    <div>
      {
        props.applicants.map((applicant) => {
          return <h4 key={ applicant.id } className="well">
                  <strong>{ applicant.username }</strong> - 
                  <em>{applicant.created_at}</em>
              </h4>
        })
      }
    </div>
  )
}

export default ApplicantsList;