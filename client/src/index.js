import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import axios from 'axios';
// import $ from 'jquery';

import UsersList from './components/UsersList';
import AddUser from './components/AddUser';


// // using jQuery
// function getCookie(name) {
//     var cookieValue = null;
//     if (document.cookie && document.cookie !== '') {
//         var cookies = document.cookie.split(';');
//         for (var i = 0; i < cookies.length; i++) {
//             var cookie = $.trim(cookies[i]);
//             // Does this cookie string begin with the name we want?
//             if (cookie.substring(0, name.length + 1) === (name + '=')) {
//                 cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
//                 break;
//             }
//         }
//     }
//     return cookieValue;
// }


class App extends Component {
  constructor() {
    super()
    this.state = {
      users: [],
      username: '',
      email: ''
    }
  }
  componentDidMount() {
    this.getUsers();
  }
  getUsers() {
    console.log(`${process.env.REACT_APP_USERS_SERVICE_URL}/users/`);
    
    axios.get(`${process.env.REACT_APP_USERS_SERVICE_URL}/users/`)
    .then((res) => { this.setState({ users: res.users }); })
    .catch((err) => { console.log(err); })
  }
  addUser(event) {
    event.preventDefault();
    const data = {
      username: this.state.username,
      email: this.state.email
    }
    // axios
    // .create(
    // {
    //   headers: {'X-CSRFToken': getCookie('csrftoken')}
    // }
    // )
    axios.post(`${process.env.REACT_APP_USERS_SERVICE_URL}/users/`, data)
    .then((res) => {
      this.getUsers();
      this.setState({ username: '' });
      this.setState({ email: '' });
    })
    .catch((err) => { console.log(err); })
  }
  handleChange(event) {
    const obj = {};
    obj[event.target.name] = event.target.value;
    this.setState(obj);
  }
  render() {
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
            <UsersList users={ this.state.users }/>
          </div>
        </div>
      </div>
    )
  }
}

ReactDOM.render(
  <App />,
  document.getElementById('root')
);