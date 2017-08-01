import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import axios from 'axios';

import ApplicantsList from './components/ApplicantsList';
import AddApplicant from './components/AddApplicant';
import LoginUser from './components/LoginUser.jsx';
import LogoutUser from './components/LogoutUser.jsx';

const REACT_API_URL = process.env.REACT_API_URL || '/api';
const REACT_AUTHORIZATION_URL = process.env.REACT_AUTHORIZATION_URL || '/login';

console.log(REACT_API_URL);
console.log(REACT_AUTHORIZATION_URL);

class App extends Component {
  constructor() {
    super()
    this.state = {
      applicants: [],
      username: '',
      email: '',
      login_username: '',
      login_password: '',
      token: ''
    }
  }
  componentDidMount() {
    if (this.currentState().token){
      this.getApplicants();
    }
  }
  currentState(){
    // deepcopy 
    return JSON.parse(JSON.stringify(this.state))
    // return this.state
  }
  updateState(obj) {
    var curstate = this.currentState()
    var newstate = {};
    for (var key in curstate) {
      newstate[key] = curstate[key];
    }

    for (var key2 in obj) {
      newstate[key2] = obj[key2];
    }
    this.setState(newstate);
    return this.currentState()
  }

  getApplicants() {
    var auth_token = "Bearer " + this.state.token

    axios.get(`${REACT_API_URL}/applicants`,{
      headers:
        {
            'Authorization': auth_token,
            'Content-Type': 'application/json',
            'Accept-language': 'en_US',
        }})
    .then((res) => {
      this.updateState({ applicants: res.data }); 
    })
    .catch((err) => { console.log(err); })
  }

  addApplicant(event) {
    event.preventDefault();
    const data = {
      username: this.state.username,
      // row_role: this.state.username,
      email: this.state.email,
      active: true,
      created_at: new Date().toLocaleString(),
    }
    
    axios.post(`${REACT_API_URL}/applicants`, data, {
            headers: {
                'Content-Type': 'application/json',
                'Authorization': "Bearer " + this.state.token,
            }})
    .then((res) => {
      this.getApplicants();
      this.updateState({ username: '' });
      this.updateState({ email: '' });
    })
    .catch((err) => { console.log(err); })
  }
  handleChange(event) {
    const obj = {};
    obj[event.target.name] = event.target.value;
    this.updateState(obj);
  }
  handleCredentialsChanged(event) {

    var field_name = event.target.name;
    var login_field_name = 'login_' + field_name;

    const obj = {};
    obj[login_field_name] = event.target.value;
    this.updateState(obj)

  }
  logout(event) {
    this.updateState({token:""})
    return this.render_login()
  }
  login(event) {
    event.preventDefault();
    
    const login_data = {
      username: this.state.login_username,
      pass: this.state.login_password
    }
    
    // axios.post('http://localhost:1234/login',login_data, 

    axios.post(`${REACT_AUTHORIZATION_URL}`, login_data,
          {
            headers: {
                'Accept': 'application/json',
                'Content-Type': "application/json;charset=utf-8"
              }
            }
            )
    .then((res) => {
      this.updateState({ 'token': res.data[0]["token"]});
      this.getApplicants();
     })
    .catch((err) => { console.log(err); })

    this.updateState({'login_password':''});

  }
  render_authorized() {
    return (
      <div className="container">
        <div className="row">
          <div className="col-md-6">
            <br/>
            <h1>All applicants</h1>
            <hr/><br/>
            <AddApplicant
              username={this.state.username}
              email={this.state.email}
              handleChange={ this.handleChange.bind(this) }
              addApplicant={ this.addApplicant.bind(this) }
            />
            <br/>
            <LogoutUser
              logout={ this.logout.bind(this) }
            />
            <br/>
            <ApplicantsList applicants={ this.state.applicants }/>
          </div>
        </div>
      </div>
    )
  }
  render_login() {
    return (
      <div className="container">
        <div className="row">
          <div className="col-md-6">
            <br/>
            <h1>Login</h1>
            <hr/><br/>
            <LoginUser
              username={this.state.login_username}
              password={this.state.login_password}
              handleChange={ this.handleCredentialsChanged.bind(this) }
              login={ this.login.bind(this) }
            />
          </div>
        </div>
      </div>
    )
  }
  render() {
    if (this.state.token) {
      return this.render_authorized()
    }
    return this.render_login()
  }
}

ReactDOM.render(
  <App />,
  document.getElementById('root')
);