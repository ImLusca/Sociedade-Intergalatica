import React ,{useState} from 'react';
import Styles from "./createNewFed.module.css"
import axios from  "axios"
import Cookies from "js-cookie"

const CreateNewFed = () => {    
    const [changeVal, setChangeVal] = useState("");

    
    const handleCancel = ()=>{
        setChangeVal("");
    }

    const handleSubmit = async () => {
    
        if (!changeVal) {
            alert('insira um nome para a federação');
            return;
        }
    
        const jsonBody = {nacao: Cookies.get("userNation"), federacao: changeVal}
        
        console.log(jsonBody)
        try {
            const response = await axios.post(`http://127.0.0.1:5000/criarFederacao`, jsonBody);
            
            if (response.status === 200) {
                alert(`A federação ${changeVal} foi criada`);
                alert(`A nação ${Cookies.get("userNation")} agora faz parte da federação ${changeVal}`);
                setChangeVal("");
            }else{
                alert(response)
            }
        } catch (error) {
            console.log(error)
            alert(`Erro: ${error.response.data.error}`);
        }
    };
    

    return (
        <>
            <h3>Criar nova Federação</h3>
            <div className={Styles.container}>

                <input type="text" value={changeVal} placeholder='Nome Federação' onChange={(e)=>setChangeVal(e.target.value)}/>

                <div className={Styles.buttons}>
                    {changeVal.length > 0 && <button onClick={handleCancel}>Cancelar</button>}
                    <button onClick={handleSubmit}>Criar</button>
                </div>
            </div>
        </>
    );
};

export default CreateNewFed;
