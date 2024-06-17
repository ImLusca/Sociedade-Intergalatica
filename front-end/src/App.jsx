import './App.css'
import Card from "./components/Card";
import Login from "./pages/Login";
import Reports from './pages/Reports';

import Overview from './pages/Overview';

import {
  Route,
  BrowserRouter as Router,
  Routes
} from "react-router-dom";

function App() {

  return (
    <>
      <Card>
        <Router>
          <Routes>
            <Route index element={<Login />} />
            <Route path='/overview' element={<Overview />} />
            <Route path='/reports' element={<Reports />} />
            
          </Routes>
        </Router>
      </Card>

    </>
  )
}

export default App
