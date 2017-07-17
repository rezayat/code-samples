import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import axios from 'axios';

import UsersList from './components/UsersList';
import AddUser from './components/AddUser';
import LoginUser from './components/LoginUser.jsx';
import LogoutUser from './components/LogoutUser.jsx';

class App extends Component {
  constructor() {
    super()
    this.state = {
      users: [],
      username: '',
      email: '',
      login_username: '',
      login_password: '',
      token: ''
    }
  }
  componentDidMount() {
    if (this.currentState().token){
      this.getUsers();
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

    for (var key in obj) {
      newstate[key] = obj[key];
    }
    this.setState(newstate);
    return this.currentState()
  }

  getUsers() {
    // console.log(`${process.env.REACT_APP_USERS_SERVICE_URL}/users`);
    
    axios.get(`${process.env.REACT_APP_USERS_SERVICE_URL}/users`, {
            headers: {
                'accept': 'application/json',

            // hard-coded token which should be generated on User's login
            // can generate any token, using the secret key "not_secret_at_all"
                'authorization': this.state.token,
                'accept-language': 'en_US',
                'content-type': 'application/x-www-form-urlencoded'
            }})
    .then((res) => { this.updateState({ users: res.data }); })
    .catch((err) => { console.log(err); })
  }
  addUser(event) {
    event.preventDefault();
    const data = {
      username: this.state.username,
      email: this.state.email,
      active: true,
      created_at: new Date().toLocaleString(),
    }

    axios.post(`${process.env.REACT_APP_USERS_SERVICE_URL}/users`, data, {
            headers: {
                'accept': 'application/json',

            // hard-coded token which should be generated on User's login
            // can generate any token, using the secret key "not_secret_at_all"
                'authorization': this.state.token,
                'accept-language': 'en_US',
                'content-type': 'application/x-www-form-urlencoded'
            }})
    .then((res) => {
      this.getUsers();
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
      password: this.state.login_password
    }

    axios.post(`${process.env.REACT_APP_AUTHORIZATION_URL}/login`,login_data, {
            headers: {
                'accept': 'application/json'
              }
            })
    .then((res) => { 
      this.updateState({ token: res.headers['authorization']});
      this.getUsers();
     })
    .catch((err) => { console.log(err); })
  }
  render_authorized() {
    return (
      <div className="container">
        <div className="row">
          <div className="col-md-6">
            <br/>
            <h1>All Users</h1>
            <hr/><br/>
            <AddUser
              username={this.state.username}
              email={this.state.email}
              handleChange={ this.handleChange.bind(this) }
              addUser={ this.addUser.bind(this) }
            />
            <br/>
            <LogoutUser
              logout={ this.logout.bind(this) }
            />
            <br/>
            <UsersList users={ this.state.users }/>
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