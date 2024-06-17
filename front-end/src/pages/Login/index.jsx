import style from "./Login.module.css";
import logo from "../../assets/logo.png";
import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import Cookies from 'js-cookie';
import axios from 'axios';

import toastr from "toastr";

function Login() {
    const [usrLogin, setusrLogin] = useState("");
    const [password, setpassword] = useState("");
  
    const navigate = useNavigate();
    const cookiesList = ["userCPI","userName","userClass", "userNation", "userFaction"];

    useEffect(()=>{
        cookiesList.forEach((x)=> Cookies.remove(x));
    },[]);


    const successCb = (user) => {
      Cookies.set("userCPI", user[0].trim());
      Cookies.set("userName", user[1].trim());
      Cookies.set("userClass", user[2]?.trim());
      Cookies.set("userNation", user[3]?.trim());
      Cookies.set("userFaction", user[4]?.trim());

      console.log(user);

      navigate("/overview");
    };
  
    const errorCb = (error) => {
      toastr.error('Erro ao realizar login');
    };
  
    const doLogin = async () => {
          
      const login = await axios.get(`http://127.0.0.1:5000/login?user=${usrLogin}&senha=${password}`);
      
      console.log(login)

      if (login.status === 200) {
        successCb(login.data);
        return;
      }
  
      if(login.status === 401){
        toastr.warning("Login inválido!");
        return;  
      }
  
      errorCb(data);
    };
  
    return (
      <div className={style.container}>
        <figure>
          <img src={logo} alt="Logo" />
        </figure>
        <div className={style.group}>
          <label htmlFor="login">Login</label>
          <input
            type="text"
            id="login"
            onChange={(e) => setusrLogin(e.target.value)}
            value={usrLogin}
            onKeyDown={e => { e.key === 'Enter' && doLogin() }}
          />
        </div>
        <div className={style.group}>
          <label htmlFor="senha">Senha</label>
          <input
            type="password"
            id="senha"
            onChange={(e) => setpassword(e.target.value)}
            value={password}
            onKeyDown={e => { e.key === 'Enter' && doLogin() }}
          />
        </div>
        <button onClick={doLogin}>Entrar</button>
      </div>
    );
  }
  export default Login;
  