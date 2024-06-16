import { useCallback,useState } from 'react'
import Particles from "react-particles";
import { loadFull } from "tsparticles";
import particlesConfig from "./particlesConfig.json";

import './App.css'
import Card from "./components/Card";
import Login from "./pages/Login";

import Overview from './pages/Overview';


import {
  Route,
  BrowserRouter as Router,
  Routes
} from "react-router-dom";

function App() {

  const particlesInit = useCallback(async (engine) => {
    await loadFull(engine);
  }, []);

  return (
    <>
      <Particles params={particlesConfig} init={particlesInit}></Particles>

      <Card>
        <Router>
          <Routes>
            <Route index element={<Login />} />
            <Route path='/overview' element={<Overview />} />
            
          </Routes>
        </Router>
      </Card>

    </>
  )
}

export default App
