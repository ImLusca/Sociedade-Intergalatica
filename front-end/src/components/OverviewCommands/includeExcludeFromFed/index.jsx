import React ,{useState} from 'react';
import Styles from "./createNewFed.module.css"
import axios from  "axios"
import Cookies from "js-cookie"

const IncludeExcludeFromFed = () => {    
    const [federation, setFederation] = useState("");
    const [changeVal, setChangeVal] = useState("");
    
    const handleExit = async ()=>{
        const response = await axios.delete(`http://127.0.0.1:5000/sairFederacao?nacao=${Cookies.get("userNation")}`);
    
        if (response.status === 200) {
            alert(`A nação ${Cookies.get("userNation")} saiu da federação`);
            nome = changeVal;
        }else{
            alert(response.data.error)
        }
    }

    const handleSubmit = async () => {
        
        try {
            const response = await axios.post(`http://127.0.0.1:5000/entrarFederacao?nacao=${Cookies.get("userNation")}&federacao=${changeVal}`);
    
            if (response.status === 200) {
                alert(`A nação ${Cookies.get("userNation")} agora faz parte da federação ${changeVal}`);
            }else{
                alert(response.data.error)
            }
        } catch (error) {
            alert(`Erro: ${error.response.data.error}`);
        }
    };
    
    return (
        <>
            <h3>Entrar / Sair federação</h3>
            <div className={Styles.container}>
                <input type="text" value={changeVal} placeholder='Mudar de federação' onChange={(e)=>setChangeVal(e.target.value)}/>
                <div className={Styles.buttons}>
                    {changeVal.length == 0 ? <button onClick={handleExit}>Sair da federaçao atual</button>:<button onClick={handleSubmit}>Entrar na Federação</button>}
                </div>
            </div>
        </>
    );
};

export default IncludeExcludeFromFed;
