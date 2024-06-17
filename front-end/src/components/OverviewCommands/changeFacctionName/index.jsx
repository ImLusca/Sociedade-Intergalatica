import React ,{useState} from 'react';
import Styles from "./changeFacction.module.css"
import axios from  "axios"
import Cookies from "js-cookie"

const ChangeNameFacction = ({ nome }) => {
    
    const [isChanging, setIsChanging] = useState(false);
    const [changeVal, setChangeVal] = useState(nome);

    const handleChangeName = ()=>{
        if(isChanging){
            handleSubmit();
        }
        
        setIsChanging(!isChanging);
    }
    
    const handleCancel = ()=>{
        setIsChanging(false);
        setChangeVal(nome);
    }

    const handleSubmit = async () => {
    
        if (!changeVal) {
            alert('insira um nome');
            return;
        }
    
        try {
            const response = await axios.post('http://127.0.0.1:5000/update_faccao_nome', {
                old_name: nome,
                new_name: changeVal,
            });
        
            if (response.status === 200) {
                alert('Nome da facção atualizado!');
                nome = changeVal;
            }
            console.log(response);
        } catch (error) {
            alert(`Erro: ${error.response.data.error}`);
        }
    };
    

    return (
        <>
            <h3>Nome da facção</h3>
            <div className={Styles.container}>

                {
                    isChanging ?
                        <input type="text" value={changeVal} onChange={(e)=>setChangeVal(e.target.value)}/>
                        : <h1>{changeVal}</h1>
                }
                <div className={Styles.buttons}>
                    {isChanging && <button onClick={handleCancel}>Cancelar</button>}                
                    <button onClick={handleChangeName}>Alterar nome</button>
                </div>
            </div>
        </>
    );
};

export default ChangeNameFacction;
