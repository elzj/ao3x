function currentUser () {
  const guest = {
    id: null,
    name: "Guest",
    loggedIn: false
  }
  const node = document.getElementById('current_user')
  if (node) {
    const data = JSON.parse(node.getAttribute('data'))
    return data
  } else {
    return guest
  }
}

export default currentUser