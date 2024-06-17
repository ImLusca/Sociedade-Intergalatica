import React ,{useState} from 'react';
import Styles from './removeFacction.module.css';
import axios from 'axios';
import Cookies from "js-cookie"

const RemoveNation = () => {
    const [changeVal, setChangeVal] = useState("");

    const handleRemove = async ()=>{
        try {
            const response = await axios.post(`http://127.0.0.1:5000/removeNacao`, {
                lider: Cookies.get("userCPI"),
                nacao: changeVal,
            });
            
            if (response.status === 200) {
                alert('Nação removida!');
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
            <h3>Remover Nação da Facção</h3>
            <div className={Styles.container}>
                <input type="text" value={changeVal} placeholder='Nome Nação' onChange={(e)=>setChangeVal(e.target.value)}/>
                <div className={Styles.buttons}>
                    <button onClick={handleRemove}>Remover</button>
                </div>
            </div>
        </>
    );
};

export default RemoveNation;
