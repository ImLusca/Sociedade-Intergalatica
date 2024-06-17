import React ,{useState, useEffect} from 'react';
import Styles from './changeLeader.module.css';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import Cookies from "js-cookie";

const ChangeLeaderFacction = () => {
    
    const navigate = useNavigate();
    const [lider, setLider] = useState("");

    const changeLeader = async ()=>{
        if(!window.confirm(`deseja indicar ${lider} como novo lider?`))
        return;

        try {
            const response = await axios.post('http://127.0.0.1:5000/indica_lider', {
                novo_lider: lider,
                nome_faccao: Cookies.get("userFaction"),
            });
            
            if (response.status === 200) {
                alert('Lider da facção atualizado!');
                navigate("/");
            }
        } catch (error) {
            if(error.response?.status == 500){
                alert(error.response?.data?.error);
                return
            }
            alert(`Erro: ${error}`);
        }
    }

    return (
        <>            
            <h3>Indicar novo lider</h3>
            <div className={Styles.container}>
                <input type="text" value={lider} placeholder='Nome Lider' onChange={(e)=>setLider(e.target.value)}/>
                <div className={Styles.buttons}>
                    <button onClick={changeLeader}>Indicar</button>
                </div>
            </div>
        </>
    );
};

export default ChangeLeaderFacction;
