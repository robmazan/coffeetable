import React from 'react';
import './App.css';

function App() {
  return (
    <form method="POST" encType="multipart/form-data" action="/upload">
      <input name="file" type="file" multiple />
      <button type="submit">Send</button>
    </form>
  );
}

export default App;
