import React ,{useState} from 'react';
import Styles from "./domainPlanet.module.css"
import axios from  "axios"
import Cookies from "js-cookie"

const DomainPlanet = () => {    
    const [changeVal, setChangeVal] = useState("");
    
    const handleCancel = ()=>{
        setChangeVal("");
    }

    const handleSubmit = async () => {
        
        if (!changeVal) {
            alert('insira o id do planeta');
            return;
        }
    
        const jsonBody = {nacao: Cookies.get("userNation"), planeta: changeVal}
        
        console.log(jsonBody)
        try {
            const response = await axios.post(`http://127.0.0.1:5000/dominarPlaneta`, jsonBody);
            
            if (response.status === 200) {
                alert(`A nação ${Cookies.get("userNation")} agora domina o planeta ${changeVal}`);
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
            <h3>Dominar Planeta</h3>
            <div className={Styles.container}>
                <input type="text" value={changeVal} placeholder='Id Planeta' onChange={(e)=>setChangeVal(e.target.value)}/>
                <div className={Styles.buttons}>
                    {changeVal.length > 0 && <button onClick={handleCancel}>Cancelar</button>}
                    <button onClick={handleSubmit}>Dominar!</button>
                </div>
            </div>
        </>
    );
};

export default DomainPlanet;
