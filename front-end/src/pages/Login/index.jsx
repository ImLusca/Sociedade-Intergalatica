import style from "./Login.module.css";
import logo from "../../assets/logo.png";
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { setUserClassInCookies, setUserNameInCookies } from "../../functions/cookiesManager";

import toastr from "toastr";


function Login() {
    const [usrLogin, setusrLogin] = useState("");
    const [password, setpassword] = useState("");
  
    const navigate = useNavigate();
  
    const successCb = (user) => {
      console.log(user);
      document.cookie = `userToken=${user.token}`;
      navigate("/clientes");
    };
  
    const errorCb = (error) => {
      toastr.error('Erro ao realizar login');
      console.log(error);
    };
  
    const doLogin = async () => {
      
      setUserNameInCookies(usrLogin == "" ? 'Lusca' : usrLogin);
      setUserClassInCookies('Comandante');
      navigate("/overview");
      return
  
      const user = {
        login: usrLogin,
        password: password,
      };
  
      const login = await fetch(endpoints.login, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(user),
      });
  
      const data = await login.json();
  
      if (login.status === 200) {
        successCb(data);
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
  